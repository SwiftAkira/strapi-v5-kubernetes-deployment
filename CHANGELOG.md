# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-07-19

### Added
- Initial release of Strapi v5 Kubernetes deployment
- Custom Docker image for Strapi v5.18.1
- Complete Kubernetes manifests (Deployment, Service, Ingress, etc.)
- GitOps ready configuration for ArgoCD
- Environment switching guide (Development vs Production)
- Automated deployment scripts
- Comprehensive verification scripts
- Database migration guide from Strapi v3 to v5
- Security best practices documentation
- Backup recommendations and examples
- AWS EKS specific configurations
- Multi-stage Dockerfile with admin panel building
- Persistent volume configurations for data and uploads
- Health checks and monitoring setup

### Security
- Non-root container execution (UID 1001)
- Secrets management with Kubernetes secrets
- Security contexts and resource limits
- Example secrets with base64 encoding

### Documentation
- Complete setup guide for customization
- Troubleshooting section with common issues
- GitOps deployment instructions
- Contributing guidelines
- Security policy

### Compatibility
- Kubernetes 1.24+
- Strapi v5.18.1
- Node.js 20
- PostgreSQL 12+
- ArgoCD (GitOps)
- AWS EKS (tested)

### Known Issues
- Domain whitelisting in development mode requires port-forwarding workaround
- Mixed development/production configuration causes authentication failures
- Documentation files may cause ArgoCD sync issues (workaround provided)

---

**Note**: This project was developed rapidly (2 days) as a foundation. Expect some rough edges but it provides a solid starting point for Strapi v5 on Kubernetes.
