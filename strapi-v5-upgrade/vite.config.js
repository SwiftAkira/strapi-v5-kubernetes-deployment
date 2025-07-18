import { defineConfig } from '@strapi/strapi/admin';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 1337,
    allowedHosts: [
      'localhost',
      '127.0.0.1',
      'your-domain.com',
      'private.your-domain.com',
      '.your-domain.com',
      'strapi',
      'strapi.strapi.svc.cluster.local',
      '192.168.1.100'
    ]
  }
});
