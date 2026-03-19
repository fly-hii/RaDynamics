import mongoose from 'mongoose';

const applicationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  deploymentMethod: {
    type: String,
    enum: ['github', 'docker'],
    required: true
  },
  github: {
    repoUrl: String,
    branch: { type: String, default: 'main' },
    buildCommand: String,
    startCommand: String,
    appType: {
      type: String,
      enum: ['nodejs', 'react', 'nextjs', 'python', 'static', 'auto']
    },
    token: String,
    isPrivate: { type: Boolean, default: false }
  },
  docker: {
    image: String,
    registry: { type: String, default: 'dockerhub' },
    tag: { type: String, default: 'latest' }
  },
  runtime: {
    port: { type: Number, default: 3000 },
    cpu: { type: String, default: '512' },
    memory: { type: String, default: '1024' },
    environmentVariables: {
      type: Map,
      of: String,
      default: {}
    }
  },
  deploymentTarget: {
    type: String,
    enum: ['ecs', 'ec2'],
    default: 'ecs'
  },
  ec2: {
    instanceId: String,
    publicIp: String,
    privateIp: String
  },
  aws: {
    accountId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AWSAccount',
      required: true
    },
    region: { type: String, default: 'us-east-1' },
    ecrRepository: String,
    ecrImageUri: String,
    ecsCluster: String,
    ecsService: String,
    taskDefinition: String,
    taskDefinitionArn: String,
    loadBalancerArn: String,
    loadBalancerDns: String,
    targetGroupArn: String,
    securityGroupId: String
  },
  status: {
    type: String,
    enum: ['pending', 'cloning', 'building', 'pushing', 'deploying', 'running', 'stopped', 'failed', 'error'],
    default: 'pending'
  },
  url: String,
  directUrl: String,
  buildLogs: [String],
  deploymentLogs: [String],
  errorMessage: String,
  lastDeployedAt: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, {
  timestamps: true
});

const Application = mongoose.models.Application || mongoose.model('Application', applicationSchema);
export default Application;
