# Tutor Environment Directory

This directory contains Tutor configuration files and data for the TRIGGER Open edX platform.

## Directory Structure

After running the setup script, this directory will contain:

```
env/
├── config.yml          # Main Tutor configuration
├── secrets.yml         # Sensitive configuration (excluded from Git)
├── data/              # Platform data (excluded from Git)
│   ├── lms/           # LMS application data
│   ├── cms/           # Studio application data
│   ├── mysql/         # MySQL database files
│   ├── mongodb/       # MongoDB database files
│   └── ...
├── plugins/           # Tutor plugins (excluded from Git)
└── logs/              # Application logs (excluded from Git)
```

## Important Files

### config.yml

Main configuration file for Tutor. This file contains:
- Platform name and branding
- Domain names (LMS_HOST, CMS_HOST)
- Email configuration
- Feature flags
- Plugin settings

**Note:** This file may contain sensitive information. Review before committing to Git.

### secrets.yml

Contains sensitive data such as:
- Database passwords
- Secret keys
- API keys
- OAuth credentials

**IMPORTANT:** This file is automatically excluded from Git via `.gitignore`. Never commit this file!

## Configuration Examples

See `config.example.yml` for example configurations.

## Initial Setup

To initialize this environment:

```bash
# From the project root
./scripts/setup.sh
```

Or manually:

```bash
cd env
tutor config save --interactive
tutor local do init
tutor local start -d
```

## Common Commands

All commands should be run from this directory (`env/`):

```bash
# Save configuration
tutor config save

# View configuration
tutor config printroot
tutor config printvalue LMS_HOST

# Start platform
tutor local start -d

# Stop platform
tutor local stop

# Restart platform
tutor local restart

# View logs
tutor local logs -f

# View specific service logs
tutor local logs -f lms
tutor local logs -f cms

# Check service status
tutor local status

# Execute command in container
tutor local exec lms bash

# Run Django management commands
tutor local exec lms ./manage.py lms shell
tutor local exec cms ./manage.py cms shell
```

## Configuration Management

### Local Development

For local development, use these settings:

```yaml
LMS_HOST: local.overhang.io
CMS_HOST: studio.local.overhang.io
ENABLE_HTTPS: false
```

### Production Deployment

For production, use:

```yaml
LMS_HOST: courses.trigger-project.eu
CMS_HOST: studio.trigger-project.eu
ENABLE_HTTPS: true
ENABLE_WEB_PROXY: true
```

### Changing Configuration

1. Edit `config.yml` or use `tutor config save`
2. Apply changes: `tutor config save`
3. Restart services: `tutor local restart`

## Backup and Restore

### Backup

```bash
# From project root
./scripts/backup.sh
```

Backs up:
- Databases (MySQL, MongoDB)
- Course data and media files
- Configuration files

### Restore

```bash
# From project root
./scripts/restore.sh backups/trigger-backup-YYYYMMDD.tar.gz
```

## Troubleshooting

### Services won't start

```bash
# Check Docker
docker ps

# Check logs
tutor local logs -f

# Restart Docker (if needed)
sudo systemctl restart docker  # Linux
# Or restart Docker Desktop on Mac/Windows

# Restart services
tutor local stop
tutor local start -d
```

### Out of disk space

```bash
# Clean Docker system
docker system prune -a

# Clean old backups
find ../backups/ -name "*.tar.gz" -mtime +30 -delete
```

### Reset environment

**WARNING:** This will delete all data!

```bash
tutor local stop
tutor local dc down -v
rm -rf data/
tutor local do init
tutor local start -d
```

## Security Notes

1. **Never commit** `secrets.yml` to Git
2. **Review** `config.yml` before committing - remove sensitive data
3. **Use strong passwords** for production
4. **Enable HTTPS** for production deployments
5. **Restrict SSH access** to your server
6. **Keep backups** in a secure location
7. **Update regularly** to get security patches

## Getting Help

- Tutor Documentation: https://docs.tutor.overhang.io/
- Tutor Forum: https://discuss.overhang.io/
- Project Documentation: See `../docs/` directory

## Related Documentation

- [Setup Guide](../docs/setup.md) - Complete setup instructions
- [Deployment Guide](../docs/deploy.md) - AWS deployment instructions
- [Maintenance Guide](../docs/maintenance.md) - Backup and update procedures
- [Usage Guide](../docs/usage.md) - Creating and managing courses
