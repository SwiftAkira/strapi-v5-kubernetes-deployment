FROM node:20-alpine

# Set working directory
WORKDIR /opt/app

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    librsvg-dev \
    python3 \
    make \
    g++ \
    libc6-compat \
    vips-dev \
    curl

# Create strapi user
RUN addgroup -g 1001 strapi 2>/dev/null || true && \
    adduser -D -s /bin/sh -u 1001 -G strapi strapi 2>/dev/null || \
    adduser -D -s /bin/sh -u 1001 -G node strapi

# Set up the app directory
RUN mkdir -p /opt/app && chown strapi:strapi /opt/app

# Set environment variables for production
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337
ENV PUBLIC_URL=https://your-domain.com
ENV PROXY=true
ENV ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com,private.your-domain.com,.your-domain.com,strapi,strapi.strapi.svc.cluster.local,192.168.1.100

# Copy package.json and config files
COPY --chown=strapi:strapi package.json ./
COPY --chown=strapi:strapi vite.config.js ./
COPY --chown=strapi:strapi vite.config.admin.js ./
COPY --chown=strapi:strapi config/ ./config/
COPY --chown=strapi:strapi src/ ./src/

# Install dependencies (production only)
RUN yarn install --production=false

# Build the admin panel for production
RUN yarn build

# Remove development dependencies
RUN yarn install --production=true && yarn cache clean

# Create necessary directories and set permissions
RUN mkdir -p public/uploads data database/migrations .strapi && \
    chown -R strapi:strapi /opt/app

# Switch to strapi user
USER strapi

# Expose port
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:1337/_health || exit 1

# Start Strapi
CMD ["yarn", "start"]
