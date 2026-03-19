import mongoose from 'mongoose';

const appCommunicationSchema = new mongoose.Schema({
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
  
  // Applications involved in communication
  applications: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Application',
    required: true
  }],
  
  // Communication Type
  communicationType: {
    type: String,
    enum: ['nginx', 'direct', 'service-mesh'],
    default: 'nginx'
  },
  
  // NGINX Configuration for Communication
  nginxConfig: {
    loadBalancing: {
      type: Boolean,
      default: true
    },
    method: {
      type: String,
      enum: ['round-robin', 'least-conn', 'ip-hash', 'weighted'],
      default: 'least-conn'
    },
    sslTermination: {
      type: Boolean,
      default: true
    },
    rateLimiting: {
      enabled: { type: Boolean, default: true },
      rate: { type: String, default: '100r/s' },
      burst: { type: Number, default: 20 }
    },
    healthChecks: {
      type: Boolean,
      default: true
    },
    healthCheckPath: {
      type: String,
      default: '/health'
    },
    caching: {
      enabled: { type: Boolean, default: true },
      duration: { type: String, default: '5m' },
      methods: [{ type: String, default: 'GET' }]
    },
    compression: {
      type: Boolean,
      default: true
    },
    websocketSupport: {
      type: Boolean,
      default: false
    },
    customHeaders: [{
      name: String,
      value: String
    }]
  },
  
  // Communication Status
  status: {
    type: String,
    enum: ['configuring', 'active', 'inactive', 'failed', 'maintenance'],
    default: 'configuring'
  },
  
  // Configuration Details
  upstreamName: String,
  nginxConfigPath: String,
  
  // Metrics and Monitoring
  metrics: {
    requestsPerSecond: { type: Number, default: 0 },
    averageResponseTime: { type: Number, default: 0 },
    errorRate: { type: Number, default: 0 },
    activeConnections: { type: Number, default: 0 },
    cacheHitRatio: { type: Number, default: 0 },
    dataTransferred: { type: Number, default: 0 }, // in MB
    lastMetricsUpdate: Date
  },
  
  // Error Handling
  errorMessage: String,
  lastError: Date,
  
  // Timestamps
  configuredAt: Date,
  lastTestedAt: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for communication name
appCommunicationSchema.virtual('name').get(function(this: any) {
  if (this.applications && this.applications.length > 0) {
    return this.applications.map((app: any) => 
      typeof app === 'object' ? app.name : app
    ).join(' ↔ ');
  }
  return 'Unknown Communication';
});

const AppCommunication = mongoose.models.AppCommunication || mongoose.model('AppCommunication', appCommunicationSchema);
export default AppCommunication;
