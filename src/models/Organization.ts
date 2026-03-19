import mongoose from 'mongoose';

const organizationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 100
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: /^[a-z0-9-]+$/
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  members: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    role: {
      type: String,
      enum: ['owner', 'admin', 'member', 'read_only'],
      default: 'member'
    },
    addedAt: {
      type: Date,
      default: Date.now
    },
    addedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  }],
  billing: {
    stripeCustomerId: String,
    stripeSubscriptionId: String,
    paymentMethodId: String,
    lastPaymentDate: Date,
    nextPaymentDate: Date
  },
  subscription: {
    plan: {
      type: String,
      enum: ['free', 'starter', 'professional', 'enterprise'],
      default: 'free'
    },
    status: {
      type: String,
      enum: ['active', 'suspended', 'cancelled', 'trial'],
      default: 'trial'
    },
    startDate: {
      type: Date,
      default: Date.now
    },
    expiresAt: {
      type: Date
    },
    trialEndsAt: {
      type: Date,
      default: () => new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
    }
  },
  limits: {
    maxAWSAccounts: { type: Number, default: 3 },
    maxDeployments: { type: Number, default: 50 },
    maxUsers: { type: Number, default: 5 },
    maxDeploymentsPerMonth: { type: Number, default: 100 }
  },
  usage: {
    awsAccounts: { type: Number, default: 0 },
    deployments: { type: Number, default: 0 },
    users: { type: Number, default: 1 },
    deploymentsThisMonth: { type: Number, default: 0 },
    lastResetDate: { type: Date, default: Date.now }
  },
  settings: {
    allowMemberInvites: { type: Boolean, default: false },
    requireMFA: { type: Boolean, default: false },
    allowedDomains: [{ type: String }],
    ipWhitelist: [{ type: String }]
  },
  isActive: {
    type: Boolean,
    default: true
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

organizationSchema.index({ 'members.userId': 1 });

organizationSchema.pre('save', async function(this: any) {
  this.updatedAt = new Date();
});

organizationSchema.statics.createDefaultOrganization = async function(userId: any, userName: any, userEmail: string) {
  const slug = userEmail.split('@')[0].toLowerCase().replace(/[^a-z0-9]/g, '-');
  
  const organization = new this({
    name: `${userName || userEmail.split('@')[0]}'s Organization`,
    slug: `${slug}-${Date.now()}`,
    ownerId: userId,
    members: [],
    usage: {
      users: 1,
      awsAccounts: 0,
      deployments: 0,
      deploymentsThisMonth: 0,
      lastResetDate: new Date()
    }
  });
  
  return await organization.save();
};

const Organization = mongoose.models.Organization || mongoose.model<any, any>('Organization', organizationSchema);
export default Organization;
