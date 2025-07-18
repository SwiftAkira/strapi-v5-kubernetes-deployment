# Strapi v5 Quick Reference Card

## 🚀 Common Commands

```bash
# Full deployment
./deploy.sh full latest

# Build only
./deploy.sh build v5.18.1

# Deploy only
./deploy.sh deploy latest

# Verify deployment
./verify.sh

# Quick health check
../health-check.sh

# Check status
./deploy.sh status

# View logs
./deploy.sh logs

# Rollback
./deploy.sh rollback

# Create backup
./deploy.sh backup

# Test health
./deploy.sh test
```

## 🔗 Important URLs

- **Admin Panel**: https://your-domain.com/admin
- **API**: https://your-domain.com/api
- **Health**: https://your-domain.com/_health

## 📊 Key Metrics

- **Namespace**: strapi
- **Deployment**: strapi
- **Service**: strapi
- **Port**: 1337
- **Image**: your-registry-url/strapi:5-latest

## 🔍 Debug Commands

```bash
# Pod logs
kubectl logs -n strapi deployment/strapi -f

# Pod status
kubectl get pods -n strapi

# Exec into pod
kubectl exec -it -n strapi deployment/strapi -- /bin/sh

# Port forward
kubectl port-forward -n strapi svc/strapi 8080:1337

# Database backup
kubectl exec -n strapi strapi-postgres-postgresql-0 -- pg_dump -U strapi strapi > backup.sql
```

## ⚠️ Emergency Procedures

### Quick Rollback
```bash
kubectl rollout undo deployment/strapi -n strapi
```

### Database Restore
```bash
kubectl exec -i -n strapi strapi-postgres-postgresql-0 -- psql -U strapi strapi < backup.sql
```

### Force Restart
```bash
kubectl rollout restart deployment/strapi -n strapi
```

## 📞 Health Checks

- **Health Endpoint**: `GET /_health` → 204 No Content
- **Admin Panel**: `GET /admin` → 200 OK
- **API Status**: `GET /api/users/me` → 401 Unauthorized (expected)
