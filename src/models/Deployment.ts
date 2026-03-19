import mongoose from 'mongoose';

const deploymentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    index: true
  },
  awsAccountId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'AWSAccount',
    required: true
  },
  resourceType: {
    type: String,
    enum: ['ec2', 's3', 'iam', 'rds', 'lambda', 'alb', 'api-gateway', 'ecs', 'ecr', 'cloudfront', 'autoscaling', 'security-group', 'vpc', 'subnet'],
    required: true
  },
  resourceName: {
    type: String
  },
  config: {
    type: mongoose.Schema.Types.Mixed
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'destroying', 'destroyed', 'destroy_failed', 'deleted_externally', 'deleted'],
    default: 'pending'
  },
  terraformOutput: {
    type: String
  },
  errorLog: {
    type: String
  },
  workspaceId: {
    type: String
  },
  deletedBy: {
    type: String,
    enum: ['ui', 'aws_console', 'unknown'],
    default: null
  },
  deletedAt: {
    type: Date,
    default: null
  },
  lastSyncedAt: {
    type: Date,
    default: null
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

deploymentSchema.pre('save', async function(this: any) {
  this.updatedAt = new Date();
});

const Deployment = mongoose.models.Deployment || mongoose.model('Deployment', deploymentSchema);
export default Deployment;
