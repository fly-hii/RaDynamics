import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import Application from "@/models/Application";

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const app = await Application.findOne({ 
      _id: params.id,
      userId: user.userId 
    });

    if (!app) return NextResponse.json({ error: "Application not found" }, { status: 404 });

    // Redeploy logic usually marks it as pending and kicks off a worker
    app.status = 'pending';
    app.deploymentLogs = [`[${new Date().toISOString()}] Redeployment initiated by user Request.`];
    await app.save();

    return NextResponse.json({ success: true, message: "Redeployment started", application: app });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
