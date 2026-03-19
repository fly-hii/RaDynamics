import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import Application from "@/models/Application";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const app = await Application.findOne({ 
      _id: id,
      userId: user.userId 
    });

    if (!app) return NextResponse.json({ error: "Application not found" }, { status: 404 });

    // In a real scenario, we'd call AWS SDK to stop the ECS service/EC2 instance
    // For now, we simulate success
    app.status = 'stopped';
    await app.save();

    return NextResponse.json({ success: true, message: "Application stopped", application: app });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
