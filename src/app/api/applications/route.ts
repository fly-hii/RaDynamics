import { NextRequest, NextResponse } from "next/server";
import { getAuthenticatedUser } from "@/lib/auth-utils";
import dbConnect from "@/lib/db";
import Application from "@/models/Application";
import AWSAccount from "@/models/AWSAccount";

export async function GET(req: NextRequest) {
  try {
    await dbConnect();
    const user = await getAuthenticatedUser(req);
    if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

    const apps = await Application.find({ 
      userId: user.userId,
      organizationId: user.organizationId 
    }).sort({ createdAt: -1 });

    return NextResponse.json({ applications: apps });
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
    const { name, deploymentMethod, deploymentTarget, github, docker, runtime, awsAccountId, ec2InstanceId } = body;

    const awsAccount = await AWSAccount.findOne({ _id: awsAccountId, userId: user.userId });
    if (!awsAccount) return NextResponse.json({ error: "AWS Account not found" }, { status: 404 });

    const application = new Application({
      userId: user.userId,
      organizationId: user.organizationId,
      name,
      deploymentMethod,
      deploymentTarget: deploymentTarget || 'ecs',
      github: deploymentMethod === 'github' ? {
        repoUrl: github.repoUrl,
        branch: github.branch || 'main',
        appType: github.appType || 'auto',
        token: github.token,
        startCommand: github.startCommand,
        buildCommand: github.buildCommand
      } : undefined,
      docker: deploymentMethod === 'docker' ? {
        image: docker.image,
        tag: docker.tag || 'latest',
        registry: 'dockerhub'
      } : undefined,
      runtime,
      aws: {
        accountId: awsAccountId,
        region: awsAccount.region || 'us-east-1'
      },
      status: 'pending'
    });

    if (deploymentTarget === 'ec2' && ec2InstanceId) {
        application.ec2 = { instanceId: ec2InstanceId };
    }

    await application.save();

    // Start background worker or async function here
    // deployApplication(application._id); 

    return NextResponse.json({ success: true, application });
  } catch (error: any) {
    console.error("Application create error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
