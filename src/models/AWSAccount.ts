import mongoose from 'mongoose';
import { encrypt, decrypt, isEncrypted } from '@/lib/encryption';

const awsAccountSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true,
    index: true
  },
  organizationName: {
    type: String,
    required: true,
    trim: true
  },
  accountName: {
    type: String,
    required: true,
    trim: true
  },
  accountId: {
    type: String,
    trim: true
  },
  accountType: {
    type: String,
    enum: ['production', 'staging', 'development', 'testing', 'sandbox'],
    default: 'production'
  },
  accessKey: {
    type: String,
    required: true
  },
  secretKey: {
    type: String,
    required: true
  },
  region: {
    type: String,
    required: true,
    default: 'us-east-1'
  },
  description: {
    type: String,
    trim: true
  },
  tags: [{
    type: String,
    trim: true
  }],
  verified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isPrimary: {
    type: Boolean,
    default: false
  },
  lastVerified: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

awsAccountSchema.index({ organizationId: 1, accountName: 1 });
awsAccountSchema.index({ userId: 1, organizationName: 1 });
awsAccountSchema.index({ userId: 1, accountName: 1 });
awsAccountSchema.index({ userId: 1, isPrimary: 1 });

awsAccountSchema.pre('save', async function(this: any) {
  this.updatedAt = new Date();
  
  if (this.accessKey && !isEncrypted(this.accessKey)) {
    this.accessKey = encrypt(this.accessKey);
  }
  
  if (this.secretKey && !isEncrypted(this.secretKey)) {
    this.secretKey = encrypt(this.secretKey);
  }
});

awsAccountSchema.methods.getDecryptedCredentials = function() {
  try {
    return {
      accessKeyId: decrypt(this.accessKey),
      secretAccessKey: decrypt(this.secretKey),
      region: this.region
    };
  } catch (error: any) {
    console.error('Failed to decrypt credentials:', error.message);
    throw new Error('Failed to retrieve AWS credentials');
  }
};

const AWSAccount = mongoose.models.AWSAccount || mongoose.model('AWSAccount', awsAccountSchema);
export default AWSAccount;
