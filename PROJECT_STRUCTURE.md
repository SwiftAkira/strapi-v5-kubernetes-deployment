# Project Structure

```
strapi-v5-kubernetes/
├── 📋 README.md                    # Main project documentation
├── 🔧 SETUP_GUIDE.md              # Customization instructions
├── 🔄 ENVIRONMENT_SWITCH_GUIDE.md # Dev/Prod switching guide
├── 🤝 CONTRIBUTING.md             # Contribution guidelines
├── 🔒 SECURITY.md                 # Security policy
├── 📝 CHANGELOG.md                # Version history
├── ❓ FAQ.md                      # Frequently asked questions
├── 🗺️ ROADMAP.md                  # Future plans and roadmap
├── ⚖️ LICENSE                     # MIT license
├── 🚫 .gitignore                  # Git ignore rules
├── 🎯 .argocd-ignore              # ArgoCD ignore rules
├── ⚙️ .yamllint.yaml              # YAML linting configuration
├── 🏥 health-check.sh             # Quick health check script
│
├── 📁 .github/                    # GitHub templates and workflows
│   ├── workflows/
│   │   └── validate.yml           # CI validation
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── help_question.md
│   └── pull_request_template.md
│
├── 🏗️ Kubernetes Manifests/
│   ├── namespace.yaml             # Namespace creation
│   ├── deployment.yaml            # Main Strapi deployment
│   ├── cm.yaml                    # Configuration map
│   ├── strapi-secrets.yaml        # Secrets (MUST be regenerated!)
│   ├── svc.yaml                   # Service
│   ├── strapi-ingress.yaml        # Public ingress
│   ├── strapi-private-ingress.yaml # Private ingress
│   ├── pvc.yaml                   # Data persistent volume
│   ├── uploads-pvc.yaml           # Uploads persistent volume
│   ├── pdb.yaml                   # Pod disruption budget
│   ├── secret-provider-class.yaml # AWS Secrets Manager
│   └── vite-config.yaml           # Vite configuration
│
└── 🚀 strapi-v5-upgrade/         # Build and deployment tools
    ├── 📖 README.md               # Technical documentation
    ├── 🗄️ DATABASE_MIGRATION.md   # Migration guide
    ├── 📁 ORGANIZATION.md         # File organization
    ├── ⚡ QUICK_REFERENCE.md      # Command reference
    ├── 🐳 Dockerfile              # Custom Strapi v5 image
    ├── 📦 package.json            # Strapi dependencies
    ├── 🚀 deploy.sh               # Deployment automation
    ├── ✅ verify.sh               # Deployment verification
    ├── ⚙️ vite.config.js          # Vite bundler config
    ├── ⚙️ vite.config.admin.js    # Vite admin config
    ├── 🔧 config/                 # Strapi configuration
    │   ├── admin.js
    │   ├── database.js
    │   ├── plugins.js
    │   └── server.js
    └── 📄 src/
        └── index.js               # Application entry point
```

## 🎯 Quick Start Files

1. **Start here**: `README.md`
2. **Customize**: `SETUP_GUIDE.md`
3. **Deploy**: `strapi-v5-upgrade/deploy.sh`
4. **Verify**: `strapi-v5-upgrade/verify.sh` or `health-check.sh`
5. **Questions**: `FAQ.md`

## 🔐 CRITICAL FILES TO MODIFY

- `strapi-secrets.yaml` - Generate new secrets!
- `cm.yaml` - Update domains and URLs
- `deployment.yaml` - Update container registry
- `strapi-ingress.yaml` - Update hostname
- `strapi-v5-upgrade/deploy.sh` - Update registry settings
