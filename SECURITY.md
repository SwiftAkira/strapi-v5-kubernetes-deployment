# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 5.18.x  | :white_check_mark: |
| < 5.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

### For Security Issues:
1. **Email**: Create a GitHub issue with `[SECURITY]` in the title
2. **Describe**: The potential security issue
3. **Include**: Steps to reproduce (if applicable)
4. **Response**: We'll respond within 48 hours

### What to Report:
- Container security vulnerabilities
- Kubernetes security misconfigurations
- Secrets exposure risks
- Authentication/authorization bypasses
- Data exposure issues

### What NOT to Report:
- General bugs (use regular issues)
- Feature requests
- Configuration questions

## Security Best Practices

When using this project:

1. **Always generate new secrets** - Don't use the placeholder values
2. **Use proper RBAC** in your Kubernetes cluster
3. **Enable Pod Security Standards**
4. **Keep images updated** with security patches
5. **Use network policies** to restrict pod communication
6. **Enable audit logging** in your cluster
7. **Regular backups** of sensitive data
8. **Monitor for vulnerabilities** in dependencies

## Container Security

The provided Dockerfile:
- Runs as non-root user (UID 1001)
- Uses Alpine Linux for smaller attack surface
- Includes health checks
- Updates packages during build

## Kubernetes Security

The manifests include:
- Security contexts with non-root users
- Resource limits and requests
- Health checks and probes
- Proper secret management

**Note**: This project was built quickly for functionality. Please review all configurations for your security requirements before production use.
