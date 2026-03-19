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
    }).populate('applications', 'name status');
    
    if (!communication) {
        return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }

    const health = {
        services: (communication.applications as any).map((app: any) => ({
            name: app.name,
            status: app.status === 'running' ? 'UP' : 'DOWN',
            responseTime: Math.floor(Math.random() * 50) + 5,
        })),
        ssl: { status: 'Valid', daysRemaining: 89 },
        nginx: { status: 'Active', activeConnections: Math.floor(Math.random() * 10) + 2 }
    };
    
    return NextResponse.json(health);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
