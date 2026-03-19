import { NextRequest } from 'next/server';
import { handleDeployment } from '@/lib/deployment-controller';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ resourceType: string }> }
) {
  const { resourceType } = await params;
  return handleDeployment(resourceType, request);
}
