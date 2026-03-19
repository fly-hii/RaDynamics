import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import { verifyAWSCredentials } from '@/lib/aws-service';
import dbConnect from '@/lib/db';
import AWSAccount from '@/models/AWSAccount';

export async function POST(request: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized session.' }, { status: 401 });
    }

    const {
      organizationName,
      accountName,
      accessKey,
      secretKey,
      region,
      description,
      isPrimary
    } = await request.json();

    if (!organizationName || !accountName || !accessKey || !secretKey || !region) {
      return NextResponse.json({ success: false, error: 'All fields are required.' }, { status: 400 });
    }

    // Verify with AWS STS
    let awsAccountId: string;
    try {
      awsAccountId = (await verifyAWSCredentials({
        accessKeyId: accessKey,
        secretAccessKey: secretKey,
        region,
      })) as string;
    } catch (error: any) {
      return NextResponse.json({ success: false, error: error.message }, { status: 400 });
    }

    // Unset primary for others if this is primary
    if (isPrimary) {
      await AWSAccount.updateMany(
        { userId: user.userId, organizationName },
        { isPrimary: false }
      );
    }

    const existingAccountsCount = await AWSAccount.countDocuments({
      userId: user.userId,
      organizationName
    });

    const awsAccount = new AWSAccount({
      userId: user.userId,
      organizationId: user.organizationId,
      organizationName,
      accountName,
      accountId: awsAccountId,
      accessKey,
      secretKey,
      region,
      description,
      verified: true,
      isPrimary: isPrimary || existingAccountsCount === 0,
      lastVerified: new Date()
    });

    await awsAccount.save();

    return NextResponse.json({
      success: true,
      accountId: awsAccount._id,
      awsAccountId,
      message: 'AWS account successfully linked and verified.'
    }, { status: 200 });

  } catch (error: any) {
    console.error('AWS verification API error:', error);
    return NextResponse.json({ success: false, error: 'Internal server error.', details: error.message }, { status: 500 });
  }
}
