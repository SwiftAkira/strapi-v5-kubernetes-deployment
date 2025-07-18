# Strapi v5 Upgrade - File Organization

## 📁 Directory Structure

```
strapi-k8s-deployment/
├── strapi-v5-upgrade/           # 🔒 Isolated upgrade files (NOT read by ArgoCD)
│   ├── README.md                # 📖 Comprehensive deployment guide
│   ├── DATABASE_MIGRATION.md    # 🗄️ Database migration guide
│   ├── deploy.sh                # 🚀 Automated deployment script
│   ├── verify.sh                # ✅ Deployment verification script
│   ├── .env                     # ⚙️ Configuration variables
│   ├── Dockerfile               # 🐳 Custom Strapi v5 image
│   ├── package.json             # 📦 Strapi v5 dependencies
│   ├── config/                  # 🔧 Strapi v5 configuration files
│   │   ├── admin.js
│   │   ├── database.js
│   │   └── server.js
│   └── src/                     # 📄 Application source
│       └── index.js
├── deployment.yaml              # 🏗️ Current Kubernetes deployment
├── cm.yaml                      # 🗂️ ConfigMap
├── strapi-secrets.yaml          # 🔐 Secrets
├── strapi-ingress.yaml          # 🌐 Ingress configuration
├── strapi-private-ingress.yaml  # 🔒 Private ingress
├── svc.yaml                     # 📡 Service configuration
├── pvc.yaml                     # 💾 Storage configuration
├── pdb.yaml                     # 🛡️ Pod disruption budget
├── secret-provider-class.yaml   # 🔑 Secret provider
└── namespace.yaml               # 🏢 Namespace definition
```

## 🎯 Purpose

The `strapi-v5-upgrade/` directory contains all the files needed to upgrade Strapi from v3.6.8 to v5.18.1. This directory is:

- **Isolated**: ArgoCD/GitOps doesn't read this directory
- **Self-contained**: Everything needed for the upgrade is included
- **Well-documented**: Comprehensive guides and scripts
- **Production-ready**: Tested configurations and deployment scripts

## 🚀 Quick Start

1. **Review the upgrade**:
   ```bash
   cd strapi-v5-upgrade/
   cat README.md
   ```

2. **Deploy the upgrade**:
   ```bash
   ./deploy.sh full latest
   ```

3. **Verify the deployment**:
   ```bash
   ./verify.sh
   ```

## 📋 What's Included

### 📖 Documentation
- **README.md**: Complete deployment and troubleshooting guide
- **DATABASE_MIGRATION.md**: Database migration specifics
- **This file**: Organization overview

### 🛠️ Scripts
- **deploy.sh**: Automated build, push, and deployment
- **verify.sh**: Comprehensive deployment verification
- **.env**: Configuration variables

### 🔧 Configuration
- **Dockerfile**: Custom Strapi v5 image with proper dependencies
- **package.json**: Updated dependencies for v5.18.1
- **config/**: Strapi v5 configuration files
- **src/**: Application entry point

## 🔄 Migration Process

1. **Backup**: Create database backup
2. **Build**: Build custom Strapi v5 Docker image
3. **Deploy**: Update Kubernetes deployment
4. **Verify**: Run verification checks
5. **Monitor**: Watch logs and health checks

## 🏷️ Key Features

- ✅ **No official image required** - Custom build process
- ✅ **Admin panel building** - Proper asset compilation
- ✅ **Database migration** - Automated v3→v5 migration
- ✅ **Health checks** - Comprehensive verification
- ✅ **Rollback support** - Safe rollback procedures
- ✅ **Production ready** - Tested configurations

## 🔐 Security Notes

- All secrets remain in existing Kubernetes secrets
- Container runs as non-root user (1001)
- Volume mounts are properly configured
- Database credentials are unchanged

## 📞 Support

For issues or questions:
1. Check the README.md troubleshooting section
2. Run the verify.sh script for diagnostics
3. Review the DATABASE_MIGRATION.md for migration issues
4. Check ArgoCD logs for GitOps deployment status

---

**Status**: Ready for production deployment
**Last Updated**: July 17, 2025
**Version**: Strapi v5.18.1
