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

    const errors = {
      alerts: [
        { type: 'latency', severity: 'medium', message: 'API Gateway latency exceeds 200ms threshold' }
      ],
      stats: {
        failedApiCalls: 0,
        timeoutErrors: 0,
        connectionRefused: 0
      }
    };
    
    return NextResponse.json(errors);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
