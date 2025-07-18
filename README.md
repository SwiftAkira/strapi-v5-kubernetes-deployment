# Strapi v5 Kubernetes Open Source Project

This project provides a complete, production-ready setup for deploying Strapi v5 to a Kubernetes cluster. Since there is no official Docker image for Strapi v5, this project includes a custom Dockerfile and all the necessary Kubernetes configurations to get you up and running quickly.

**🚀 Built for GitOps**: This project is designed and tested with GitOps workflows using **ArgoCD**, **Kubernetes**, and **AWS EKS**. All configurations are declarative and ready for automated deployments.

**⚠️ ArgoCD Users**: Documentation files (`.md` files) may cause sync issues. Consider moving them to a `docs/` folder or deleting them from your GitOps repository after reading.

**⚡ Quick Development**: This entire project was built in just 2 days, so there will definitely be some rough edges and potential issues - but it's better than starting from scratch! 😄

## Features

-   **Custom Docker Image**: A production-ready Dockerfile for Strapi v5.
-   **Kubernetes Configurations**: A full set of Kubernetes manifests for a complete deployment.
-   **Persistent Storage**: Pre-configured PersistentVolumeClaims for data and uploads.
-   **Environment Switching**: A clear guide on how to switch between development and production modes.
-   **Secrets Management**: A template for managing your secrets.
-   **GitOps Ready**: Designed for ArgoCD and Kubernetes GitOps workflows.
-   **AWS EKS Tested**: Fully tested on AWS EKS clusters with ECR integration.

## How to Use This Project

**⚠️ IMPORTANT**: Before deploying, you must customize this project for your environment. See `SETUP_GUIDE.md` for detailed instructions.

Follow these steps to get this project up and running in your own environment.

### 1. Initialize a New Git Repository

First, you'll need to create a new Git repository for your project.

```bash
# Navigate to the open-source-project directory
cd open-source-project

# Initialize a new Git repository
git init

# Add all the files to the repository
git add .

# Make your initial commit
git commit -m "Initial commit"

# Add your remote repository URL
git remote add origin <your-repo-url>

# Push the project to your remote repository
git push -u origin master
```

### 2. Customize the Configuration

**CRITICAL**: You must customize several files before deployment. See `SETUP_GUIDE.md` for detailed instructions.

Key files to customize:
-   **`deployment.yaml`**: Update the `image` field to point to your container registry
-   **`cm.yaml`**: Update `PUBLIC_URL` and `STRAPI_ADMIN_BACKEND_URL` to your domain
-   **`strapi-secrets.yaml`**: Generate new secure secrets (current ones are placeholders!)
-   **Ingress files**: Update hostnames to your domain
-   **Deploy script**: Update registry URL and AWS region

### 3. Build and Push the Docker Image

You'll need to build the custom Docker image and push it to your registry.

```bash
# Navigate to the upgrade directory
cd strapi-v5-upgrade/

# Update deploy.sh with your registry details first!
# Then build and push (handles Apple Silicon compatibility automatically)
./deploy.sh build latest
./deploy.sh push latest
```

**📱 Apple Silicon Mac Users**: The deployment script automatically builds for `linux/amd64` architecture to ensure compatibility with EKS and other Linux-based Kubernetes clusters.

### 4. Deploy to Kubernetes

Once you've customized the configuration and pushed your Docker image, you can deploy the project to your Kubernetes cluster.

```bash
# Apply all the Kubernetes manifests
kubectl apply -f .

# Check deployment status
./health-check.sh
```

### 5. Access Your Strapi Instance

Once the deployment is complete, you can access your Strapi instance at the domain you configured in `cm.yaml`.

## ⚠️ Security Notice

The included `strapi-secrets.yaml` contains **placeholder values only**. You **MUST** generate your own secure secrets before deploying to production. See `SETUP_GUIDE.md` for instructions.

## Getting Started

1. **Read the setup guide**: Start with `SETUP_GUIDE.md` for customization instructions
2. **Review the project structure**: Check `PROJECT_STRUCTURE.md` for file organization
3. **Review the architecture**: Check `strapi-v5-upgrade/README.md` for technical details  
4. **Environment switching**: See `ENVIRONMENT_SWITCH_GUIDE.md` for dev/prod configuration
5. **Common questions**: Check `FAQ.md` for frequently asked questions

## 🤝 Contributing & Support

This project was built in 2 days, so I promise there will be issues! But hey, it's better than nothing! 😅

### 🐛 Found a Bug or Need Help?
- **Ask questions**: Feel free to reach out if you have any questions
- **Report issues**: Create an issue on GitHub if you encounter problems
- **Need a feature**: Open a feature request issue

### 🚀 Want to Contribute?
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-awesome-feature`
3. **Make your changes** and test them
4. **Submit a Pull Request** with a clear description

All contributions are welcome! Whether it's:
- 🐛 Bug fixes
- ✨ New features  
- 📚 Documentation improvements
- 🧪 Additional testing
- 🔧 Configuration optimizations

See `ROADMAP.md` for planned improvements and contribution opportunities.

### 💬 Questions?
Don't hesitate to ask! Check `FAQ.md` first, then create an issue or reach out if you need help getting this running in your environment.

## 📋 Compatibility

- ✅ **Kubernetes**: 1.24+
- ✅ **ArgoCD**: GitOps ready
- ✅ **AWS EKS**: Fully tested
- ✅ **Strapi**: v5.18.1
- ✅ **Node.js**: 20
- ✅ **PostgreSQL**: 12+

## 🚨 Important Notes

### **Environment Configuration**
- **CRITICAL**: Never mix dev/prod configurations - it will break authentication
- **Development**: Requires port-forwarding (`kubectl port-forward`)  
- **Production**: Use proper domains with DNS/SSL configuration

### **Data Backup**
**STRONGLY RECOMMENDED**: Implement backup strategies beyond PVCs for production use:
- Database backups (automated CronJobs)
- Upload file backups
- Consider backup plugins for Strapi
- Use tools like Velero for cluster-level backups

## 📄 License

This project is open source and available under the [MIT License](LICENSE). Feel free to use, modify, and distribute as needed!

**Thanks for checking out this project! Happy deploying! 🎉**
