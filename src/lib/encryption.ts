import crypto from 'crypto';

const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

const getEncryptionKey = () => {
  const key = process.env.ENCRYPTION_KEY;
  
  if (!key) {
    throw new Error('ENCRYPTION_KEY environment variable is not set');
  }
  
  if (key.length !== 64) {
    throw new Error('ENCRYPTION_KEY must be 64 hex characters (32 bytes)');
  }
  
  return Buffer.from(key, 'hex');
};

export function encrypt(text: string): string {
  if (!text) return text;
  
  try {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, getEncryptionKey(), iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    return iv.toString('hex') + ':' + encrypted;
  } catch (error: any) {
    console.error('Encryption error:', error.message);
    throw new Error('Failed to encrypt data');
  }
}

export function decrypt(text: string): string {
  if (!text) return text;
  
  try {
    const parts = text.split(':');
    
    if (parts.length !== 2) {
      throw new Error('Invalid encrypted data format');
    }
    
    const iv = Buffer.from(parts[0], 'hex');
    const encryptedText = Buffer.from(parts[1], 'hex');
    
    const decipher = crypto.createDecipheriv(ALGORITHM, getEncryptionKey(), iv);
    
    let decrypted = decipher.update(encryptedText as any, undefined, 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error: any) {
    console.error('Decryption error:', error.message);
    throw new Error('Failed to decrypt data');
  }
}

export function isEncrypted(text: string): boolean {
  if (!text) return false;
  
  const parts = text.split(':');
  if (parts.length !== 2) return false;
  
  const hexRegex = /^[0-9a-f]+$/i;
  return hexRegex.test(parts[0]) && hexRegex.test(parts[1]) && parts[0].length === 32;
}
