import { exec, spawn } from 'child_process';
import { promisify } from 'util';
import { writeFile, mkdir, copyFile } from 'fs/promises';
import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

const execAsync = promisify(exec);

const getTerraformExecutable = async () => {
  let terraformPath = process.env.TERRAFORM_PATH;
  
  if (!terraformPath) {
    terraformPath = process.platform === 'win32' ? 'terraform.exe' : 'terraform';
  }
  
  const commonPaths = [
    terraformPath,
    'C:\\ProgramData\\chocolatey\\bin\\terraform.exe',
    'C:\\tools\\terraform\\terraform.exe',
    'C:\\Terraform\\terraform.exe',
    path.join(process.env.USERPROFILE || '', 'terraform.exe'),
  ];
  
  for (const testPath of commonPaths) {
    try {
      await execAsync(`"${testPath}" version`);
      return testPath;
    } catch (error) {
      continue;
    }
  }
  
  throw new Error(`Terraform not found. Please ensure Terraform is installed.`);
};

const WORKSPACE_DIR = process.env.TERRAFORM_WORKSPACE_DIR || path.join(process.cwd(), 'terraform/workspaces');
const TEMPLATE_DIR = path.join(process.cwd(), 'terraform/templates');

// Helper to format object to tfvars
const toTfVars = (obj: any) => {
  let content = '';
  for (const [key, value] of Object.entries(obj)) {
    if (value === null || value === undefined) {
      content += `${key} = null\n`;
    } else if (typeof value === 'string') {
      content += `${key} = "${value}"\n`;
    } else if (typeof value === 'boolean' || typeof value === 'number') {
      content += `${key} = ${value}\n`;
    } else {
      content += `${key} = ${JSON.stringify(value)}\n`;
    }
  }
  return content;
};

export const executeTerraform = async (resourceType: string, config: any, awsCredentials: any, userId = 'system') => {
  const workspaceId = uuidv4();
  const workspacePath = path.join(WORKSPACE_DIR, workspaceId);

  try {
    const terraformExecutable = await getTerraformExecutable();
    await mkdir(workspacePath, { recursive: true });

    let vars: any = {
        aws_region: config.region || awsCredentials.region,
        aws_access_key: awsCredentials.accessKeyId,
        aws_secret_key: awsCredentials.secretAccessKey,
        ...config
    };

    let templateFile = '';
    
    switch (resourceType) {
      case 'vpc':
        templateFile = 'vpc.tf';
        break;
      case 'ec2':
        templateFile = 'ec2.tf';
        vars.instance_name = config.instance_name || 'RayDynamics-EC2';
        break;
      case 's3':
        templateFile = 's3.tf';
        vars.bucket_name = config.bucketName?.toLowerCase();
        break;
      case 'rds':
        templateFile = 'rds.tf';
        vars.identifier = config.resourceName || config.identifier;
        vars.username = config.masterUsername || config.username;
        vars.password = config.masterPassword || config.password;
        break;
      case 'lambda':
        templateFile = 'lambda.tf';
        vars.function_name = config.resourceName || config.function_name;
        break;
      case 'iam':
        templateFile = 'iam.tf';
        vars.username = config.resourceName || config.username;
        break;
      default:
        // Try fallback to generic template name
        templateFile = `${resourceType}.tf`;
    }

    const templatePath = path.join(TEMPLATE_DIR, templateFile);
    if (!fs.existsSync(templatePath)) {
      throw new Error(`Template not found: ${templateFile}. Expected at ${templatePath}`);
    }
    
    await copyFile(templatePath, path.join(workspacePath, 'main.tf'));
    await writeFile(path.join(workspacePath, 'terraform.tfvars'), toTfVars(vars));

    // Init and Apply
    await runTerraformCommand(terraformExecutable, ['init', '-no-color'], { cwd: workspacePath });
    const { stdout, stderr } = await runTerraformCommand(terraformExecutable, ['apply', '-auto-approve', '-no-color'], { cwd: workspacePath });

    return { success: true, stdout, stderr, workspaceId };
  } catch (error: any) {
    console.error('Terraform Execute error:', error);
    return { success: false, error: error.message, workspaceId };
  }
};

export const destroyTerraform = async (workspaceId: string, credentials: { accessKey: string, secretKey: string, region: string }) => {
  try {
    const terraformExecutable = await getTerraformExecutable();
    const workspacePath = path.join(WORKSPACE_DIR, workspaceId);

    if (!fs.existsSync(workspacePath)) {
      throw new Error(`Workspace not found: ${workspaceId}`);
    }

    const { accessKey, secretKey, region } = credentials;
    const env = {
      ...process.env,
      AWS_ACCESS_KEY_ID: accessKey,
      AWS_SECRET_ACCESS_KEY: secretKey,
      AWS_DEFAULT_REGION: region,
    };

    const { stdout, stderr } = await runTerraformCommand(
      terraformExecutable, 
      ['destroy', '-auto-approve', '-no-color'], 
      { cwd: workspacePath, env }
    );

    return { success: true, stdout, stderr };
  } catch (error: any) {
    console.error('Terraform Destroy error:', error);
    return { success: false, error: error.message };
  }
};

async function runTerraformCommand(executable: string, args: string[], options: any): Promise<{stdout: string, stderr: string}> {
  return new Promise((resolve, reject) => {
    const child = spawn(executable, args, {
      ...options,
      shell: true
    });
    
    let stdout = '';
    let stderr = '';
    
    child.stdout.on('data', (data) => stdout += data.toString());
    child.stderr.on('data', (data) => stderr += data.toString());
    
    child.on('close', (code) => {
      if (code === 0) resolve({ stdout, stderr });
      else reject(new Error(`Command failed with code ${code}. Stderr: ${stderr}`));
    });
  });
}
