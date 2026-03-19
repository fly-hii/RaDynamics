import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import dbConnect from '@/lib/db';
import User from '@/models/User';
import OTP from '@/models/OTP';
import { sendOTPEmail } from '@/lib/email';

export async function POST(request: Request) {
  try {
    await dbConnect();
    const { email, password } = await request.json();

    if (!email || !password) {
      return NextResponse.json({ success: false, error: 'Email and password are required' }, { status: 400 });
    }

    // Find user (case insensitive)
    const user = await User.findOne({ 
      email: { $regex: new RegExp(`^${email}$`, 'i') } 
    });
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Invalid email or password' }, { status: 401 });
    }

    // Check if user is verified
    if (!user.emailVerified) {
      return NextResponse.json({ 
        success: false, 
        error: 'Please verify your email first by completing signup',
        needsVerification: true
      }, { status: 401 });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return NextResponse.json({ success: false, error: 'Invalid email or password' }, { status: 401 });
    }

    // Generate logic OTP (MANDATORY)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Delete any existing login OTPs
    await OTP.deleteMany({ 
      email: email.toLowerCase(), 
      type: 'login' 
    });

    // Save new OTP
    await OTP.create({
      email: email.toLowerCase(),
      otp,
      type: 'login',
      expiresAt: new Date(Date.now() + 10 * 60 * 1000)
    });

    // Send email here.
    console.log(`📧 MANDATORY OTP for ${email}: ${otp}`);
    await sendOTPEmail(email, otp, 'login');

    // Generate temporary token for OTP verification
    const tempToken = jwt.sign(
      { 
        userId: user._id, 
        email: user.email,
        type: 'password_verified',
        step: 'pending_otp'
      },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '10m' }
    );

    return NextResponse.json({
      success: true,
      message: 'Password verified. OTP sent to your email.',
      tempToken,
      email: user.email,
      nextStep: 'verify_otp'
    }, { status: 200 });

  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json({ success: false, error: 'Login failed', details: error.message }, { status: 500 });
  }
}
