import { 
  ECSClient, 
  CreateClusterCommand, 
  DescribeClustersCommand,
  RegisterTaskDefinitionCommand,
  CreateServiceCommand,
  UpdateServiceCommand,
  DescribeServicesCommand
} from '@aws-sdk/client-ecs';
import { 
  ECRClient, 
  CreateRepositoryCommand, 
  DescribeRepositoriesCommand, 
  GetAuthorizationTokenCommand 
} from '@aws-sdk/client-ecr';
import { exec } from 'child_process';
import util from 'util';

const execPromise = util.promisify(exec);

export class AwsAppService {
  private ecsClient: ECSClient;
  private ecrClient: ECRClient;

  constructor(credentials: any, region: string = 'us-east-1') {
    const config = {
      region,
      credentials: {
        accessKeyId: credentials.accessKeyId,
        secretAccessKey: credentials.secretAccessKey
      }
    };
    this.ecsClient = new ECSClient(config);
    this.ecrClient = new ECRClient(config);
  }

  // ECR Methods
  async ensureRepository(repositoryName: string) {
    try {
      const describe = new DescribeRepositoriesCommand({ repositoryNames: [repositoryName] });
      const existing = await this.ecrClient.send(describe);
      return existing.repositories?.[0];
    } catch (error: any) {
      if (error.name === 'RepositoryNotFoundException') {
        const create = new CreateRepositoryCommand({ repositoryName });
        const resp = await this.ecrClient.send(create);
        return resp.repository;
      }
      throw error;
    }
  }

  async loginToECR() {
    const auth = await this.ecrClient.send(new GetAuthorizationTokenCommand({}));
    const authData = auth.authorizationData?.[0];
    if (!authData || !authData.authorizationToken || !authData.proxyEndpoint) {
      throw new Error('Failed to get ECR auth token');
    }
    const token = Buffer.from(authData.authorizationToken, 'base64').toString('utf-8');
    const [username, password] = token.split(':');
    const cmd = `docker login -u ${username} -p ${password} ${authData.proxyEndpoint}`;
    await execPromise(cmd);
    return authData.proxyEndpoint;
  }

  // ECS Methods
  async ensureCluster(clusterName: string) {
    try {
      const describe = new DescribeClustersCommand({ clusters: [clusterName] });
      const resp = await this.ecsClient.send(describe);
      if (resp.clusters?.length && resp.clusters[0].status === 'ACTIVE') {
        return resp.clusters[0];
      }
      const create = new CreateClusterCommand({ clusterName });
      const createResp = await this.ecsClient.send(create);
      return createResp.cluster;
    } catch (error: any) {
      throw new Error(`Failed to ensure ECS cluster: ${error.message}`);
    }
  }

  async deployToECS(config: any) {
    // Register Task Definition
    const taskDef = await this.ecsClient.send(new RegisterTaskDefinitionCommand({
      family: config.name,
      networkMode: 'awsvpc',
      requiresCompatibilities: ['FARGATE'],
      cpu: config.cpu || '256',
      memory: config.memory || '512',
      containerDefinitions: [{
        name: config.name,
        image: config.image,
        portMappings: [{ containerPort: config.port, protocol: 'tcp' }],
        environment: Object.entries(config.env || {}).map(([name, value]) => ({ name, value: String(value) })),
        essential: true
      }],
      executionRoleArn: config.executionRoleArn
    }));

    // Check if service exists
    const services = await this.ecsClient.send(new DescribeServicesCommand({
      cluster: config.cluster,
      services: [config.name]
    }));

    if (services.services?.length && services.services[0].status !== 'INACTIVE') {
      // Update
      await this.ecsClient.send(new UpdateServiceCommand({
        cluster: config.cluster,
        service: config.name,
        taskDefinition: taskDef.taskDefinition?.taskDefinitionArn,
        forceNewDeployment: true
      }));
    } else {
      // Create
      await this.ecsClient.send(new CreateServiceCommand({
        cluster: config.cluster,
        serviceName: config.name,
        taskDefinition: taskDef.taskDefinition?.taskDefinitionArn,
        desiredCount: 1,
        launchType: 'FARGATE',
        networkConfiguration: {
          awsvpcConfiguration: {
            subnets: config.subnets,
            securityGroups: config.securityGroups,
            assignPublicIp: 'ENABLED'
          }
        }
      }));
    }
  }
}
