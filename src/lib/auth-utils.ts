import { NextRequest } from 'next/server';
import jwt from 'jsonwebtoken';

export interface UserPayload {
  userId: string;
  email: string;
  organizationId?: string;
  name?: string;
}

export const getAuthenticatedUser = async (request: NextRequest): Promise<UserPayload | null> => {
  const authHeader = request.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret') as UserPayload;
    return decoded;
  } catch (error) {
    return null;
  }
};

// Synchronous helper for standard Request objects
export const verifyToken = (request: Request): UserPayload | null => {
  const authHeader = request.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.split(' ')[1];
  try {
    return jwt.verify(token, process.env.JWT_SECRET || 'secret') as UserPayload;
  } catch {
    return null;
  }
};
