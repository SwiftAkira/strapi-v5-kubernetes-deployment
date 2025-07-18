# Strapi v5.18.1 Upgrade Guide

This directory contains all the files and configurations needed to upgrade Strapi from v3.6.8 to v5.18.1 in our EKS cluster.

## 📋 Overview

The upgrade involves:
- Custom Docker image credocker buildx build --platform linux/amd64 -t your-registry-url/strapi:5-vX.X.X .
docker push your-registry-url/strapi:5-vX.X.Xion (no official Strapi v5 image available)
- New application structure for Strapi v5
- Updated dependencies and configuration
- Database migration considerations
- GitOps deployment via ArgoCD (fully tested workflow)

**🔧 GitOps Ready**: This project is designed for GitOps workflows. All configurations are declarative and work seamlessly with ArgoCD for automated deployments on Kubernetes clusters.

## 🏗️ Architecture Changes

### Strapi v3 → v5 Key Differences:
- **Admin Panel**: Requires building during Docker build process
- **Configuration**: New config structure with separate files
- **Dependencies**: Updated to React 18, styled-components v6
- **Database**: Same PostgreSQL but with potential schema changes
- **API**: Updated API structure and endpoints

## 📁 File Structure

```
strapi-v5-upgrade/
├── README.md              # This file
├── Dockerfile             # Custom multi-stage build
├── package.json           # Strapi v5 dependencies
├── config/
│   ├── admin.js          # Admin panel configuration
│   ├── database.js       # Database connection settings
│   └── server.js         # Server configuration
└── src/
    └── index.js          # Application entry point
```

## 🚀 Deployment Steps

### 1. Build and Push Docker Image

```bash
# Navigate to this directory
cd /path/to/strapi-v5-upgrade

# Authenticate with your container registry
# For AWS ECR:
aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-registry-url

# Build the image for AMD64 architecture
docker buildx build --platform linux/amd64 -f Dockerfile -t your-registry-url/strapi:5-latest .

# Push to your registry
docker push your-registry-url/strapi:5-latest
```

**🍎 Apple Silicon Mac Users**: When building on M1/M2/M3 Macs for EKS deployment, ensure you use `--platform linux/amd64` (already included in the commands above) to avoid "exec format error" on Linux nodes.

### 2. Update Deployment Configuration

The deployment configuration needs to be updated to use the new image. Key changes:

```yaml
# In deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: strapi
        image: your-registry-url/strapi:5-latest
        # Volume mount MUST be to /opt/app/data (not /opt/app)
        volumeMounts:
        - name: strapi-data
          mountPath: /opt/app/data
        # User ID must be 1001 (not 1000)
        securityContext:
          runAsUser: 1001
          runAsGroup: 1001
```

### 3. Deploy via ArgoCD

```bash
# Sync the application
argocd app sync strapi-app

# Or force refresh if needed
argocd app refresh strapi-app
argocd app sync strapi-app --force
```

### 4. Verify Deployment

```bash
# Check pod status
kubectl get pods -n strapi

# Check logs
kubectl logs -n strapi deployment/strapi -f

# Test health endpoint
kubectl port-forward -n strapi svc/strapi 8080:1337
curl http://localhost:8080/_health

# Test admin panel
curl http://localhost:8080/admin
```

## 🔧 Configuration Details

### Environment Variables
All environment variables are managed through Kubernetes ConfigMaps and Secrets:

**ConfigMap (`strapi-config`):**
- `DATABASE_CLIENT=postgres`
- `DATABASE_HOST=strapi-postgres-postgresql.strapi.svc.cluster.local`
- `DATABASE_PORT=5432`
- `DATABASE_NAME=strapi`
- `DATABASE_USERNAME=strapi`
- `HOST=0.0.0.0`
- `PORT=1337`
- `NODE_ENV=production`
- `STRAPI_PLUGIN_I18N_INIT_LOCALE_CODE=en`
- `STRAPI_TELEMETRY_DISABLED=true`
- `STRAPI_LOG_LEVEL=info`

**Secret (`strapi-secrets`):**
- `APP_KEYS` - Application encryption keys
- `API_TOKEN_SALT` - API token salt
- `ADMIN_JWT_SECRET` - Admin JWT secret
- `TRANSFER_TOKEN_SALT` - Transfer token salt
- `JWT_SECRET` - General JWT secret

### Database Configuration
The database connection is configured in `config/database.js` to use environment variables from Kubernetes.

### Admin Panel Configuration
The admin panel is configured in `config/admin.js` with:
- Custom build path
- Authentication settings
- API URL configuration

## 🗄️ Database Migration

⚠️ **Important**: Strapi v5 may require database schema changes. Always backup your database before upgrading.

```bash
# Create database backup
kubectl exec -n strapi strapi-postgres-postgresql-0 -- pg_dump -U strapi strapi > strapi_backup_$(date +%Y%m%d_%H%M%S).sql

# If migration fails, restore from backup
kubectl exec -i -n strapi strapi-postgres-postgresql-0 -- psql -U strapi strapi < strapi_backup_YYYYMMDD_HHMMSS.sql
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Admin Panel Shows "Not Found"
**Problem**: Admin panel returns 404 or shows blank page
**Solution**: Ensure `yarn build` is included in Dockerfile and admin assets are built

#### 2. Package.json Not Found
**Problem**: `ENOENT: no such file or directory, open '/opt/app/package.json'`
**Solution**: Volume mount should be `/opt/app/data`, not `/opt/app`

#### 3. Permission Errors
**Problem**: File permission errors or crashes
**Solution**: Ensure `runAsUser: 1001` and `runAsGroup: 1001` in deployment

#### 4. Database Connection Issues
**Problem**: Cannot connect to PostgreSQL
**Solution**: Check database service name and credentials in ConfigMap/Secret

#### 5. Styled Components Error
**Problem**: Build fails with styled-components version mismatch
**Solution**: Use `styled-components: ^6.1.8` in package.json

### Debug Commands

```bash
# Check pod logs
kubectl logs -n strapi deployment/strapi --tail=50 -f

# Exec into pod
kubectl exec -it -n strapi deployment/strapi -- /bin/sh

# Check file permissions
kubectl exec -it -n strapi deployment/strapi -- ls -la /opt/app/

# Check admin build files
kubectl exec -it -n strapi deployment/strapi -- ls -la /opt/app/node_modules/@strapi/admin/dist/

# Check database connectivity
kubectl exec -it -n strapi deployment/strapi -- node -e "
const config = require('./config/database.js');
console.log('DB Config:', config.connection);
"
```

## 📝 Version Update Process

### To Update Strapi Version:

1. **Update package.json**:
   ```json
   {
     "dependencies": {
       "@strapi/strapi": "^5.XX.X",
       "@strapi/plugin-users-permissions": "^5.XX.X",
       // ... other @strapi packages
     }
   }
   ```

2. **Test locally** (if possible):
   ```bash
   docker build -t strapi-test .
   docker run -p 1337:1337 strapi-test
   ```

3. **Build and push new image**:
   ```bash
   docker buildx build --platform linux/amd64 -t 742561979202.dkr.ecr.eu-central-1.amazonaws.com/strapi:5-vX.X.X .
   docker push 742561979202.dkr.ecr.eu-central-1.amazonaws.com/strapi:5-vX.X.X
   ```

4. **Update deployment** to use new image tag

5. **Deploy and test**

## 🚨 Rollback Procedure

If the upgrade fails:

1. **Immediate rollback**:
   ```bash
   kubectl rollout undo deployment/strapi -n strapi
   ```

2. **Restore database** (if needed):
   ```bash
   kubectl exec -i -n strapi strapi-postgres-postgresql-0 -- psql -U strapi strapi < backup.sql
   ```

3. **Update ArgoCD** to point back to v3 configuration

## 📊 Health Checks

### Endpoints to Monitor:
- `/_health` - Health check endpoint
- `/admin` - Admin panel accessibility
- `/api/users/me` - API functionality

### Expected Responses:
- Health check: `204 No Content`
- Admin panel: `200 OK` with HTML response
- API: `401 Unauthorized` (if not authenticated)

## 🔐 Security Considerations

1. **Secrets Management**: All sensitive data is stored in Kubernetes Secrets
2. **User Permissions**: Container runs as non-root user (1001)
3. **Network Policies**: Consider implementing network policies for database access
4. **Image Security**: Regularly scan Docker images for vulnerabilities

## 📚 Additional Resources

- [Strapi v5 Documentation](https://docs.strapi.io/dev-docs/migration/v4-to-v5)
- [Strapi v5 Breaking Changes](https://docs.strapi.io/dev-docs/migration/v4-to-v5/breaking-changes)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## 🏷️ Tags and Labels

- **Version**: Strapi v5.18.1
- **Environment**: Production/Staging
- **Architecture**: linux/amd64
- **Database**: PostgreSQL
- **Deployment**: Kubernetes/ArgoCD
- **Registry**: AWS ECR (eu-central-1)

---

**Last Updated**: July 19, 2025
**Maintainer**: Open Source Community
**Status**: Ready for deployment
**GitOps**: Tested with ArgoCD on AWS EKS

**Note**: This project was rapidly developed in 2 days - expect some rough edges but it's a solid foundation to build upon! 🚀
