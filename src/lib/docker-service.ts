import { exec } from 'child_process';
import util from 'util';
import fs from 'fs/promises';
import path from 'path';

const execPromise = util.promisify(exec);

class DockerService {
  async generateDockerfile(appType: string, repoPath: string, startCommand: string, port: number) {
    const dockerfiles: Record<string, string> = {
      nodejs: `FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE ${port}
CMD ${startCommand}`,

      react: `FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]`,

      nextjs: `FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN npm run build
EXPOSE ${port}
CMD ["npm", "start"]`,

      python: `FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE ${port}
CMD ${startCommand}`,

      static: `FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]`
    };

    const dockerfile = dockerfiles[appType] || dockerfiles.nodejs;
    const dockerfilePath = path.join(repoPath, 'Dockerfile');
    
    await fs.writeFile(dockerfilePath, dockerfile);
    console.log(`Generated Dockerfile for ${appType}`);
    
    return dockerfilePath;
  }

  async buildImage(repoPath: string, imageName: string, tag: string = 'latest') {
    try {
      console.log(`Building Docker image: ${imageName}:${tag}`);
      const { stdout, stderr } = await execPromise(
        `docker build -t ${imageName}:${tag} .`,
        { cwd: repoPath, maxBuffer: 10 * 1024 * 1024 }
      );
      return { success: true, output: stdout };
    } catch (error: any) {
      console.error('Error building Docker image:', error);
      throw new Error(`Docker build failed: ${error.message}`);
    }
  }

  async tagImage(sourceImage: string, targetImage: string) {
    try {
      await execPromise(`docker tag ${sourceImage} ${targetImage}`);
      return true;
    } catch (error: any) {
      throw new Error(`Failed to tag image: ${error.message}`);
    }
  }

  async pushImage(imageName: string) {
    try {
      const { stdout } = await execPromise(`docker push ${imageName}`);
      return { success: true, output: stdout };
    } catch (error: any) {
      throw new Error(`Docker push failed: ${error.message}`);
    }
  }
}

const dockerService = new DockerService();
export default dockerService;
