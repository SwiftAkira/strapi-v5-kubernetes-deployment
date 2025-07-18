# Strapi v5 Kubernetes Setup Guide

This guide will help you customize this deployment for your own environment.

**🚀 GitOps R3. **Build an4. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f ../
   ```
5. **Verify the deployment**:
   ```bash
   ./verify.sh
   ```

## ⚠️ Important Platform Notes

### **Apple Silicon Mac Users (M1/M2/M3)**
**CRITICAL**: When building Docker images on Apple Silicon Macs for deployment to EKS (or any Linux-based Kubernetes), you MUST build for the correct architecture:

```bash
# The deploy.sh script already includes --platform linux/amd64
./deploy.sh build latest

# If building manually:
docker buildx build --platform linux/amd64 -t your-image .
```

**Why this matters:**
- Apple Silicon Macs use ARM64 architecture
- EKS nodes typically run AMD64/x86_64 Linux
- Wrong architecture = container won't start and will show "exec format error"
- The deploy.sh script handles this automaticallyour container image**:
   ```bash
   cd strapi-v5-upgrade/
   # IMPORTANT: On Apple Silicon Macs, use --platform linux/amd64
   ./deploy.sh build latest
   ./deploy.sh push latest
   ``` This project is designed and tested for GitOps workflows using ArgoCD on Kubernetes clusters, specifically AWS EKS. All configurations are declarative and ready for automated deployments.

## ⚠️ Important GitOps Warning

**CRITICAL for ArgoCD Users**: The markdown documentation files (`.md` files) in this repository might cause sync issues with ArgoCD, as it may try to read them as Kubernetes manifests. 

**Recommended actions before deployment:**
1. **Move documentation files** to a separate `docs/` folder outside the Kubernetes manifests
2. **Or delete the `.md` files** from your GitOps repository after reading them
3. **Or use the provided `.argocd-ignore` file** to exclude documentation files
4. **Or configure ArgoCD** to ignore `.md` files using application-level exclusions

**Safe files to keep in GitOps repo:**
- `*.yaml` files (Kubernetes manifests)
- `strapi-v5-upgrade/` directory (contains Dockerfile and configs)
- `.argocd-ignore` file (helps prevent sync issues)

**Files that may cause ArgoCD sync issues:**
- `README.md`
- `SETUP_GUIDE.md` 
- `ENVIRONMENT_SWITCH_GUIDE.md`
- `LICENSE`

## 🔧 Required Customizations

Before deploying, you **MUST** customize the following files for your environment:

### 1. Container Registry (`deployment.yaml`)

Update the image reference to point to your container registry:

```yaml
# In deployment.yaml, line ~22
image: your-registry/strapi:5-latest
```

**Examples:**
- AWS ECR: `123456789012.dkr.ecr.us-west-2.amazonaws.com/strapi:5-latest`
- Docker Hub: `yourusername/strapi:5-latest`
- Google Container Registry: `gcr.io/your-project/strapi:5-latest`
- Azure Container Registry: `yourregistry.azurecr.io/strapi:5-latest`

### 2. Domain Configuration

Update all domain references from the placeholder `your-domain.com`:

**Files to update:**
- `cm.yaml` - Lines 12-13, 25-27
- `strapi-ingress.yaml` - Line 12
- `strapi-private-ingress.yaml` - Line 8
- `vite-config.yaml` - Lines 13-17
- `strapi-v5-upgrade/Dockerfile` - Line 33
- `strapi-v5-upgrade/config/admin.js` - Lines 19-23
- `strapi-v5-upgrade/vite.config.admin.js` - Lines 9-13
- `strapi-v5-upgrade/vite.config.js` - Lines 9-13

**Replace:**
- `your-domain.com` → `yourdomain.com` (your main domain)
- `private.your-domain.com` → `admin.yourdomain.com` (your admin subdomain)
- `.your-domain.com` → `.yourdomain.com` (wildcard for subdomains)

### 3. Generate Secure Secrets (`strapi-secrets.yaml`)

**CRITICAL**: The current secrets are placeholders and are NOT secure!

Generate new secrets using these commands:

```bash
# Generate individual secrets
openssl rand -base64 32

# Generate APP_KEYS (4 comma-separated keys)
echo -n "$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)" | base64

# Generate other secrets and encode them
echo -n "$(openssl rand -base64 32)" | base64  # For API_TOKEN_SALT
echo -n "$(openssl rand -base64 32)" | base64  # For ADMIN_JWT_SECRET
echo -n "$(openssl rand -base64 32)" | base64  # For TRANSFER_TOKEN_SALT
echo -n "$(openssl rand -base64 32)" | base64  # For JWT_SECRET
```

Update the values in `strapi-secrets.yaml` with your generated base64-encoded secrets.

### 4. Network Configuration (Optional)

If you need to access the development environment locally, update the local IP addresses:

**Files to update:**
- `vite-config.yaml` - Line 17 (`192.168.1.100`)
- `strapi-v5-upgrade/config/admin.js` - Line 23
- `strapi-v5-upgrade/vite.config.admin.js` - Line 13
- `strapi-v5-upgrade/vite.config.js` - Line 13

Replace `192.168.1.100` with your local network IP address.

### 5. AWS Configuration (If using AWS)

If using AWS services, update:

**`secret-provider-class.yaml`:**
- Line 11: `your-app/strapi-credentials` → `your-app-name/strapi-credentials`

**`strapi-v5-upgrade/deploy.sh`:**
- Line 13: `your-registry-url` → Your ECR registry URL
- Line 15: `your-aws-region` → Your AWS region (e.g., `us-west-2`)

## 🚀 Deployment Steps

### Option 1: GitOps Deployment (Recommended)
1. **Customize all the files** as described above
2. **Handle documentation files** - Move `.md` files to `docs/` folder or delete them to prevent ArgoCD sync issues
3. **Build and push your container image**:
   ```bash
   cd strapi-v5-upgrade/
   ./deploy.sh build latest
   ./deploy.sh push latest
   ```
4. **Commit and push to your Git repository** (without `.md` files in root)
5. **Set up ArgoCD application** pointing to your repository
6. **Sync the application** in ArgoCD

### Option 2: Direct kubectl Deployment
1. **Customize all the files** as described above
2. **Build and push your container image**:
   ```bash
   cd strapi-v5-upgrade/
   # IMPORTANT: On Apple Silicon Macs, use --platform linux/amd64
   ./deploy.sh build latest
   ./deploy.sh push latest
   ```
3. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f ../
   ```
4. **Verify the deployment**:
   ```bash
   ./verify.sh
   ```

## 🔍 Verification Checklist

- [ ] Updated container registry URL
- [ ] Updated all domain references
- [ ] Generated new secure secrets
- [ ] Updated local IP addresses (if needed)
- [ ] Built and pushed container image
- [ ] Applied Kubernetes manifests
- [ ] Verified deployment with `verify.sh`
- [ ] Accessed admin panel at your domain

## ⚠️ Important Configuration Notes

### **Development vs Production Mode**
**CRITICAL**: Ensure ALL configuration files are set to the same mode (dev or prod). Mixed configurations will cause authentication issues that make it impossible to log in!

- **Development Mode**: Requires port-forwarding and localhost configuration
  ```bash
  # Port forward to access locally
  kubectl port-forward -n strapi svc/strapi --address 0.0.0.0 8080:1337
  # Access via: http://localhost:8080/admin or http://your-local-ip:8080/admin
  ```
  
- **Production Mode**: Use normal domains/URLs with proper DNS configuration
  ```
  # Access via: https://your-domain.com/admin
  ```

### **Development Mode Workaround**
When running in development mode, you need to configure the app to allow localhost connections from your K8s cluster. The current setup includes localhost IPs in the allowed hosts, but domain whitelisting in Strapi v5 can be tricky. Port-forwarding is the recommended workaround for local development.

### **Data Backup Recommendation**
**STRONGLY RECOMMENDED**: Install a backup plugin for your Strapi instance. Storing sensitive data only in PVCs without proper backup strategies is risky. Consider:
- Database backups (automated via CronJobs)
- File upload backups 
- Configuration backups
- Third-party backup solutions (Velero, etc.)

## 📚 Additional Resources

- [Container Registry Setup](https://kubernetes.io/docs/concepts/containers/images/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Strapi v5 Documentation](https://docs.strapi.io/)

## 🆘 Troubleshooting

### Common Issues:

1. **Image Pull Errors**: Check your container registry authentication
2. **Domain Not Accessible**: Verify DNS and ingress controller setup
3. **Admin Panel 404**: Check domain configuration in ConfigMaps
4. **Database Connection Issues**: Verify PostgreSQL is running and accessible
5. **Can't Login in Dev Mode**: Ensure you're using port-forwarding and localhost URLs
6. **Can't Login After Mode Switch**: Check that ALL configs (cm.yaml + deployment.yaml) match the same mode
7. **Mixed Configuration**: If some files are dev and others prod, authentication will fail completely
8. **Container Won't Start on EKS**: On Apple Silicon Macs, ensure you built with `--platform linux/amd64`

### Debug Commands:

```bash
# Check pod status
kubectl get pods -n strapi

# Check pod logs
kubectl logs -n strapi deployment/strapi

# Check service endpoints
kubectl get endpoints -n strapi

# Port forward for local testing (REQUIRED for dev mode)
kubectl port-forward -n strapi svc/strapi --address 0.0.0.0 8080:1337

# Check configuration consistency
kubectl get cm strapi-config -n strapi -o yaml
kubectl get deployment strapi -n strapi -o yaml | grep -A5 -B5 command
```

For more help, see the detailed guides in `strapi-v5-upgrade/README.md` and `ENVIRONMENT_SWITCH_GUIDE.md`.

## 🤝 Need Help?

This project was built quickly (2 days!) so there might be some issues. Don't hesitate to:
- **Ask questions** by creating a GitHub issue
- **Report bugs** you encounter
- **Request features** you'd like to see
- **Contribute** with pull requests

We're here to help make this work for your use case! 🚀
