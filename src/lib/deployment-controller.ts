import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import dbConnect from '@/lib/db';
import Deployment from '@/models/Deployment';
import AWSAccount from '@/models/AWSAccount';
import { executeTerraform } from '@/lib/terraform-service';
import Organization from '@/models/Organization';

export async function handleDeployment(resourceType: string, request: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized session.' }, { status: 401 });
    }

    const body = await request.json();
    const { awsAccountId, ...config } = body;

    if (!awsAccountId) {
      return NextResponse.json({ success: false, error: 'AWS account ID is required.' }, { status: 400 });
    }

    const awsAccount = await AWSAccount.findOne({ _id: awsAccountId, userId: user.userId });
    if (!awsAccount) {
      return NextResponse.json({ success: false, error: 'AWS account not found or access denied.' }, { status: 404 });
    }

    // Check Organization and increment usage if needed
    const org = await Organization.findOne({ _id: user.organizationId });
    if (org) {
        // Simple mock of usage increment
        org.usage = org.usage || {};
        org.usage.deployments = (org.usage.deployments || 0) + 1;
        await org.save();
    }

    const resourceName = config.instance_name || config.bucketName || config.clusterName || config.resourceName || 'Unnamed Resource';

    const deployment = new Deployment({
      userId: user.userId,
      awsAccountId,
      resourceType,
      resourceName,
      config,
      status: 'pending'
    });

    await deployment.save();

    const credentials = awsAccount.getDecryptedCredentials();
    
    // Execute Terraform asynchronously
    // In a real prod environment, this would be a background job (BullMQ/QStash)
    // For now, we fire and forget in Next.js (though Vercel might kill it, local dev is fine)
    executeTerraform(resourceType, config, credentials, user.userId).then(async (result) => {
        deployment.status = result.success ? 'completed' : 'failed';
        deployment.terraformOutput = result.stdout;
        deployment.errorLog = result.error || result.stderr;
        deployment.workspaceId = result.workspaceId;
        deployment.updatedAt = new Date();
        await deployment.save();
        console.log(`Deployment ${deployment._id} finished with status: ${deployment.status}`);
    }).catch(async (err) => {
        deployment.status = 'failed';
        deployment.errorLog = err.message;
        await deployment.save();
    });

    return NextResponse.json({ 
      success: true, 
      deploymentId: deployment._id, 
      status: 'pending',
      message: 'Deployment initiated successfully.' 
    }, { status: 202 });

  } catch (error: any) {
    console.error(`Deployment API error for ${resourceType}:`, error);
    return NextResponse.json({ success: false, error: 'Internal server error.', details: error.message }, { status: 500 });
  }
}
