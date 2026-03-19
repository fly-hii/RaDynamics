/**
 * NGINX Service for inter-app communication
 */
export class NginxService {
    /**
     * Generate NGINX upstream configuration
     */
    static generateUpstreamConfig(applications: any[]) {
      const upstreamName = `app_comm_${Date.now()}`;
      let config = `# Gateway Upstream\nupstream ${upstreamName} {\n`;
      
      applications.forEach(app => {
        const backend = this.getBackendUrl(app);
        config += `    server ${backend} weight=1 max_fails=3 fail_timeout=30s;\n`;
      });
      
      config += `    least_conn;\n    keepalive 32;\n}\n`;
      return { config, upstreamName };
    }
  
    /**
     * Generate Location routing configuration
     */
    static generateLocationConfig(applications: any[], settings: any) {
      let config = `# Route mapping\n`;
      applications.forEach(app => {
        const path = `/${app.name.toLowerCase().replace(/[^a-z0-9]/g, '-')}`;
        config += `\nlocation ${path}/ {\n`;
        config += `    proxy_pass ${app.url};\n`;
        config += `    proxy_http_version 1.1;\n`;
        config += `    proxy_set_header Host $host;\n`;
        if (settings.rateLimiting?.enabled) {
          config += `    limit_req zone=app_rate burst=20 nodelay;\n`;
        }
        config += `}\n`;
      });
      return config;
    }
  
    private static getBackendUrl(app: any) {
      if (app.deploymentTarget === 'ec2' && app.ec2?.privateIp) {
        return `${app.ec2.privateIp}:${app.runtime?.port || 3000}`;
      }
      return `${app.name}.internal:${app.runtime?.port || 3000}`;
    }
  }
