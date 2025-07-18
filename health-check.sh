#!/bin/bash

# Health Check Script for Strapi v5 Kubernetes Deployment
# Usage: ./health-check.sh [namespace]

set -e

NAMESPACE=${1:-"strapi"}
DEPLOYMENT_NAME="strapi"
SERVICE_NAME="strapi"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🏥 Strapi v5 Health Check"
echo "========================="
echo ""

# Check if namespace exists
echo -n "📦 Checking namespace '$NAMESPACE'... "
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "❌ Namespace '$NAMESPACE' not found!"
    exit 1
fi

# Check deployment
echo -n "🚀 Checking deployment... "
if kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE &>/dev/null; then
    REPLICAS=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
    DESIRED=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}')
    if [[ "$REPLICAS" == "$DESIRED" ]] && [[ "$REPLICAS" -gt 0 ]]; then
        echo -e "${GREEN}✓ ($REPLICAS/$DESIRED ready)${NC}"
    else
        echo -e "${YELLOW}⚠ ($REPLICAS/$DESIRED ready)${NC}"
    fi
else
    echo -e "${RED}✗${NC}"
fi

# Check pods
echo -n "🏃 Checking pods... "
POD_COUNT=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi --no-headers | grep -c "Running" || echo "0")

if [[ "$RUNNING_PODS" -gt 0 ]] && [[ "$RUNNING_PODS" == "$POD_COUNT" ]]; then
    echo -e "${GREEN}✓ ($RUNNING_PODS/$POD_COUNT running)${NC}"
else
    echo -e "${YELLOW}⚠ ($RUNNING_PODS/$POD_COUNT running)${NC}"
fi

# Check service
echo -n "🌐 Checking service... "
if kubectl get service $SERVICE_NAME -n $NAMESPACE &>/dev/null; then
    ENDPOINTS=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)
    if [[ "$ENDPOINTS" -gt 0 ]]; then
        echo -e "${GREEN}✓ ($ENDPOINTS endpoints)${NC}"
    else
        echo -e "${YELLOW}⚠ (no endpoints)${NC}"
    fi
else
    echo -e "${RED}✗${NC}"
fi

# Check ingress
echo -n "🔗 Checking ingress... "
INGRESS_COUNT=$(kubectl get ingress -n $NAMESPACE 2>/dev/null | grep -c strapi || echo "0")
if [[ "$INGRESS_COUNT" -gt 0 ]]; then
    echo -e "${GREEN}✓ ($INGRESS_COUNT found)${NC}"
else
    echo -e "${YELLOW}⚠ (no ingress found)${NC}"
fi

# Test health endpoint
echo -n "❤️ Testing health endpoint... "
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [[ -n "$POD_NAME" ]]; then
    if kubectl exec -n $NAMESPACE $POD_NAME -- curl -f -s http://localhost:1337/_health &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
else
    echo -e "${RED}✗ (no pod found)${NC}"
fi

echo ""
echo "📊 Summary:"
echo "==========="

# Overall status
ISSUES=0

# Check for common issues
if [[ "$RUNNING_PODS" -eq 0 ]]; then
    echo -e "${RED}❌ No running pods${NC}"
    ((ISSUES++))
fi

if [[ "$ENDPOINTS" -eq 0 ]]; then
    echo -e "${RED}❌ Service has no endpoints${NC}"
    ((ISSUES++))
fi

if [[ "$ISSUES" -eq 0 ]]; then
    echo -e "${GREEN}✅ All checks passed! Strapi appears healthy.${NC}"
    echo ""
    echo "🎯 Quick access commands:"
    echo "  Port forward: kubectl port-forward -n $NAMESPACE svc/$SERVICE_NAME 8080:1337"
    echo "  View logs:    kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME -f"
    echo "  Get pods:     kubectl get pods -n $NAMESPACE"
else
    echo -e "${YELLOW}⚠️ $ISSUES issues found. Check the output above.${NC}"
    echo ""
    echo "🔍 Troubleshooting commands:"
    echo "  Check events: kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp"
    echo "  Check logs:   kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT_NAME"
    echo "  Describe pod: kubectl describe pod -n $NAMESPACE \$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=strapi -o name | head -1)"
fi

echo ""
