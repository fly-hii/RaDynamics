import { STSClient, GetCallerIdentityCommand } from "@aws-sdk/client-sts";
import { EC2Client, DescribeVpcsCommand, CreateVpcCommand, ModifyVpcAttributeCommand } from "@aws-sdk/client-ec2";

export interface AWSCredentials {
  accessKeyId: string;
  secretAccessKey: string;
  region: string;
}

export const getSTSClient = (credentials: AWSCredentials) => {
  return new STSClient({
    credentials: {
      accessKeyId: credentials.accessKeyId,
      secretAccessKey: credentials.secretAccessKey,
    },
    region: credentials.region,
  });
};

export const getEC2Client = (credentials: AWSCredentials) => {
  return new EC2Client({
    credentials: {
      accessKeyId: credentials.accessKeyId,
      secretAccessKey: credentials.secretAccessKey,
    },
    region: credentials.region,
  });
};

export const verifyAWSCredentials = async (credentials: AWSCredentials) => {
  const client = getSTSClient(credentials);
  const command = new GetCallerIdentityCommand({});
  try {
    const response = await client.send(command);
    return response.Account;
  } catch (error) {
    throw new Error("Invalid AWS credentials or unauthorized access.");
  }
};

export const listVpcs = async (credentials: AWSCredentials) => {
  const client = getEC2Client(credentials);
  const command = new DescribeVpcsCommand({});
  try {
    const response = await client.send(command);
    return response.Vpcs;
  } catch (error) {
    throw new Error("Failed to fetch VPCs from AWS.");
  }
};
