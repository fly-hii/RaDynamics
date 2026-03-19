import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import AppCommunication from "@/models/AppCommunication";

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const communication = await AppCommunication.findOne({
      _id: params.id,
      userId: user.userId
    });
    
    if (!communication) {
      return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }
    
    // Simulate metrics collection
    const metrics = {
      requestsPerSecond: Math.floor(Math.random() * 100) + 20,
      totalRequests: Math.floor(Math.random() * 20000) + 10000,
      averageResponseTime: Math.floor(Math.random() * 200) + 80,
      errorRate: (Math.random() * 2.5).toFixed(2),
      activeConnections: Math.floor(Math.random() * 100) + 20,
      cacheHitRatio: (Math.random() * 100).toFixed(1),
      dataTransferred: Math.floor(Math.random() * 1000) + 100, // MB
      uptime: '99.9%'
    };
    
    return NextResponse.json({
      communication: communication._id,
      metrics,
      timestamp: new Date()
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
