#!/bin/bash

# Strapi v5 Deployment Script
# This script automates the build and deployment process

set -e

# Configuration
ECR_REGISTRY="your-registry-url"
ECR_REPOSITORY="strapi"
AWS_REGION="your-aws-region"
NAMESPACE="strapi"
DEPLOYMENT_NAME="strapi"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if we're in the right directory
if [[ ! -f "Dockerfile" ]] || [[ ! -f "package.json" ]]; then
    error "Please run this script from the strapi-v5-upgrade directory"
fi

# Parse command line arguments
COMMAND=${1:-"help"}
VERSION=${2:-"latest"}

case $COMMAND in
    "build")
        log "Building Strapi v5 Docker image..."
        
        # Authenticate with ECR
        log "Authenticating with ECR..."
        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
        
        # Build image
        log "Building Docker image for linux/amd64..."
        # Note: --platform linux/amd64 ensures compatibility with EKS/Linux nodes (important for Apple Silicon Macs)
        docker buildx build --platform linux/amd64 -f Dockerfile -t $ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION .
        
        log "Build completed successfully!"
        ;;
        
    "push")
        log "Pushing image to ECR..."
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION
        log "Push completed successfully!"
        ;;
        
    "deploy")
        log "Deploying to Kubernetes..."
        
        # Update deployment to use new image
        kubectl set image deployment/$DEPLOYMENT_NAME -n $NAMESPACE strapi=$ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION
        
        # Wait for rollout to complete
        log "Waiting for deployment to complete..."
        kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE --timeout=600s
        
        log "Deployment completed successfully!"
        ;;
        
    "full")
        log "Running full deployment (build + push + deploy)..."
        
        # Build
        log "Step 1/3: Building image..."
        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
        # Note: --platform linux/amd64 ensures compatibility with EKS/Linux nodes (important for Apple Silicon Macs)
        docker buildx build --platform linux/amd64 -f Dockerfile -t $ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION .
        
        # Push
        log "Step 2/3: Pushing image..."
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION
        
        # Deploy
        log "Step 3/3: Deploying to Kubernetes..."
        kubectl set image deployment/$DEPLOYMENT_NAME -n $NAMESPACE strapi=$ECR_REGISTRY/$ECR_REPOSITORY:5-$VERSION
        kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE --timeout=600s
        
        log "Full deployment completed successfully!"
        ;;
        
    "rollback")
        log "Rolling back deployment..."
        kubectl rollout undo deployment/$DEPLOYMENT_NAME -n $NAMESPACE
        kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE --timeout=300s
        log "Rollback completed successfully!"
        ;;
        
    "status")
        log "Checking deployment status..."
        echo ""
        echo "Pods:"
        kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi
        echo ""
        echo "Deployment:"
        kubectl get deployment -n $NAMESPACE $DEPLOYMENT_NAME
        echo ""
        echo "Services:"
        kubectl get svc -n $NAMESPACE
        echo ""
        echo "Recent logs:"
        kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME --tail=10
        ;;
        
    "logs")
        log "Showing logs..."
        kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME -f --tail=50
        ;;
        
    "test")
        log "Testing deployment..."
        
        # Check if pod is ready
        kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=strapi -n $NAMESPACE --timeout=300s
        
        # Port forward and test
        log "Port forwarding to test endpoints..."
        kubectl port-forward -n $NAMESPACE svc/strapi 8080:1337 &
        PF_PID=$!
        
        sleep 5
        
        # Test health endpoint
        if curl -f http://localhost:8080/_health > /dev/null 2>&1; then
            log "Health check: PASSED"
        else
            warn "Health check: FAILED"
        fi
        
        # Test admin panel
        if curl -f http://localhost:8080/admin > /dev/null 2>&1; then
            log "Admin panel: ACCESSIBLE"
        else
            warn "Admin panel: NOT ACCESSIBLE"
        fi
        
        # Kill port forward
        kill $PF_PID
        
        log "Testing completed!"
        ;;
        
    "backup")
        log "Creating database backup..."
        BACKUP_FILE="strapi_backup_$(date +%Y%m%d_%H%M%S).sql"
        kubectl exec -n $NAMESPACE strapi-postgres-postgresql-0 -- pg_dump -U strapi strapi > $BACKUP_FILE
        log "Backup created: $BACKUP_FILE"
        ;;
        
    "restore")
        BACKUP_FILE=${2:-""}
        if [[ -z "$BACKUP_FILE" ]]; then
            error "Please provide backup file: ./deploy.sh restore <backup_file>"
        fi
        
        log "Restoring database from $BACKUP_FILE..."
        kubectl exec -i -n $NAMESPACE strapi-postgres-postgresql-0 -- psql -U strapi strapi < $BACKUP_FILE
        log "Database restore completed!"
        ;;
        
    "help"|*)
        echo "Strapi v5 Deployment Script"
        echo ""
        echo "Usage: $0 <command> [version]"
        echo ""
        echo "Commands:"
        echo "  build [version]     - Build Docker image (default: latest)"
        echo "  push [version]      - Push image to ECR"
        echo "  deploy [version]    - Deploy to Kubernetes"
        echo "  full [version]      - Build + Push + Deploy"
        echo "  rollback            - Rollback to previous version"
        echo "  status              - Show deployment status"
        echo "  logs                - Show live logs"
        echo "  test                - Test deployment health"
        echo "  backup              - Create database backup"
        echo "  restore <file>      - Restore database from backup"
        echo "  help                - Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 full latest      - Full deployment with latest tag"
        echo "  $0 build v5.18.1    - Build with specific version tag"
        echo "  $0 rollback         - Rollback deployment"
        echo "  $0 backup           - Create database backup"
        echo ""
        ;;
esac
