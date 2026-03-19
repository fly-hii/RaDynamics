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

    const logs = {
      application: [
        { timestamp: new Date(), level: 'INFO', message: 'API Gateway received request on /v1/products', source: 'Gateway' },
        { timestamp: new Date(Date.now() - 5000), level: 'DEBUG', message: 'Routing to upstream group: app_main', source: 'NGINX' },
        { timestamp: new Date(Date.now() - 15000), level: 'INFO', message: 'Upstream health check: all nodes healthy', source: 'Monitor' }
      ],
      system: [
        { timestamp: new Date(), level: 'INFO', message: 'NGINX proxy server running', source: 'System' }
      ]
    };
    
    return NextResponse.json(logs);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
