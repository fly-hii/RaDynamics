import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import AppCommunication from "@/models/AppCommunication";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const communication = await AppCommunication.findOne({
      _id: id,
      userId: user.userId
    });
    
    if (!communication) {
        return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }

    const traffic = {
      liveApiHits: Math.floor(Math.random() * 50) + 10,
      recentCalls: [
        { method: 'GET', endpoint: '/api/v1/user', status: 200, time: '12ms' },
        { method: 'POST', endpoint: '/api/v1/order', status: 201, time: '34ms' },
        { method: 'GET', endpoint: '/health', status: 200, time: '4ms' }
      ]
    };
    
    return NextResponse.json(traffic);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
