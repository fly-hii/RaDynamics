import simpleGit from 'simple-git';
import fs from 'fs/promises';
import path from 'path';

class GitHubService {
  private tempDir: string;

  constructor() {
    this.tempDir = process.env.GITHUB_TEMP_DIR || '/tmp/raydynamics-repos';
  }

  async ensureTempDir() {
    try {
      await fs.mkdir(this.tempDir, { recursive: true });
    } catch (error) {
      console.error('Error creating temp directory:', error);
    }
  }

  async cloneRepository(repoUrl: string, branch: string = 'main', appId: string, githubToken: string | null = null) {
    await this.ensureTempDir();
    
    const repoPath = path.join(this.tempDir, appId);
    
    try {
      // Remove existing directory if it exists
      await fs.rm(repoPath, { recursive: true, force: true });
      
      console.log(`🔄 Starting optimized clone: ${repoUrl} (branch: ${branch})`);
      
      let cloneUrl = repoUrl;
      if (githubToken && repoUrl.includes('github.com')) {
        cloneUrl = repoUrl.replace('https://github.com/', `https://${githubToken}@github.com/`);
      }
      
      const git = simpleGit();
      
      console.log('🚀 Starting git clone...');
      
      await git.clone(cloneUrl, repoPath, [
        '--branch', branch, 
        '--single-branch',
        '--depth', '1',
        '--no-tags'
      ]);
      
      console.log(`✅ Repository cloned successfully to ${repoPath}`);
      return repoPath;
    } catch (error: any) {
      console.error('❌ Clone failed:', error);
      throw new Error(`Failed to clone repository: ${error.message}`);
    }
  }

  async detectAppType(repoPath: string) {
    try {
      const files = await fs.readdir(repoPath);
      
      if (files.includes('package.json')) {
        const packageJson = JSON.parse(
          await fs.readFile(path.join(repoPath, 'package.json'), 'utf-8')
        );
        
        if (packageJson.dependencies?.next || files.includes('next.config.js') || files.includes('next.config.mjs')) {
          return 'nextjs';
        }
        
        if (packageJson.dependencies?.react && (files.includes('src') || files.includes('public'))) {
          return 'react';
        }
        
        return 'nodejs';
      }
      
      if (files.includes('requirements.txt') || files.includes('app.py') || files.includes('main.py')) {
        return 'python';
      }
      
      if (files.includes('index.html')) {
        return 'static';
      }
      
      return 'unknown';
    } catch (error) {
      console.error('Error detecting app type:', error);
      return 'unknown';
    }
  }

  async cleanupRepo(appId: string) {
    const repoPath = path.join(this.tempDir, appId);
    try {
      await fs.rm(repoPath, { recursive: true, force: true });
      console.log(`Cleaned up repository: ${repoPath}`);
    } catch (error) {
      console.error('Error cleaning up repository:', error);
    }
  }
}

const githubService = new GitHubService();
export default githubService;
