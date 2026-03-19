import { NextResponse } from 'next/server';
import dbConnect from '@/lib/db';
import AWSAccount from '@/models/AWSAccount';
import Organization from '@/models/Organization';
import { verifyToken } from '@/lib/auth-utils';
import { EC2Client, DescribeRegionsCommand } from '@aws-sdk/client-ec2';
import { encrypt } from '@/lib/encryption';

// GET - list user's AWS accounts
export async function GET(request: Request) {
  try {
    await dbConnect();
    const user = verifyToken(request);
    if (!user) return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });

    const accounts = await AWSAccount.find({ userId: user.userId, isActive: true })
      .select('-accessKey -secretKey')
      .sort({ isPrimary: -1, createdAt: -1 });

    return NextResponse.json({ success: true, accounts }, { status: 200 });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

// POST - add new AWS account
export async function POST(request: Request) {
  try {
    await dbConnect();
    const user = verifyToken(request);
    if (!user) return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });

    const { accountName, accountId, accountType, accessKey, secretKey, region, description } = await request.json();

    if (!accountName || !accessKey || !secretKey || !region) {
      return NextResponse.json({ success: false, error: 'Account name, credentials and region are required' }, { status: 400 });
    }

    // Verify credentials by calling AWS
    let verified = false;
    try {
      const ec2 = new EC2Client({
        region,
        credentials: { accessKeyId: accessKey, secretAccessKey: secretKey },
      });
      await ec2.send(new DescribeRegionsCommand({}));
      verified = true;
    } catch {
      verified = false;
    }

    // Get or create org
    let org = await Organization.findOne({ ownerId: user.userId });
    if (!org) {
      org = await Organization.create({ name: `${user.email}'s Org`, ownerId: user.userId });
    }

    const isFirst = (await AWSAccount.countDocuments({ userId: user.userId })) === 0;

    const account = await AWSAccount.create({
      userId: user.userId,
      organizationId: org._id,
      organizationName: org.name,
      accountName,
      accountId: accountId || '',
      accountType: accountType || 'production',
      accessKey,
      secretKey,
      region,
      description: description || '',
      verified,
      isPrimary: isFirst,
    });

    return NextResponse.json({
      success: true,
      message: verified ? 'AWS account connected and verified!' : 'Account saved but credentials could not be verified.',
      verified,
      account: { ...account.toObject(), accessKey: undefined, secretKey: undefined },
    }, { status: 201 });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

// DELETE - remove account
export async function DELETE(request: Request) {
  try {
    await dbConnect();
    const user = verifyToken(request);
    if (!user) return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });

    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    if (!id) return NextResponse.json({ success: false, error: 'Account ID required' }, { status: 400 });

    await AWSAccount.findOneAndUpdate(
      { _id: id, userId: user.userId },
      { isActive: false }
    );

    return NextResponse.json({ success: true, message: 'Account removed' }, { status: 200 });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
