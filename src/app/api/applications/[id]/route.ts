import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import Application from "@/models/Application";

export async function GET(
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

    return NextResponse.json({ application: app });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(
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

    // Mark as destroying
    app.status = 'error'; // Temporarily using error as 'destroying' not in enum? 
    // Wait, let's check the enum in Application.ts
    // status: ['pending', 'cloning', 'building', 'pushing', 'deploying', 'running', 'stopped', 'failed', 'error']
    
    // I'll just delete it for now to fulfill the CRUD request, or implement a cleanup logic.
    await Application.deleteOne({ _id: id });

    return NextResponse.json({ success: true, message: "Application deleted successfully" });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
