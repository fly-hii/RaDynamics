import nodemailer from 'nodemailer';

// Email service for sending OTPs
export const sendOTPEmail = async (email: string, otp: string, type: 'login' | 'signup' | 'reset') => {
  // Always log to console for development
  console.log('\n📧 ========== EMAIL SERVICE ==========');
  console.log(`To: ${email}`);
  console.log(`Type: ${type === 'login' ? 'Login OTP' : type === 'signup' ? 'Signup Verification OTP' : 'Password Reset OTP'}`);
  console.log(`OTP Code: ${otp}`);
  console.log('=====================================\n');

  try {
    const user = process.env.EMAIL_USER;
    const pass = process.env.EMAIL_PASSWORD;

    if (!user || !pass) {
      console.warn('⚠️ No email credentials configured. OTP is shown in console only.');
      return true;
    }

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user,
        pass
      }
    });

    const subjectMap = {
      'login': '🔐 Your RayDynamics Login OTP',
      'signup': '✅ Verify Your RayDynamics Account',
      'reset': '🔑 RayDynamics Password Reset OTP'
    };

    const typeTitle = type === 'login' ? 'Login Verification' : type === 'signup' ? 'Account Verification' : 'Password Reset';
    const actionLabel = type === 'login' ? 'logging into' : type === 'signup' ? 'verifying your account on' : 'resetting your password on';

    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>RayDynamics Verification</title>
        <style>
          body { font-family: sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08); }
          .header { background: #0062ff; color: white; padding: 40px 30px; text-align: center; }
          .header h1 { margin: 0; font-size: 28px; }
          .content { padding: 40px 30px; }
          .otp-box { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 10px; padding: 30px 20px; text-align: center; margin: 30px 0; }
          .otp-code { font-size: 42px; font-weight: 800; color: #0062ff; letter-spacing: 10px; font-family: monospace; }
          .footer { text-align: center; margin-top: 40px; color: #64748b; font-size: 14px; padding-top: 20px; border-top: 1px solid #e2e8f0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>RayDynamics</h1>
            <p>${typeTitle}</p>
          </div>
          <div class="content">
            <h2>Hello!</h2>
            <p>Your OTP code for ${actionLabel} <strong>RayDynamics</strong> is:</p>
            <div class="otp-box">
              <div class="otp-code">${otp}</div>
              <p>⏰ Valid for 15 minutes</p>
            </div>
            <p>If you didn't request this code, please ignore this email.</p>
            <p>Thank you,<br>The RayDynamics Team</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} RayDynamics. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const mailOptions = {
      from: `RayDynamics <${user}>`,
      to: email,
      subject: subjectMap[type] || 'RayDynamics Verification Code',
      html: htmlContent,
      text: `Your RayDynamics OTP is: ${otp}`
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ Email sent successfully to ${email}`);
    return true;
  } catch (error: any) {
    console.error('❌ Failed to send email:', error.message);
    return false;
  }
};
