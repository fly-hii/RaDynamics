import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import dbConnect from '@/lib/db';
import User from '@/models/User';
import OTP from '@/models/OTP';
import { sendOTPEmail } from '@/lib/email';

export async function POST(request: Request) {
  try {
    await dbConnect();
    const { name, email, password } = await request.json();

    if (!name || !email || !password) {
      return NextResponse.json({ success: false, error: 'All fields are required' }, { status: 400 });
    }

    if (password.length < 8) {
      return NextResponse.json({ success: false, error: 'Password must be at least 8 characters' }, { status: 400 });
    }

    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing && existing.emailVerified) {
      return NextResponse.json({ success: false, error: 'Account already exists with this email' }, { status: 409 });
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    if (existing) {
      existing.name = name;
      existing.password = hashedPassword;
      await existing.save();
    } else {
      await User.create({
        name,
        email: email.toLowerCase(),
        password: hashedPassword,
        emailVerified: false,
      });
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    await OTP.deleteMany({ email: email.toLowerCase(), type: 'signup' });
    await OTP.create({
      email: email.toLowerCase(),
      otp,
      type: 'signup',
      expiresAt: new Date(Date.now() + 15 * 60 * 1000),
    });

    console.log(`📧 SIGNUP OTP for ${email}: ${otp}`);
    await sendOTPEmail(email, otp, 'signup');

    return NextResponse.json({
      success: true,
      message: 'OTP sent to your email. Please verify to complete signup.',
      email,
    }, { status: 200 });

  } catch (error: any) {
    console.error('Signup error:', error);
    return NextResponse.json({ success: false, error: 'Signup failed', details: error.message }, { status: 500 });
  }
}
