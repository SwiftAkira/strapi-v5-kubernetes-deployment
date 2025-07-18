# Frequently Asked Questions (FAQ)

## 🤔 Common Questions

### **Q: Why is there no official Strapi v5 Docker image?**
**A:** Strapi v5 requires building the admin panel during the Docker build process, which makes it complex to create a generic official image. This project provides a custom Dockerfile that handles the build process properly.

### **Q: Can I use this with other cloud providers besides AWS?**
**A:** Yes! While tested on AWS EKS, this should work on any Kubernetes cluster. You'll need to:
- Update the container registry URLs
- Modify the secrets management (remove AWS-specific parts)
- Adjust ingress configurations for your provider

### **Q: Why do I get "exec format error" when deploying?**
**A:** This typically happens when building on Apple Silicon Macs for Linux clusters. Ensure you use `--platform linux/amd64` when building (the deploy.sh script handles this automatically).

### **Q: Can I use this in production?**
**A:** Yes, but with important considerations:
- Generate new secure secrets (don't use the placeholders!)
- Implement proper backup strategies
- Review security configurations for your environment
- Test thoroughly in staging first
- Consider monitoring and logging solutions

### **Q: How do I switch between development and production modes?**
**A:** See the `ENVIRONMENT_SWITCH_GUIDE.md` file. **CRITICAL**: Ensure ALL configuration files match the same mode or authentication will break.

### **Q: Why can't I access the admin panel?**
**A:** Common causes:
- **Development mode**: You need port-forwarding (`kubectl port-forward`)
- **Production mode**: Check DNS, SSL, and ingress configuration
- **Mixed configs**: Ensure cm.yaml and deployment.yaml are both set to the same mode
- **Wrong domain**: Verify the domain in your configuration matches your setup

### **Q: How do I backup my data?**
**A:** We strongly recommend multiple backup strategies:
- Database backups (automated CronJobs)
- PVC snapshots
- File upload backups
- Consider tools like Velero for cluster-level backups
- See the backup section in `ENVIRONMENT_SWITCH_GUIDE.md`

### **Q: Can I use Helm instead of raw YAML?**
**A:** Currently, this project provides raw Kubernetes YAML manifests. Converting to Helm charts would be a great community contribution!

### **Q: Does this work with ArgoCD?**
**A:** Yes! This project is designed for GitOps with ArgoCD. Use the provided `.argocd-ignore` file to prevent documentation files from causing sync issues.

### **Q: How do I update Strapi to a newer version?**
**A:** 
1. Update the Strapi version in `strapi-v5-upgrade/package.json`
2. Rebuild the Docker image
3. Update the image tag in your deployment
4. Test in staging first
5. Deploy to production

### **Q: Why was this built in only 2 days?**
**A:** Sometimes you need a working solution quickly! While rapid development means some rough edges, it provides a solid foundation that would otherwise take weeks to create from scratch.

### **Q: How can I contribute?**
**A:** See `CONTRIBUTING.md` for guidelines. We welcome:
- Bug fixes and improvements
- Documentation updates
- Testing on different platforms
- Security enhancements
- New features

### **Q: Is this secure for production use?**
**A:** The base configurations follow security best practices, but you must:
- Generate new secrets (current ones are placeholders!)
- Review security settings for your environment
- Implement proper RBAC
- Use network policies
- Regular security updates
- See `SECURITY.md` for more details

### **Q: What if I get ArgoCD sync errors?**
**A:** Usually caused by documentation files. Solutions:
- Use the provided `.argocd-ignore` file
- Move `.md` files to a `docs/` folder
- Configure ArgoCD to ignore documentation files

### **Q: Can I use a different database than PostgreSQL?**
**A:** Strapi v5 supports multiple databases, but you'll need to:
- Update the database configuration in `config/database.js`
- Modify the connection settings in `cm.yaml`
- Ensure the database is available in your cluster

### **Q: Why are there two ingress files?**
**A:** 
- `strapi-ingress.yaml`: Public access with rate limiting
- `strapi-private-ingress.yaml`: Private/admin access without restrictions
- You can use one or both depending on your needs

## 🆘 Still Need Help?

If your question isn't answered here:
1. Check the troubleshooting sections in the documentation
2. Search existing GitHub issues
3. Create a new issue with the appropriate template
4. Be sure to include your environment details and logs

## 💡 Have a Question to Add?

If you think a question should be added to this FAQ, please open an issue or submit a PR!
