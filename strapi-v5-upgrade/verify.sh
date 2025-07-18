#!/bin/bash

# Strapi v5 Verification Script
# This script verifies that the deployment is working correctly

set -e

# Configuration
NAMESPACE="strapi"
DEPLOYMENT_NAME="strapi"
SERVICE_NAME="strapi"
TIMEOUT=300

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    return 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

check_mark() {
    echo -e "${GREEN}✓${NC}"
}

cross_mark() {
    echo -e "${RED}✗${NC}"
}

# Check functions
check_namespace() {
    info "Checking namespace $NAMESPACE..."
    if kubectl get namespace $NAMESPACE &>/dev/null; then
        echo -n "  Namespace exists: "
        check_mark
        return 0
    else
        echo -n "  Namespace exists: "
        cross_mark
        return 1
    fi
}

check_deployment() {
    info "Checking deployment $DEPLOYMENT_NAME..."
    
    # Check if deployment exists
    if ! kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE &>/dev/null; then
        echo -n "  Deployment exists: "
        cross_mark
        return 1
    fi
    
    echo -n "  Deployment exists: "
    check_mark
    
    # Check if deployment is ready
    local ready_replicas=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
    local desired_replicas=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}')
    
    if [[ "$ready_replicas" == "$desired_replicas" ]] && [[ "$ready_replicas" -gt 0 ]]; then
        echo -n "  Deployment ready ($ready_replicas/$desired_replicas): "
        check_mark
        return 0
    else
        echo -n "  Deployment ready ($ready_replicas/$desired_replicas): "
        cross_mark
        return 1
    fi
}

check_pods() {
    info "Checking pods..."
    
    local pod_count=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi --no-headers | wc -l)
    local running_pods=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi --no-headers | grep -c "Running" || echo "0")
    
    echo -n "  Pods running ($running_pods/$pod_count): "
    if [[ "$running_pods" -gt 0 ]] && [[ "$running_pods" == "$pod_count" ]]; then
        check_mark
        return 0
    else
        cross_mark
        return 1
    fi
}

check_service() {
    info "Checking service $SERVICE_NAME..."
    
    if kubectl get service $SERVICE_NAME -n $NAMESPACE &>/dev/null; then
        echo -n "  Service exists: "
        check_mark
        
        # Check if service has endpoints
        local endpoints=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)
        echo -n "  Service endpoints ($endpoints): "
        if [[ "$endpoints" -gt 0 ]]; then
            check_mark
            return 0
        else
            cross_mark
            return 1
        fi
    else
        echo -n "  Service exists: "
        cross_mark
        return 1
    fi
}

check_health_endpoint() {
    info "Checking health endpoint..."
    
    # Port forward to test
    kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME 8080:1337 &
    local pf_pid=$!
    
    sleep 5
    
    # Test health endpoint
    if curl -f -s http://localhost:8080/_health &>/dev/null; then
        echo -n "  Health endpoint responsive: "
        check_mark
        kill $pf_pid
        return 0
    else
        echo -n "  Health endpoint responsive: "
        cross_mark
        kill $pf_pid
        return 1
    fi
}

check_admin_panel() {
    info "Checking admin panel..."
    
    # Port forward to test
    kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME 8080:1337 &
    local pf_pid=$!
    
    sleep 5
    
    # Test admin panel
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/admin)
    
    if [[ "$response" == "200" ]]; then
        echo -n "  Admin panel accessible: "
        check_mark
        kill $pf_pid
        return 0
    else
        echo -n "  Admin panel accessible (HTTP $response): "
        cross_mark
        kill $pf_pid
        return 1
    fi
}

check_logs() {
    info "Checking recent logs for errors..."
    
    local error_count=$(kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME --tail=100 | grep -i error | wc -l)
    
    echo -n "  Recent errors in logs ($error_count): "
    if [[ "$error_count" -eq 0 ]]; then
        check_mark
        return 0
    else
        cross_mark
        return 1
    fi
}

check_database_connection() {
    info "Checking database connection..."
    
    # Try to connect to database through Strapi
    local pod_name=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi -o jsonpath='{.items[0].metadata.name}')
    
    if kubectl exec -n $NAMESPACE $pod_name -- node -e "
        const config = require('./config/database.js');
        const { Client } = require('pg');
        const client = new Client(config.connection);
        client.connect().then(() => {
            console.log('Database connection successful');
            client.end();
        }).catch(err => {
            console.error('Database connection failed:', err);
            process.exit(1);
        });
    " &>/dev/null; then
        echo -n "  Database connection: "
        check_mark
        return 0
    else
        echo -n "  Database connection: "
        cross_mark
        return 1
    fi
}

check_version() {
    info "Checking Strapi version..."
    
    local pod_name=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi -o jsonpath='{.items[0].metadata.name}')
    local version=$(kubectl exec -n $NAMESPACE $pod_name -- node -e "console.log(require('./package.json').dependencies['@strapi/strapi'])" 2>/dev/null || echo "unknown")
    
    echo -n "  Strapi version ($version): "
    if [[ "$version" == *"5."* ]]; then
        check_mark
        return 0
    else
        cross_mark
        return 1
    fi
}

# Main verification
main() {
    echo "================================================================="
    echo "               Strapi v5 Deployment Verification"
    echo "================================================================="
    echo ""
    
    local total_checks=0
    local passed_checks=0
    
    # Run all checks
    checks=(
        "check_namespace"
        "check_deployment"
        "check_pods"
        "check_service"
        "check_health_endpoint"
        "check_admin_panel"
        "check_logs"
        "check_database_connection"
        "check_version"
    )
    
    for check in "${checks[@]}"; do
        total_checks=$((total_checks + 1))
        if $check; then
            passed_checks=$((passed_checks + 1))
        fi
        echo ""
    done
    
    # Summary
    echo "================================================================="
    echo "                      Verification Summary"
    echo "================================================================="
    echo ""
    echo "Total checks: $total_checks"
    echo "Passed: $passed_checks"
    echo "Failed: $((total_checks - passed_checks))"
    echo ""
    
    if [[ $passed_checks -eq $total_checks ]]; then
        log "✅ All checks passed! Strapi v5 deployment is healthy."
        echo ""
        echo "🎉 You can now access:"
        echo "   - Admin Panel: https://your-domain.com/admin"
        echo "   - API: https://your-domain.com/api"
        echo "   - Health: https://your-domain.com/_health"
        echo ""
        return 0
    else
        warn "❌ Some checks failed. Please review the output above."
        echo ""
        echo "🔍 Troubleshooting:"
        echo "   - Check logs: kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME"
        echo "   - Check pod status: kubectl get pods -n $NAMESPACE"
        echo "   - Check events: kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp"
        echo ""
        return 1
    fi
}

# Run the verification
main
