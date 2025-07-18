module.exports = ({ env }) => ({
  auth: {
    secret: env('ADMIN_JWT_SECRET'),
  },
  apiToken: {
    salt: env('API_TOKEN_SALT'),
  },
  transfer: {
    token: {
      salt: env('TRANSFER_TOKEN_SALT'),
    },
  },
  flags: {
    nps: env.bool('FLAG_NPS', true),
    promoteEE: env.bool('FLAG_PROMOTE_EE', true),
  },
  // Vite configuration for admin panel
  vite: {
    server: {
      host: '0.0.0.0',
      port: env.int('PORT', 1337),
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
  }
});