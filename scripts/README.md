# TRIGGER Helper Scripts

This directory contains helper scripts to automate common tasks for the TRIGGER Open edX platform.

## Available Scripts

### 1. setup.sh

Automates the complete installation and configuration of Open edX using Tutor.

**Usage:**

```bash
# Local development setup
./setup.sh

# Production setup
./setup.sh --production --domain trigger-project.eu

# Show help
./setup.sh --help
```

**What it does:**
- Checks prerequisites (Docker, Python, disk space)
- Installs Tutor
- Configures Open edX
- Builds Docker images
- Initializes databases
- Enables plugins
- Starts services

**Options:**
- `--production` - Configure for production deployment
- `--domain DOMAIN` - Set domain name for production

**Time:** 30-45 minutes on first run

---

### 2. backup.sh

Creates comprehensive backups of your Open edX platform.

**Usage:**

```bash
# Create local backup
./backup.sh

# Backup and upload to S3
./backup.sh --s3 my-backup-bucket

# Custom retention period (days)
./backup.sh --retention 14

# Show help
./backup.sh --help
```

**What it backs up:**
- MySQL database
- MongoDB database
- Course content and media files
- Configuration files
- Metadata and version information

**Backup location:** `../backups/`

**Options:**
- `--s3 BUCKET` - Upload backup to S3 bucket
- `--retention DAYS` - Number of days to keep backups (default: 7)

**Time:** 5-15 minutes depending on data size

**Automated backups:**

```bash
# Schedule daily backups at 2 AM
crontab -e
# Add: 0 2 * * * /path/to/scripts/backup.sh
```

---

### 3. restore.sh

Restores Open edX from a backup archive.

**Usage:**

```bash
# Restore from local backup
./restore.sh ../backups/trigger-backup-20240115.tar.gz

# Restore from S3
./restore.sh s3://my-bucket/backups/trigger-backup-20240115.tar.gz

# Skip confirmation prompts
./restore.sh backup.tar.gz --force

# Show help
./restore.sh --help
```

**What it does:**
- Creates safety backup of current state
- Stops services
- Restores databases
- Restores course data
- Restores configuration
- Starts services
- Verifies restore

**Options:**
- `--force` - Skip confirmation prompts

**Time:** 10-20 minutes

**IMPORTANT:** Test restore procedures regularly on a test environment!

---

### 4. update.sh

Updates Tutor, plugins, and Open edX to the latest versions.

**Usage:**

```bash
# Standard update (with backup)
./update.sh

# Update without creating backup
./update.sh --skip-backup

# Skip confirmation prompts
./update.sh --force

# Show help
./update.sh --help
```

**What it does:**
- Creates pre-update backup
- Shows current versions
- Updates system packages
- Updates Tutor
- Updates plugins
- Updates Docker images
- Runs database migrations
- Restarts services
- Verifies update

**Options:**
- `--skip-backup` - Skip pre-update backup
- `--force` - Skip confirmation prompts

**Time:** 30-45 minutes

**Recommended schedule:** Monthly or when security updates are available

---

## Script Requirements

All scripts require:
- Bash shell
- Docker installed and running
- Tutor installed (except setup.sh which installs it)
- Sufficient disk space
- Appropriate permissions

## Making Scripts Executable

If scripts are not executable, run:

```bash
chmod +x *.sh
```

## Common Workflow

### Initial Setup

```bash
# 1. Run setup
./setup.sh

# 2. Create admin user
cd ../env
tutor local do createuser --staff --superuser admin admin@trigger.eu

# 3. Access platform
# Open http://local.overhang.io in browser
```

### Regular Maintenance

```bash
# Daily: Check logs
cd ../env
tutor local logs --tail=100

# Weekly: Create backup
./backup.sh

# Monthly: Update platform
./update.sh
```

### Disaster Recovery

```bash
# 1. Identify latest backup
ls -lh ../backups/

# 2. Restore from backup
./restore.sh ../backups/trigger-backup-YYYYMMDD.tar.gz

# 3. Verify platform
cd ../env
tutor local status
tutor local logs -f
```

## Scheduling Automated Tasks

Use cron to schedule automated tasks:

```bash
# Edit crontab
crontab -e

# Add scheduled tasks:
# Daily backup at 2 AM
0 2 * * * /home/ubuntu/trigger-course/scripts/backup.sh

# Weekly update on Sunday at 3 AM
0 3 * * 0 /home/ubuntu/trigger-course/scripts/update.sh --force

# Clean old Docker images weekly
0 4 * * 0 docker system prune -f
```

## Monitoring Script Execution

### View Script Logs

Scripts can log to files:

```bash
# Run with logging
./backup.sh 2>&1 | tee -a ../logs/backup.log

# View logs
tail -f ../logs/backup.log
```

### Email Notifications

Add email notifications to cron jobs:

```bash
# Edit crontab
crontab -e

# Add MAILTO at the top
MAILTO=admin@trigger-project.eu

# Scripts will email output on completion or errors
0 2 * * * /home/ubuntu/trigger-course/scripts/backup.sh
```

## Troubleshooting

### Script Won't Run

```bash
# Check if executable
ls -l *.sh

# Make executable
chmod +x script-name.sh

# Check for syntax errors
bash -n script-name.sh
```

### Docker Not Running

```bash
# Check Docker status
docker ps

# Start Docker (Linux)
sudo systemctl start docker

# Start Docker Desktop (Mac/Windows)
# Open Docker Desktop application
```

### Insufficient Permissions

```bash
# Run with appropriate user
# Don't use sudo unless necessary

# Check file ownership
ls -l

# Fix ownership if needed
chown -R $USER:$USER .
```

### Out of Disk Space

```bash
# Check disk space
df -h

# Clean Docker
docker system prune -a

# Remove old backups
find ../backups/ -name "*.tar.gz" -mtime +30 -delete
```

## Best Practices

### Backups

1. **Automate daily backups**
2. **Test restores regularly** (monthly)
3. **Store backups off-site** (S3, remote server)
4. **Keep multiple backup generations** (daily, weekly, monthly)
5. **Monitor backup success** (email notifications)

### Updates

1. **Create backup before updating**
2. **Read release notes** for breaking changes
3. **Test updates in staging environment first**
4. **Update during low-traffic periods**
5. **Monitor logs after updates**

### Security

1. **Never commit scripts with hardcoded passwords**
2. **Use environment variables** for sensitive data
3. **Restrict script permissions** (chmod 700 for sensitive scripts)
4. **Review script logs regularly**
5. **Keep scripts updated** with security patches

## Customization

Scripts can be customized by:

1. **Editing variables** at the top of each script
2. **Adding custom logic** for your specific needs
3. **Creating additional scripts** for custom tasks
4. **Using environment variables** for configuration

Example customization:

```bash
# Edit script
nano backup.sh

# Find configuration section
# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TUTOR_ROOT="${PROJECT_ROOT}/env"
BACKUP_ROOT="${PROJECT_ROOT}/backups"

# Modify as needed
BACKUP_ROOT="/mnt/external-drive/backups"
```

## Getting Help

If you encounter issues:

1. **Read script help**: `./script-name.sh --help`
2. **Check documentation**: See `../docs/` directory
3. **Review logs**: Check output for error messages
4. **Test prerequisites**: Ensure Docker and Tutor work
5. **Consult Tutor docs**: https://docs.tutor.overhang.io/

## Contributing

To improve these scripts:

1. Test changes thoroughly
2. Update documentation
3. Follow existing code style
4. Add error handling
5. Include help messages

## Script Maintenance

Scripts should be reviewed and updated:
- When Tutor version changes
- When Open edX version changes
- When new features are added
- When bugs are discovered
- Quarterly for best practices

---

**Related Documentation:**

- [Setup Guide](../docs/setup.md) - Complete setup instructions
- [Maintenance Guide](../docs/maintenance.md) - Detailed maintenance procedures
- [Deploy Guide](../docs/deploy.md) - AWS deployment instructions

---

**Last Updated:** 2024

**Script Version:** 1.0

**Compatible with:** Tutor 17.x, Open edX Palm
