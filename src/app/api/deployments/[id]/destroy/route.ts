import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import dbConnect from '@/lib/db';
import Deployment from '@/models/Deployment';
import AWSAccount from '@/models/AWSAccount';
import { destroyTerraform } from '@/lib/terraform-service';

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    const deploymentId = params.id;

    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized.' }, { status: 401 });
    }

    const deployment = await Deployment.findOne({
      _id: deploymentId,
      userId: user.userId
    });

    if (!deployment) {
      return NextResponse.json({ success: false, error: 'Deployment not found.' }, { status: 404 });
    }

    if (!deployment.workspaceId) {
       // If no workspace but we want to clear it from the UI
       deployment.status = 'deleted';
       await deployment.save();
       return NextResponse.json({ success: true, message: 'Deployment cleared.' });
    }

    const awsAccount = await AWSAccount.findById(deployment.awsAccountId);
    if (!awsAccount) {
      return NextResponse.json({ success: false, error: 'AWS Account not found for resource.' }, { status: 404 });
    }

    // Update status to destroying
    deployment.status = 'destroying';
    await deployment.save();

    // Trigger destroy asynchronously
    const credentials = {
        accessKey: awsAccount.accessKeyId,
        secretKey: (awsAccount as any).getDecryptedCredentials().secretAccessKey,
        region: deployment.config.region || awsAccount.region
    };

    destroyTerraform(deployment.workspaceId, credentials).then(async (result) => {
        if (result.success) {
            deployment.status = 'destroyed';
            deployment.terraformOutput = result.stdout;
        } else {
            deployment.status = 'destroy_failed';
            deployment.errorLog = result.error;
        }
        deployment.updatedAt = new Date();
        await deployment.save();
    }).catch(async (err) => {
        deployment.status = 'destroy_failed';
        deployment.errorLog = err.message;
        await deployment.save();
    });

    return NextResponse.json({ 
      success: true, 
      message: 'Resource termination initiated.' 
    });

  } catch (error: any) {
    console.error('Destroy deployment error:', error);
    return NextResponse.json({ success: false, error: 'Internal server error.' }, { status: 500 });
  }
}
