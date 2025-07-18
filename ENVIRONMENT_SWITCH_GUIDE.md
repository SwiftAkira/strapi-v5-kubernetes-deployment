# Strapi Environment Switch Guide: Development vs. Production

This guide provides detailed, step-by-step instructions on how to switch the Strapi deployment between **Development** and **Production** modes.

## Overview of Modes

### 🌳 Development Mode
- **Purpose**: Used for local development, debugging, and testing. Enables features like hot-reloading.
- **Command**: `yarn develop`
- **Access**: Typically accessed via `kubectl port-forward` on `localhost` or a local network IP.
- **Configuration**: `NODE_ENV` is set to `development`, and URLs point to `localhost` or a local IP.

### 🚀 Production Mode
- **Purpose**: Used for the live, public-facing application. It's optimized for performance and security.
- **Command**: `yarn start`
- **Access**: Accessed via the public domain name (e.g., `https://strapi.dev-onair.events`).
- **Configuration**: `NODE_ENV` is set to `production`, and URLs point to the public domain.

---

## How to Switch Environments

Follow these steps carefully to switch between modes.

### Step 1: Modify the `cm.yaml` ConfigMap

This file controls all the environment variables for Strapi.

1.  Open `cm.yaml`.
2.  Locate the `data` section and modify the following key-value pairs according to the target environment.

#### ➡️ To Switch to **Production Mode**:

Update the following values in `cm.yaml`:

```yaml
# ... other config ...
  NODE_ENV: production
  # Public URL for proper admin panel access (production server)
  PUBLIC_URL: "https://your-domain.com"
  # Admin panel URL configuration (production server)
  STRAPI_ADMIN_BACKEND_URL: "https://your-domain.com"
# ... other config ...
```

#### ➡️ To Switch to **Development Mode** (for Local Port-Forwarding):

Update the following values in `cm.yaml`. Replace `192.168.1.100` with your current local network IP if needed, or use `localhost`.

```yaml
# ... other config ...
  NODE_ENV: development
  # Public URL for proper admin panel access (support both localhost and WiFi IP)
  PUBLIC_URL: "http://192.168.1.100:1337"
  # Admin panel URL configuration (support both localhost and WiFi IP)
  STRAPI_ADMIN_BACKEND_URL: "http://192.168.1.100:1337"
# ... other config ...
```

### Step 2: Modify the `deployment.yaml` Startup Command

This file controls how the Strapi container is started.

1.  Open `deployment.yaml`.
2.  Find the `containers` section and locate the `command` and `args`.

#### ➡️ To Switch to **Production Mode**:

The container should use the `yarn start` command.

```yaml
# ... other config ...
        command: ["yarn", "start"]
        args: []
# ... other config ...
```

#### ➡️ To Switch to **Development Mode**:

The container should use the `yarn develop` command.

```yaml
# ... other config ...
        command: ["sh", "-c"]
        args: ["rm -rf /opt/app/build /opt/app/.cache /opt/app/node_modules/.cache && yarn develop"]
# ... other config ...
```
*Note: The `rm -rf ...` part helps clear caches that can sometimes cause issues when switching modes.*


### Step 3: Commit and Push Changes to Git

Since the cluster uses GitOps with ArgoCD, you must commit and push your changes to the repository for them to be applied.

**⚠️ Important**: If you're using ArgoCD, ensure documentation files (`.md` files) don't cause sync issues. Consider using the provided `.argocd-ignore` file or moving docs to a separate folder.

1.  **Stage your changes:**
    ```bash
    git add cm.yaml deployment.yaml
    ```

2.  **Commit the changes with a clear message:**
    ```bash
    # Example for switching to production
    git commit -m "Feat: Switch Strapi to production mode"

    # Example for switching to development
    git commit -m "Feat: Switch Strapi to development mode for local testing"
    ```

3.  **Push to the repository:**
    ```bash
    git push origin dev
    ```

### Step 4: Verify the Deployment

ArgoCD will automatically detect the changes and start deploying the new configuration. This will trigger a rolling restart of the Strapi pod.

1.  **Watch the pod status:**
    ```bash
    kubectl get pods -n strapi -w
    ```
    You will see the old pod terminating and a new one starting up. Wait for the new pod to be in the `Running` state and `1/1` ready.

2.  **Check the logs (optional but recommended):**
    Once the new pod is running, check its logs to ensure it started correctly in the desired mode.
    ```bash
    # Get the new pod name first
    kubectl get pods -n strapi

    # Check logs
    kubectl logs -n strapi <new-pod-name> -f
    ```
    In the logs, you should see messages indicating whether Strapi has started in production or development mode.

### Step 5: Access the Application

How you access Strapi depends on the mode.

-   **In Production Mode**: Access it via the public URL:
    `https://your-domain.com/admin`

-   **In Development Mode**: You need to use `port-forward`:
    ```bash
    # Get the new pod name
    kubectl get pods -n strapi
    
    # Start port-forwarding (use --address 0.0.0.0 to allow network access)
    kubectl port-forward -n strapi <new-pod-name> --address 0.0.0.0 1337:1337
    ```
    Then access it via `http://localhost:1337/admin` or `http://<your-wifi-ip>:1337/admin`.

## ⚠️ Critical Configuration Warnings

### **Mixed Mode Configuration Issues**
**NEVER mix development and production configurations!** If your `cm.yaml` is set to development mode but your `deployment.yaml` is using production commands (or vice versa), you will encounter authentication issues that make it **impossible to log in**.

**Always ensure:**
- `cm.yaml` NODE_ENV matches your intended mode
- `deployment.yaml` command matches your intended mode
- All URL configurations are consistent

### **Development Mode Limitations**
When running in development mode:
- **Domain whitelisting** in Strapi v5 can be challenging
- **Port-forwarding is required** for local access
- The app must be configured to allow localhost connections from your K8s cluster
- Current configuration includes localhost IPs in allowed hosts as a workaround

### **Production Mode Requirements**  
When running in production mode:
- **DNS must be properly configured** for your domain
- **SSL certificates** should be in place
- **All URLs** in configuration must use your actual domain
- **Ingress controller** must be properly configured

---
This completes the process. Following these steps will ensure a smooth transition between environments.

## 💾 Data Backup Recommendations

**IMPORTANT**: Since Strapi stores sensitive data, it's highly recommended to implement proper backup strategies beyond just PVCs:

### Recommended Backup Solutions:
- **Database Backups**: Set up automated PostgreSQL backups using CronJobs
- **File Upload Backups**: Backup the uploads PVC regularly  
- **Configuration Backups**: Version control all Kubernetes manifests
- **Cluster-level Backups**: Consider tools like Velero for disaster recovery
- **Strapi Backup Plugins**: Install backup plugins within Strapi for additional protection

### Example Database Backup CronJob:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: strapi-db-backup
  namespace: strapi
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > /backup/strapi_$(date +%Y%m%d_%H%M%S).sql
            # Add your database connection details
          restartPolicy: OnFailure
```

**Remember**: PVCs alone are not sufficient for production data protection!
