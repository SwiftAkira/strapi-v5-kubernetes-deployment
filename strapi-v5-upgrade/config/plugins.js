module.exports = ({ env }) => ({
  // Enable GraphQL plugin
  graphql: {
    enabled: true,
    config: {
      endpoint: '/graphql',
      shadowCRUD: true,
      landingPage: env('NODE_ENV') !== 'production', // Enable GraphQL Sandbox in development
      depthLimit: 10,
      amountLimit: 100,
      apolloServer: {
        tracing: false,
      },
    },
  },
  // Enable other plugins
  'users-permissions': {
    enabled: true,
  },
});
