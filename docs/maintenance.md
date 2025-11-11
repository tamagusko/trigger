# Maintenance Guide

This guide covers backup, restore, update, and troubleshooting procedures for the TRIGGER Open edX platform.

## Table of Contents

1. [Regular Maintenance Tasks](#regular-maintenance-tasks)
2. [Backup Procedures](#backup-procedures)
3. [Restore Procedures](#restore-procedures)
4. [Update Procedures](#update-procedures)
5. [Monitoring and Health Checks](#monitoring-and-health-checks)
6. [Database Maintenance](#database-maintenance)
7. [Troubleshooting](#troubleshooting)
8. [Security Best Practices](#security-best-practices)
9. [Performance Optimization](#performance-optimization)

---

## Regular Maintenance Tasks

### Daily Tasks

**1. Check System Health**
```bash
# View running services
tutor local status

# Check logs for errors
tutor local logs --tail=100 | grep -i error

# Check disk space
df -h
```

**2. Monitor Resource Usage**
```bash
# View CPU and memory
htop

# View Docker stats
docker stats --no-stream
```

### Weekly Tasks

**1. Review Logs**
```bash
# Check all service logs
tutor local logs --tail=1000 > weekly-logs.txt

# Look for patterns or recurring errors
grep -i "error\|warning\|critical" weekly-logs.txt
```

**2. Check Backups**
```bash
# Verify backup script ran successfully
ls -lh ~/trigger-course/backups/

# Test restore process (on test system)
./scripts/restore.sh backup-2024-01-15.tar.gz
```

**3. Update Content**
- Review course announcements
- Check for broken links
- Update course materials as needed

### Monthly Tasks

**1. Update System Packages**
```bash
# Update Ubuntu packages
sudo apt update && sudo apt upgrade -y

# Update Tutor
pip install --upgrade "tutor[full]"
```

**2. Review Analytics**
- Check enrollment trends
- Review completion rates
- Analyze user feedback

**3. Security Audit**
```bash
# Check for security updates
sudo apt list --upgradable

# Review user accounts
tutor local exec lms ./manage.py lms shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(is_superuser=True).count())"

# Check SSL certificate expiration
echo | openssl s_client -servername courses.trigger-project.eu -connect courses.trigger-project.eu:443 2>/dev/null | openssl x509 -noout -dates
```

---

## Backup Procedures

### Automated Backup Script

The project includes a backup script at `scripts/backup.sh`. This script backs up:
- MySQL/MongoDB databases
- Course content and media files
- Configuration files

**Run Manual Backup:**
```bash
cd ~/trigger-course
./scripts/backup.sh
```

**Schedule Automated Backups:**

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /home/ubuntu/trigger-course/scripts/backup.sh

# Add weekly backup at Sunday 3 AM
0 3 * * 0 /home/ubuntu/trigger-course/scripts/backup.sh
```

### Manual Backup Procedures

**1. Backup Databases:**

```bash
# Create backup directory
mkdir -p ~/backups

# Backup MySQL database
tutor local exec mysql mysqldump --all-databases > ~/backups/mysql-$(date +%Y%m%d).sql

# Backup MongoDB database
tutor local exec mongodb mongodump --archive=/tmp/mongodb-backup.archive
tutor local cp mongodb:/tmp/mongodb-backup.archive ~/backups/mongodb-$(date +%Y%m%d).archive
```

**2. Backup Course Data:**

```bash
# Backup Tutor data directory
cd ~/trigger-course/env
tar -czf ~/backups/tutor-data-$(date +%Y%m%d).tar.gz data/
```

**3. Backup Configuration:**

```bash
# Backup Tutor configuration
cp ~/trigger-course/env/config.yml ~/backups/config-$(date +%Y%m%d).yml

# Note: Never commit config.yml or secrets to Git!
```

**4. Create Complete Backup Archive:**

```bash
cd ~/backups
tar -czf complete-backup-$(date +%Y%m%d).tar.gz \
  mysql-$(date +%Y%m%d).sql \
  mongodb-$(date +%Y%m%d).archive \
  tutor-data-$(date +%Y%m%d).tar.gz \
  config-$(date +%Y%m%d).yml
```

### Backup Storage

**Local Storage:**
- Keep last 7 daily backups
- Keep last 4 weekly backups
- Keep last 12 monthly backups

**Remote Storage (Recommended):**

**Option 1: AWS S3**
```bash
# Install AWS CLI
pip install awscli

# Configure AWS credentials
aws configure

# Upload backup to S3
aws s3 cp ~/backups/complete-backup-$(date +%Y%m%d).tar.gz s3://trigger-backups/
```

**Option 2: rsync to Remote Server**
```bash
# Sync backups to remote server
rsync -avz ~/backups/ user@backup-server:/backups/trigger-openedx/
```

### Backup Rotation Script

Add to your backup script:

```bash
#!/bin/bash
# Keep only last 7 days of backups
find ~/backups/ -name "*.tar.gz" -mtime +7 -delete

# Keep weekly backups (Sundays)
if [ $(date +%u) -eq 7 ]; then
  cp ~/backups/complete-backup-$(date +%Y%m%d).tar.gz ~/backups/weekly/
fi

# Keep monthly backups (1st of month)
if [ $(date +%d) -eq 01 ]; then
  cp ~/backups/complete-backup-$(date +%Y%m%d).tar.gz ~/backups/monthly/
fi
```

---

## Restore Procedures

### Using the Restore Script

```bash
cd ~/trigger-course
./scripts/restore.sh ~/backups/complete-backup-20240115.tar.gz
```

### Manual Restore

**IMPORTANT:** Test restore procedures on a separate test environment first!

**1. Stop Services:**
```bash
cd ~/trigger-course/env
tutor local stop
```

**2. Restore Databases:**

```bash
# Restore MySQL
tutor local exec -i mysql mysql < ~/backups/mysql-20240115.sql

# Restore MongoDB
tutor local cp ~/backups/mongodb-20240115.archive mongodb:/tmp/
tutor local exec mongodb mongorestore --archive=/tmp/mongodb-20240115.archive
```

**3. Restore Course Data:**

```bash
# Extract data backup
cd ~/trigger-course/env
tar -xzf ~/backups/tutor-data-20240115.tar.gz
```

**4. Restore Configuration:**

```bash
# Restore config file
cp ~/backups/config-20240115.yml ~/trigger-course/env/config.yml
```

**5. Restart Services:**

```bash
tutor local start -d
```

**6. Verify Restore:**

```bash
# Check all services are running
tutor local status

# Test access to platform
curl -I http://local.overhang.io

# Verify database connectivity
tutor local exec lms ./manage.py lms check
```

### Disaster Recovery

**Complete System Failure:**

1. **Provision New Server:**
   - Same specifications as original
   - Install Docker and Tutor
   - Clone TRIGGER repository

2. **Restore from Backup:**
   ```bash
   ./scripts/restore.sh s3://trigger-backups/latest-backup.tar.gz
   ```

3. **Update DNS (if IP changed):**
   - Point domain to new IP
   - Wait for DNS propagation

4. **Verify SSL Certificates:**
   ```bash
   tutor local restart
   ```

---

## Update Procedures

### Using the Update Script

```bash
cd ~/trigger-course
./scripts/update.sh
```

This script will:
1. Create a backup
2. Update Tutor
3. Update plugins
4. Rebuild images
5. Run migrations
6. Restart services

### Manual Update Process

**1. Backup Current System:**
```bash
./scripts/backup.sh
```

**2. Update Tutor:**

```bash
# Check current version
tutor --version

# Update Tutor
pip install --upgrade "tutor[full]"

# Verify new version
tutor --version
```

**3. Update Configuration:**

```bash
cd ~/trigger-course/env
tutor config save
```

**4. Update Docker Images:**

```bash
# Pull latest images
tutor images pull all

# Or rebuild custom images
tutor images build all
```

**5. Run Database Migrations:**

```bash
tutor local do init --limit=reindex-courseware-student-progress
```

**6. Restart Services:**

```bash
tutor local restart
```

**7. Verify Update:**

```bash
# Check service health
tutor local status

# Test platform access
curl -I http://courses.trigger-project.eu

# Check logs for errors
tutor local logs -f | grep -i error
```

### Update Plugins

**Update All Plugins:**

```bash
tutor plugins update
```

**Update Specific Plugin:**

```bash
pip install --upgrade tutor-discovery
tutor plugins enable discovery
tutor config save
tutor images build openedx-dev
tutor local restart
```

### Rollback After Failed Update

If update causes issues:

```bash
# Stop services
tutor local stop

# Restore from backup
./scripts/restore.sh ~/backups/pre-update-backup.tar.gz

# Start services
tutor local start -d
```

---

## Monitoring and Health Checks

### Service Health

**Check Service Status:**
```bash
# All services
tutor local status

# Specific service
docker ps | grep openedx
```

**Check Service Logs:**
```bash
# All logs
tutor local logs -f

# LMS only
tutor local logs -f lms

# Last 100 lines with errors
tutor local logs --tail=100 | grep -i error
```

### System Resources

**Disk Space:**
```bash
# Overall disk usage
df -h

# Docker disk usage
docker system df

# Tutor data size
du -sh ~/trigger-course/env/data/
```

**Memory Usage:**
```bash
# System memory
free -h

# Docker container memory
docker stats --no-stream
```

**CPU Usage:**
```bash
# Top processes
top

# Docker container CPU
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}"
```

### Database Health

**MySQL:**
```bash
# Connect to MySQL
tutor local exec mysql mysql -u root -p

# Check database size
tutor local exec mysql mysql -u root -p -e "SELECT table_schema 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
```

**MongoDB:**
```bash
# Connect to MongoDB
tutor local exec mongodb mongosh

# Check database stats
tutor local exec mongodb mongosh --eval "db.stats()"
```

### Application Health

**Django Health Check:**
```bash
tutor local exec lms ./manage.py lms check
tutor local exec cms ./manage.py cms check
```

**Test Course Access:**
```bash
# LMS
curl -I http://courses.trigger-project.eu

# Studio
curl -I http://studio.trigger-project.eu
```

### Automated Monitoring

**Setup Monitoring Script:**

Create `~/scripts/health-check.sh`:

```bash
#!/bin/bash
# Health check script

# Check if services are running
if ! tutor local status | grep -q "Up"; then
  echo "ERROR: Services not running!" | mail -s "TRIGGER Alert" admin@trigger.eu
fi

# Check disk space (alert if >80%)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
  echo "WARNING: Disk usage at ${DISK_USAGE}%" | mail -s "TRIGGER Alert" admin@trigger.eu
fi

# Check memory (alert if >90%)
MEM_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
if [ $MEM_USAGE -gt 90 ]; then
  echo "WARNING: Memory usage at ${MEM_USAGE}%" | mail -s "TRIGGER Alert" admin@trigger.eu
fi
```

**Schedule Health Checks:**
```bash
# Run every 15 minutes
crontab -e
*/15 * * * * /home/ubuntu/scripts/health-check.sh
```

### CloudWatch Integration (AWS)

**Install CloudWatch Agent:**
```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Configure
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

**Monitor Metrics:**
- CPU Utilization
- Memory Usage
- Disk I/O
- Network Traffic
- Custom application logs

---

## Database Maintenance

### Optimize Database

**MySQL:**
```bash
# Analyze tables
tutor local exec mysql mysqlcheck -u root -p --analyze --all-databases

# Optimize tables
tutor local exec mysql mysqlcheck -u root -p --optimize --all-databases
```

**MongoDB:**
```bash
# Compact database
tutor local exec mongodb mongosh --eval "db.runCommand({compact: 'collection_name'})"
```

### Clean Old Data

**Remove Old Logs:**
```bash
# Clean Docker logs
docker system prune -f

# Clean application logs
find ~/trigger-course/env/data/lms/logs/ -name "*.log" -mtime +30 -delete
```

**Remove Inactive Users:**
```bash
# List inactive users (no login in 6 months)
tutor local exec lms ./manage.py lms shell -c "
from django.contrib.auth import get_user_model
from datetime import datetime, timedelta
User = get_user_model()
inactive = User.objects.filter(last_login__lt=datetime.now()-timedelta(days=180))
print(f'Found {inactive.count()} inactive users')
"
```

### Database Backup and Vacuum

**Weekly Maintenance:**
```bash
# Backup before maintenance
./scripts/backup.sh

# Vacuum MySQL
tutor local exec mysql mysqlcheck -u root -p --auto-repair --all-databases

# Compact MongoDB
tutor local exec mongodb mongosh --eval "db.adminCommand({repairDatabase: 1})"
```

---

## Troubleshooting

### Common Issues

**Issue 1: Service Won't Start**

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check container logs
tutor local logs -f

# Restart Tutor services
tutor local restart
```

**Issue 2: Out of Disk Space**

```bash
# Clean Docker system
docker system prune -a

# Remove old backups
find ~/backups/ -mtime +30 -delete

# Clean temporary files
sudo apt clean
```

**Issue 3: Database Connection Issues**

```bash
# Check database service
tutor local logs -f mysql

# Restart database
tutor local restart mysql

# Check database connectivity
tutor local exec lms ./manage.py lms dbshell
```

**Issue 4: SSL Certificate Expired**

```bash
# Renew certificate
sudo certbot renew

# Or with Tutor
tutor local restart caddy
```

**Issue 5: Slow Performance**

```bash
# Check resource usage
htop
docker stats

# Restart services
tutor local restart

# Scale up workers (if needed)
tutor config save --set OPENEDX_LMS_UWSGI_WORKERS=8
tutor local restart
```

### Log Analysis

**Find Errors:**
```bash
# Recent errors
tutor local logs --tail=1000 | grep -i "error\|exception\|critical"

# Errors by service
tutor local logs lms | grep -i error
tutor local logs cms | grep -i error
```

**Monitor Logs in Real-time:**
```bash
# All logs
tutor local logs -f

# Filter for errors
tutor local logs -f | grep -i error
```

---

## Security Best Practices

### Regular Security Tasks

**1. Update System:**
```bash
# Weekly updates
sudo apt update && sudo apt upgrade -y
sudo reboot  # if kernel updated
```

**2. Review User Accounts:**
```bash
# List superusers
tutor local exec lms ./manage.py lms shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
for user in User.objects.filter(is_superuser=True):
    print(f'{user.username} - {user.email}')
"
```

**3. Check for Security Updates:**
```bash
# Tutor security updates
pip list --outdated | grep tutor

# System security updates
sudo apt list --upgradable | grep -i security
```

**4. Review Access Logs:**
```bash
# Check failed login attempts
tutor local logs lms | grep "Failed login"

# Check admin access
tutor local logs lms | grep "/admin"
```

### Firewall Configuration

```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH (change port if needed)
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

### SSL/TLS Management

```bash
# Check certificate expiration
echo | openssl s_client -servername courses.trigger-project.eu -connect courses.trigger-project.eu:443 2>/dev/null | openssl x509 -noout -dates

# Renew certificates (Let's Encrypt)
sudo certbot renew

# Test certificate
sudo certbot renew --dry-run
```

---

## Performance Optimization

### Docker Optimization

**Increase Resources:**
- Docker Desktop: Settings → Resources
- Minimum 8GB RAM, 4 CPU cores
- 50GB+ disk space

**Cleanup:**
```bash
# Remove unused containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f
```

### Application Tuning

**Increase Workers:**
```bash
tutor config save --set OPENEDX_LMS_UWSGI_WORKERS=4
tutor config save --set OPENEDX_CMS_UWSGI_WORKERS=2
tutor local restart
```

**Enable Caching:**
```bash
# Redis already enabled by default in Tutor
# Verify Redis is running
docker ps | grep redis
```

### Database Optimization

**MySQL:**
```bash
# Edit MySQL configuration
tutor config save --set MYSQL_CONF_MAX_CONNECTIONS=200
tutor local restart mysql
```

**MongoDB:**
```bash
# Enable compression
tutor local exec mongodb mongosh --eval "db.adminCommand({setParameter: 1, wireObjectCheck: false})"
```

### CDN for Static Files

Consider using CloudFront or CloudFlare for:
- Course images
- Video content
- Static assets (CSS, JS)

---

## Maintenance Checklist

### Daily
- [ ] Check service status
- [ ] Monitor disk space
- [ ] Review error logs

### Weekly
- [ ] Verify backups completed
- [ ] Review system logs
- [ ] Check resource usage
- [ ] Test backup restore (on test environment)

### Monthly
- [ ] Update system packages
- [ ] Update Tutor and plugins
- [ ] Review security logs
- [ ] Database optimization
- [ ] Check SSL certificates
- [ ] Review user accounts

### Quarterly
- [ ] Full disaster recovery test
- [ ] Security audit
- [ ] Performance review
- [ ] Cost optimization review
- [ ] Update documentation

---

## Support and Resources

### Getting Help

**Tutor Community:**
- Forum: https://discuss.overhang.io/
- Documentation: https://docs.tutor.overhang.io/
- GitHub: https://github.com/overhangio/tutor

**Open edX Community:**
- Documentation: https://docs.openedx.org/
- Forum: https://discuss.openedx.org/

**TRIGGER Project:**
- Website: https://trigger-project.eu/
- Technical Support: [Add contact]

---

**Previous:** [Usage Guide](usage.md) | **Back to:** [README](../README.md)
