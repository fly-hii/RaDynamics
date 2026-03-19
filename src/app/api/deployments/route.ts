import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import dbConnect from '@/lib/db';
import Deployment from '@/models/Deployment';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized session.' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '10');
    const status = searchParams.get('status');

    const query: any = { userId: user.userId };
    if (status) query.status = status;

    const deployments = await Deployment.find(query)
      .sort({ createdAt: -1 })
      .limit(limit);

    return NextResponse.json({ 
      success: true, 
      deployments 
    }, { status: 200 });

  } catch (error: any) {
    console.error('Fetch deployments API error:', error);
    return NextResponse.json({ success: false, error: 'Internal server error.', details: error.message }, { status: 500 });
  }
}
