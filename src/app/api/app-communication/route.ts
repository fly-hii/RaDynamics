import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import AppCommunication from "@/models/AppCommunication";
import Application from "@/models/Application";

export async function GET(req: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const communications = await AppCommunication.find({ 
      userId: user.userId,
      organizationId: user.organizationId 
    })
    .populate('applications', 'name url status deploymentTarget')
    .sort({ createdAt: -1 });
    
    return NextResponse.json(communications);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const body = await req.json();
    const { 
      applications: appIds, 
      communicationType, 
      nginxConfig 
    } = body;

    if (!appIds || appIds.length < 2) {
      return NextResponse.json({ 
        error: 'At least 2 applications are required for communication setup' 
      }, { status: 400 });
    }

    // Verify all applications exist and belong to user
    const applications = await Application.find({
      _id: { $in: appIds },
      userId: user.userId
    });

    if (applications.length !== appIds.length) {
      return NextResponse.json({ 
        error: 'One or more applications not found' 
      }, { status: 400 });
    }

    const communication = new AppCommunication({
      userId: user.userId,
      organizationId: user.organizationId,
      applications: appIds,
      communicationType: communicationType || 'nginx',
      nginxConfig: {
        loadBalancing: nginxConfig?.loadBalancing ?? true,
        sslTermination: nginxConfig?.sslTermination ?? true,
        rateLimiting: nginxConfig?.rateLimiting || { enabled: true, rate: '100r/s' },
        healthChecks: nginxConfig?.healthChecks ?? true,
        caching: nginxConfig?.caching || { enabled: true, duration: '5m' },
        compression: nginxConfig?.compression ?? true
      },
      status: 'active' // For now default to active until worker logic is full
    });

    await communication.save();
    
    const populated = await AppCommunication.findById(communication._id)
      .populate('applications', 'name url status deploymentTarget');

    return NextResponse.json(populated, { status: 201 });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
