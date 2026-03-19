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
    }).populate('applications', 'name url status deploymentTarget');
    
    if (!communication) {
      return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }
    
    return NextResponse.json(communication);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const body = await req.json();
    const communication = await AppCommunication.findOne({
      _id: id,
      userId: user.userId
    });
    
    if (!communication) {
      return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }

    if (body.nginxConfig) {
      communication.nginxConfig = { ...communication.nginxConfig, ...body.nginxConfig };
    }
    if (body.status) {
      communication.status = body.status;
    }

    await communication.save();
    return NextResponse.json(communication);
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

    const communication = await AppCommunication.findOne({
      _id: id,
      userId: user.userId
    });
    
    if (!communication) {
      return NextResponse.json({ error: 'Communication not found' }, { status: 404 });
    }

    await communication.deleteOne();
    return NextResponse.json({ success: true, message: 'Communication deleted successfully' });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
