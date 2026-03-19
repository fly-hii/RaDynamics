import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import dbConnect from '@/lib/db';
import User from '@/models/User';
import OTP from '@/models/OTP';
import Organization from '@/models/Organization';

export async function POST(request: Request) {
  try {
    await dbConnect();
    const { email, otp, tempToken } = await request.json();

    if (!email || !otp || !tempToken) {
      return NextResponse.json({ success: false, error: 'Email, OTP and session token are required' }, { status: 400 });
    }

    // Verify temp token
    let decodedTemp: any;
    try {
      decodedTemp = jwt.verify(tempToken, process.env.JWT_SECRET || 'secret');
      if (decodedTemp.type !== 'password_verified' || decodedTemp.step !== 'pending_otp') {
        throw new Error('Invalid token');
      }
    } catch (error) {
      return NextResponse.json({ success: false, error: 'Session expired. Please login again.' }, { status: 401 });
    }

    // Find and verify OTP
    const otpRecord = await OTP.findOne({
      email: { $regex: new RegExp(`^${email}$`, 'i') },
      otp,
      type: 'login',
      verified: false,
      expiresAt: { $gt: new Date() }
    });

    if (!otpRecord) {
      return NextResponse.json({ success: false, error: 'Invalid or expired OTP' }, { status: 401 });
    }

    // Find user to associate with token
    const user = await User.findOne({ email: { $regex: new RegExp(`^${email}$`, 'i') } });
    if (!user) {
      return NextResponse.json({ success: false, error: 'User not found' }, { status: 404 });
    }

    // Mark OTP as verified
    otpRecord.verified = true;
    await otpRecord.save();

    // Mark user as verified if not already (safeguard)
    if (!user.emailVerified) {
       user.emailVerified = true;
       await user.save();
    }

    // Get user's organization
    const organization = await Organization.findById(user.defaultOrganizationId);

    // Final JWT
    const token = jwt.sign(
      { 
        userId: user._id, 
        email: user.email,
        organizationId: user.defaultOrganizationId
      },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );

    return NextResponse.json({
      success: true,
      message: 'Login successful!',
      token,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        profilePhoto: user.profilePhoto,
        organizationId: user.defaultOrganizationId
      },
      organization: organization ? {
        id: organization._id,
        name: organization.name,
        plan: organization.subscription.plan
      } : null
    }, { status: 200 });

  } catch (error: any) {
    console.error('OTP verification error:', error);
    return NextResponse.json({ success: false, error: 'Verification failed', details: error.message }, { status: 500 });
  }
}
