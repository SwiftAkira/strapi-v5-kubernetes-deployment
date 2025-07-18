# Database Migration Guide: Strapi v3 to v5

## Overview
This guide covers the database migration process when upgrading from Strapi v3.6.8 to v5.18.1.

## ⚠️ Important Warnings

1. **ALWAYS create a backup before starting the migration**
2. **Test the migration in a staging environment first**
3. **The migration process may take time depending on your data volume**
4. **Some plugins may not be compatible with v5**

## 📋 Pre-Migration Checklist

- [ ] Create full database backup
- [ ] Document current plugin usage
- [ ] Review custom configurations
- [ ] Ensure sufficient disk space
- [ ] Plan for downtime
- [ ] Test migration in staging

## 🔄 Migration Process

### Step 1: Create Database Backup

```bash
# Using the deployment script
./deploy.sh backup

# Or manually
kubectl exec -n strapi strapi-postgres-postgresql-0 -- pg_dump -U strapi strapi > strapi_v3_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Step 2: Deploy Strapi v5

```bash
# Build and deploy v5
./deploy.sh full latest

# Monitor deployment
kubectl logs -n strapi deployment/strapi -f
```

### Step 3: Database Migration

Strapi v5 will automatically run database migrations on startup. Monitor the logs for:

```
[INFO] Database migration started
[INFO] Migrating table: strapi_database_schema
[INFO] Migrating table: strapi_migrations
[INFO] Database migration completed successfully
```

### Step 4: Verify Migration

```bash
# Run verification script
./verify.sh

# Check admin panel
kubectl port-forward -n strapi svc/strapi 8080:1337
# Open http://localhost:8080/admin
```

## 🔍 Common Migration Issues

### Issue 1: Plugin Compatibility
**Problem**: Some v3 plugins may not work with v5
**Solution**: Remove incompatible plugins from package.json and find v5 alternatives

### Issue 2: Configuration Changes
**Problem**: Configuration structure has changed
**Solution**: Update config files to match v5 structure (already done in this upgrade)

### Issue 3: API Changes
**Problem**: API endpoints or responses have changed
**Solution**: Update frontend/client applications to match new API structure

### Issue 4: Database Schema Conflicts
**Problem**: Migration fails due to schema conflicts
**Solution**: 
```sql
-- Check for conflicts
SELECT * FROM strapi_database_schema;
SELECT * FROM strapi_migrations;

-- If needed, clean up conflicting entries
DELETE FROM strapi_database_schema WHERE name = 'problematic_table';
```

## 🏗️ Schema Changes (v3 → v5)

### Core Tables
- `strapi_database_schema` - Updated structure
- `strapi_migrations` - New migration tracking
- `strapi_api_tokens` - Enhanced token management
- `strapi_transfer_tokens` - New transfer token system

### Content Types
- Permission system updated
- Relation handling improved
- Component structure enhanced

### User Management
- `strapi_users` - Enhanced user model
- `strapi_role` - Updated role system
- `strapi_permission` - Refined permissions

## 🔧 Manual Migration Steps (if needed)

### If automatic migration fails:

1. **Reset migration state**:
```sql
DELETE FROM strapi_migrations;
DELETE FROM strapi_database_schema;
```

2. **Restart Strapi** to trigger fresh migration:
```bash
kubectl rollout restart deployment/strapi -n strapi
```

3. **Monitor logs** for migration progress:
```bash
kubectl logs -n strapi deployment/strapi -f
```

## 🚨 Rollback Procedure

If migration fails and you need to rollback:

### Option 1: Kubernetes Rollback
```bash
kubectl rollout undo deployment/strapi -n strapi
```

### Option 2: Database Restore
```bash
# Stop current deployment
kubectl scale deployment/strapi -n strapi --replicas=0

# Restore database
kubectl exec -i -n strapi strapi-postgres-postgresql-0 -- psql -U strapi strapi < strapi_v3_backup_YYYYMMDD_HHMMSS.sql

# Rollback to v3 configuration
# (Update ArgoCD to point to v3 configs)

# Restart deployment
kubectl scale deployment/strapi -n strapi --replicas=1
```

## 📊 Monitoring Migration

### Key Metrics to Watch:
- Database connection status
- Migration log entries
- API response times
- Admin panel accessibility
- Content type availability

### Log Patterns to Monitor:
```bash
# Success patterns
grep -i "migration.*success" logs.txt
grep -i "database.*ready" logs.txt

# Error patterns
grep -i "migration.*error" logs.txt
grep -i "database.*error" logs.txt
```

## 🔍 Post-Migration Verification

### Database Verification Queries:
```sql
-- Check migration status
SELECT * FROM strapi_migrations ORDER BY time DESC LIMIT 10;

-- Check schema version
SELECT * FROM strapi_database_schema WHERE name = 'strapi_core_store';

-- Verify content types
SELECT * FROM strapi_core_store WHERE key LIKE 'model_def_%';

-- Check user accounts
SELECT id, username, email, provider, confirmed FROM strapi_users;
```

### API Verification:
```bash
# Test authentication
curl -X POST http://localhost:8080/api/auth/local \
  -H "Content-Type: application/json" \
  -d '{"identifier": "admin", "password": "password"}'

# Test content endpoints
curl http://localhost:8080/api/content-types

# Test admin API
curl http://localhost:8080/api/users/me
```

## 📚 References

- [Strapi v5 Migration Guide](https://docs.strapi.io/dev-docs/migration/v4-to-v5)
- [Database Migration Best Practices](https://docs.strapi.io/dev-docs/database-migrations)
- [API Changes in v5](https://docs.strapi.io/dev-docs/migration/v4-to-v5/breaking-changes)

---

**Remember**: Always test in staging first and have a rollback plan ready!
