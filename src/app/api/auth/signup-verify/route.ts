import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import dbConnect from '@/lib/db';
import User from '@/models/User';
import OTP from '@/models/OTP';

export async function POST(request: Request) {
  try {
    await dbConnect();
    const { email, otp } = await request.json();

    if (!email || !otp) {
      return NextResponse.json({ success: false, error: 'Email and OTP are required' }, { status: 400 });
    }

    const otpRecord = await OTP.findOne({
      email: email.toLowerCase(),
      type: 'signup',
      expiresAt: { $gt: new Date() },
    });

    if (!otpRecord) {
      return NextResponse.json({ success: false, error: 'OTP expired or not found. Please resend.' }, { status: 400 });
    }

    if (otpRecord.otp !== otp.trim()) {
      return NextResponse.json({ success: false, error: 'Invalid OTP. Please try again.' }, { status: 400 });
    }

    const user = await User.findOneAndUpdate(
      { email: email.toLowerCase() },
      { emailVerified: true },
      { new: true }
    );

    if (!user) {
      return NextResponse.json({ success: false, error: 'User not found' }, { status: 404 });
    }

    await OTP.deleteMany({ email: email.toLowerCase(), type: 'signup' });

    const token = jwt.sign(
      { userId: user._id, email: user.email, name: user.name },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '7d' }
    );

    return NextResponse.json({
      success: true,
      message: 'Account verified successfully!',
      token,
      user: { id: user._id, name: user.name, email: user.email },
    }, { status: 200 });

  } catch (error: any) {
    console.error('Signup verify error:', error);
    return NextResponse.json({ success: false, error: 'Verification failed', details: error.message }, { status: 500 });
  }
}
