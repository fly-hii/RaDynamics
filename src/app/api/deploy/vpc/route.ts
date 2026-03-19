import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import dbConnect from '@/lib/db';
import AWSAccount from '@/models/AWSAccount';
import Deployment from '@/models/Deployment';
import Organization from '@/models/Organization';
import { STSClient, GetCallerIdentityCommand } from "@aws-sdk/client-sts";
import { EC2Client, CreateVpcCommand, ModifyVpcAttributeCommand, CreateInternetGatewayCommand, AttachInternetGatewayCommand, CreateSubnetCommand, ModifySubnetAttributeCommand, CreateRouteTableCommand, CreateRouteCommand, AssociateRouteTableCommand } from "@aws-sdk/client-ec2";

export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized.' }, { status: 401 });
    }

    const body = await request.json();
    const {
      vpcName,
      region,
      cidrBlock,
      awsAccountId,
      resourcesMode,
      createInternetGateway,
      createPublicSubnet,
      publicSubnetCidr
    } = body;

    if (!region || !awsAccountId) {
      return NextResponse.json({ success: false, error: 'Region and AWS account are required.' }, { status: 400 });
    }

    const awsAccount = await AWSAccount.findOne({ _id: awsAccountId, userId: user.userId });
    if (!awsAccount) {
      return NextResponse.json({ success: false, error: 'AWS account not found or access denied.' }, { status: 404 });
    }

    // Increment Organization Usage
    const org = await Organization.findOne({ _id: awsAccount.organizationId });
    if (org) {
        org.usage = org.usage || {};
        org.usage.deployments = (org.usage.deployments || 0) + 1;
        await org.save();
    }

    const { accessKeyId, secretAccessKey } = awsAccount.getDecryptedCredentials();

    const ec2 = new EC2Client({
      credentials: { accessKeyId, secretAccessKey },
      region
    });

    // Step 1: Create VPC
    const createVpcCmd = new CreateVpcCommand({
      CidrBlock: cidrBlock || '10.0.0.0/16',
      TagSpecifications: [{
        ResourceType: 'vpc',
        Tags: [{ Key: 'Name', Value: vpcName || 'RayDynamics-VPC' }]
      }]
    });

    const vpcResult = await ec2.send(createVpcCmd);
    const vpcId = vpcResult.Vpc?.VpcId;

    if (!vpcId) {
      throw new Error("Failed to create VPC.");
    }

    // Step 2: Enabled DNS attributes
    await ec2.send(new ModifyVpcAttributeCommand({ VpcId: vpcId, EnableDnsSupport: { Value: true } }));
    await ec2.send(new ModifyVpcAttributeCommand({ VpcId: vpcId, EnableDnsHostnames: { Value: true } }));

    // Step 3: Handle "VPC and More" mode
    let internetGatewayId: string | undefined;
    let publicSubnetId: string | undefined;

    if (resourcesMode === 'vpc-and-more') {
      if (createInternetGateway) {
         const igwResult = await ec2.send(new CreateInternetGatewayCommand({
           TagSpecifications: [{
             ResourceType: 'internet-gateway',
             Tags: [{ Key: 'Name', Value: `${vpcName || vpcId}-igw` }]
           }]
         }));
         internetGatewayId = igwResult.InternetGateway?.InternetGatewayId;
         if (internetGatewayId) {
            await ec2.send(new AttachInternetGatewayCommand({ InternetGatewayId: internetGatewayId, VpcId: vpcId }));
         }
      }

      if (createPublicSubnet && publicSubnetCidr) {
         const subnetResult = await ec2.send(new CreateSubnetCommand({
            VpcId: vpcId,
            CidrBlock: publicSubnetCidr,
            TagSpecifications: [{
               ResourceType: 'subnet',
               Tags: [
                  { Key: 'Name', Value: `${vpcName || vpcId}-public` },
                  { Key: 'Type', Value: 'Public' }
               ]
            }]
         }));
         publicSubnetId = subnetResult.Subnet?.SubnetId;
         if (publicSubnetId) {
            await ec2.send(new ModifySubnetAttributeCommand({ SubnetId: publicSubnetId, MapPublicIpOnLaunch: { Value: true } }));
            
            // Route table for public subnet
            if (internetGatewayId) {
               const rtResult = await ec2.send(new CreateRouteTableCommand({
                  VpcId: vpcId,
                  TagSpecifications: [{
                     ResourceType: 'route-table',
                     Tags: [{ Key: 'Name', Value: `${vpcName || vpcId}-public-rt` }]
                  }]
               }));
               const routeTableId = rtResult.RouteTable?.RouteTableId;
               if (routeTableId) {
                  await ec2.send(new CreateRouteCommand({
                     RouteTableId: routeTableId,
                     DestinationCidrBlock: '0.0.0.0/0',
                     GatewayId: internetGatewayId
                  }));
                  await ec2.send(new AssociateRouteTableCommand({ SubnetId: publicSubnetId, RouteTableId: routeTableId }));
               }
            }
         }
      }
    }

    // Step 4: Save Deployment
    const deployment = new Deployment({
      userId: user.userId,
      awsAccountId: awsAccount._id,
      resourceType: 'vpc',
      resourceName: vpcName || vpcId,
      status: 'completed',
      config: { vpcId, internetGatewayId, publicSubnetId, ...body }
    });

    await deployment.save();

    return NextResponse.json({
      success: true,
      message: 'VPC deployed successfully.',
      data: { vpcId, internetGatewayId, publicSubnetId }
    }, { status: 200 });

  } catch (error: any) {
    console.error('VPC deployment API error:', error);
    return NextResponse.json({ success: false, error: 'Deployment failed.', details: error.message }, { status: 500 });
  }
}
