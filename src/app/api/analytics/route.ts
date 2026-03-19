import { NextRequest, NextResponse } from 'next/server';
import { getAuthenticatedUser } from '@/lib/auth-utils';
import dbConnect from '@/lib/db';
import Deployment from '@/models/Deployment';
import AWSAccount from '@/models/AWSAccount';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(request);
    
    if (!user) {
      return NextResponse.json({ success: false, error: 'Unauthorized.' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type') || 'overview';
    const userId = user.userId;

    if (type === 'overview') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const [todayCount, totalCount, successCount, failedCount, activeAccounts] = await Promise.all([
        Deployment.countDocuments({ userId, createdAt: { $gte: today } }),
        Deployment.countDocuments({ userId }),
        Deployment.countDocuments({ userId, status: 'completed' }),
        Deployment.countDocuments({ userId, status: 'failed' }),
        AWSAccount.countDocuments({ userId, isActive: true })
      ]);

      const successRate = totalCount > 0 ? Math.round((successCount / totalCount) * 100) : 0;

      return NextResponse.json({
        success: true,
        overview: {
          todayDeployments: todayCount,
          totalDeployments: totalCount,
          successfulDeployments: successCount,
          failedDeployments: failedCount,
          successRate,
          activeAWSAccounts: activeAccounts
        }
      });
    }

    if (type === 'distribution') {
      const deployments = await Deployment.find({ userId, status: 'completed' });
      const stats: Record<string, number> = {};
      
      deployments.forEach(d => {
        const rType = d.resourceType || 'other';
        stats[rType] = (stats[rType] || 0) + 1;
      });

      const distribution = Object.entries(stats).map(([name, value]) => ({
        name,
        value,
        percentage: deployments.length > 0 ? Math.round((value / deployments.length) * 100) : 0
      }));

      return NextResponse.json({ success: true, distribution });
    }

    return NextResponse.json({ success: false, error: 'Invalid analytics type.' }, { status: 400 });

  } catch (error: any) {
    console.error('Analytics API error:', error);
    return NextResponse.json({ success: false, error: 'Internal server error.' }, { status: 500 });
  }
}
