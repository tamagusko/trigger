# Testing Guide for TRIGGER Scripts

This guide explains how to test all the helper scripts safely before using them in production.

## Prerequisites

Before testing, ensure you have:

- [ ] Docker Desktop installed and running
- [ ] At least 8GB RAM allocated to Docker
- [ ] 20GB+ free disk space
- [ ] Python 3 installed (`python3 --version`)
- [ ] pip3 installed (`pip3 --version`)
- [ ] Internet connection (for downloading images)

## Testing Environment Setup

### Check Your System

```bash
# Navigate to project directory
cd /Users/tamagusko/repos/UCD/TRIGGER_course

# Check Docker
docker --version
docker ps

# Check Docker resources
docker info | grep -E "CPUs|Total Memory"

# Check disk space
df -h .

# Check Python
python3 --version
pip3 --version
```

### Expected Output Example

```
Docker version 24.0.7
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

CPUs: 4
Total Memory: 16GiB

Filesystem      Size   Used  Avail Capacity
/dev/disk1s1   500G   100G  380G    21%

Python 3.11.6
pip 23.3.1
```

---

## Testing setup.sh

This is the main script that installs Tutor and Open edX. It's safe to test on your local machine.

### Step 1: Dry Run Check

First, check if the script has any syntax errors:

```bash
bash -n scripts/setup.sh
```

If no output appears, the syntax is correct.

### Step 2: View Help

```bash
./scripts/setup.sh --help
```

**Expected output:**
```
Usage: ./scripts/setup.sh [OPTIONS]

Options:
  --production       Set up for production deployment
  --domain DOMAIN    Set domain name (e.g., trigger-project.eu)
  --help             Show this help message
```

### Step 3: Run Local Setup (Safe Test)

**Time required:** 30-45 minutes

```bash
# Run the setup for local development
./scripts/setup.sh
```

**What will happen:**

1. **Prerequisites check** (~1 min)
   - Checks Docker, Python, disk space
   - You'll see green checkmarks ✓ for each

2. **Tutor installation** (~2-5 min)
   - Installs Tutor via pip
   - Adds to PATH

3. **Configuration** (~1 min)
   - Creates `env/config.yml`
   - Sets local domains

4. **Building images** (~15-30 min)
   - Downloads and builds Docker images
   - This is the longest step
   - You'll see build progress

5. **Initializing platform** (~10-15 min)
   - Creates databases
   - Runs migrations
   - You'll be prompted to create a superuser

6. **Starting services** (~2-3 min)
   - Starts all containers
   - Shows service status

**Monitor the process:**

Open a second terminal and watch:
```bash
# In another terminal
watch docker ps
```

### Step 4: Verify Installation

After setup completes:

```bash
# Check services are running
cd env
tutor local status

# Expected output: All services should show "Up"
```

```bash
# Check service logs
tutor local logs --tail=20

# Should see no critical errors
```

```bash
# Test access
curl -I http://local.overhang.io
# Should return: HTTP/1.1 200 OK
```

### Step 5: Access the Platform

Open in browser:
- **LMS:** http://local.overhang.io
- **Studio:** http://studio.local.overhang.io

You should see the Open edX login page.

### Step 6: Create Test User

```bash
cd env
tutor local do createuser --staff --superuser testadmin test@example.com
# Enter password when prompted
```

Log in with these credentials at http://local.overhang.io/admin

---

## Testing backup.sh

Only test backup **after** setup.sh completes successfully.

### Step 1: Check Script Syntax

```bash
bash -n scripts/backup.sh
```

### Step 2: View Help

```bash
./scripts/backup.sh --help
```

### Step 3: Create a Test Backup

**Time required:** 5-15 minutes

```bash
./scripts/backup.sh
```

**What will happen:**

1. Prerequisites check
2. Database backup (MySQL, MongoDB)
3. Course data backup
4. Configuration backup
5. Creates compressed archive in `backups/`

**Expected output:**
```
==================================================
TRIGGER Open edX Backup - [timestamp]
==================================================

✓ Prerequisites check complete
ℹ Backing up databases...
✓   MySQL backup complete (15M)
✓   MongoDB backup complete (8M)
✓ Configuration backed up
✓ Course data backed up (120M)
✓ Backup archive created: trigger-backup-20240115.tar.gz (45M)

==================================================
✓ Backup Complete!
==================================================
```

### Step 4: Verify Backup

```bash
# List backups
ls -lh backups/

# Check backup contents
tar -tzf backups/trigger-backup-*.tar.gz | head -20

# Expected: Should list mysql.sql, mongodb.archive, config.yml, etc.
```

### Step 5: Test Backup with S3 (Optional)

Only if you have AWS credentials configured:

```bash
# Configure AWS first
aws configure

# Then backup to S3
./scripts/backup.sh --s3 your-bucket-name
```

---

## Testing restore.sh

**⚠️ WARNING:** This will replace your current data. Only test after making a backup!

### Step 1: Ensure You Have a Backup

```bash
ls -lh backups/
# Should show at least one backup file
```

### Step 2: Make Note of Current State

```bash
# Check current admin users
cd env
tutor local exec lms ./manage.py lms shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print('Users:', User.objects.count())"
```

### Step 3: Create Test Content

1. Log in to Studio: http://studio.local.overhang.io
2. Create a test course
3. Add some content
4. Note the course name

### Step 4: Create Another Backup

```bash
./scripts/backup.sh
# This captures your test content
```

### Step 5: Make a Change

1. Delete the test course OR
2. Create a new user

### Step 6: Test Restore

**Time required:** 10-20 minutes

```bash
# Find your backup
BACKUP_FILE=$(ls -t backups/trigger-backup-*.tar.gz | head -1)

# Restore from backup
./scripts/restore.sh $BACKUP_FILE
```

**What will happen:**

1. Warning message (type 'yes' to confirm)
2. Creates safety backup
3. Stops services
4. Restores databases
5. Restores course data
6. Starts services
7. Verifies restore

### Step 7: Verify Restore

```bash
# Check services
cd env
tutor local status

# Check if your test content is back
# Visit http://studio.local.overhang.io
```

---

## Testing update.sh

**⚠️ Test this last**, after confirming backup and restore work.

### Step 1: Check Current Versions

```bash
cd env
tutor --version
tutor config printvalue OPENEDX_COMMON_VERSION
```

### Step 2: View Help

```bash
cd ..
./scripts/update.sh --help
```

### Step 3: Run Update

**Time required:** 30-45 minutes

```bash
./scripts/update.sh
```

**What will happen:**

1. Creates pre-update backup
2. Shows current versions
3. Updates system packages (on Linux)
4. Updates Tutor
5. Updates plugins
6. Updates Docker images
7. Runs migrations
8. Restarts services
9. Verifies update

### Step 4: Verify Update

```bash
# Check new versions
cd env
tutor --version

# Check services
tutor local status

# Test platform access
curl -I http://local.overhang.io
```

---

## Quick Test Sequence

If you want to test everything quickly:

```bash
# 1. Setup (30-45 min)
./scripts/setup.sh

# 2. Create test user
cd env
tutor local do createuser --staff --superuser test test@example.com
cd ..

# 3. Backup (5-15 min)
./scripts/backup.sh

# 4. Verify backup exists
ls -lh backups/

# 5. Restore test (10-20 min)
./scripts/restore.sh backups/trigger-backup-*.tar.gz

# 6. Update test (30-45 min)
./scripts/update.sh --skip-backup

# Total time: ~1.5-2 hours
```

---

## Troubleshooting Tests

### setup.sh Issues

**Problem:** "Docker is not running"
```bash
# Start Docker Desktop
open -a Docker  # macOS
# Or open Docker Desktop app manually
```

**Problem:** "Not enough disk space"
```bash
# Clean Docker
docker system prune -a

# Free up disk space
df -h
```

**Problem:** Build fails
```bash
# Check logs
cd env
tutor local logs -f

# Try rebuilding
tutor images build openedx
```

### backup.sh Issues

**Problem:** "Services not running"
```bash
cd env
tutor local start -d
sleep 30
cd ..
./scripts/backup.sh
```

**Problem:** "Permission denied"
```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

### restore.sh Issues

**Problem:** "Backup file not found"
```bash
# Check exact filename
ls backups/

# Use full path
./scripts/restore.sh backups/trigger-backup-20240115-143022.tar.gz
```

**Problem:** Restore fails midway
```bash
# Stop services
cd env
tutor local stop

# Clean and retry
tutor local dc down -v
cd ..
./scripts/restore.sh backups/your-backup.tar.gz
```

---

## Testing Checklist

Use this checklist to track your testing:

### Prerequisites
- [ ] Docker installed and running
- [ ] 8GB+ RAM allocated
- [ ] 20GB+ disk space available
- [ ] Python 3 and pip3 installed

### setup.sh
- [ ] Syntax check passes
- [ ] Help displays correctly
- [ ] Script runs without errors
- [ ] All services start successfully
- [ ] Can access http://local.overhang.io
- [ ] Can create admin user
- [ ] Can log in to platform

### backup.sh
- [ ] Syntax check passes
- [ ] Help displays correctly
- [ ] Backup completes successfully
- [ ] Backup file created in backups/
- [ ] Backup file contains expected files
- [ ] Backup size seems reasonable

### restore.sh
- [ ] Syntax check passes
- [ ] Help displays correctly
- [ ] Restore warning displays
- [ ] Safety backup created
- [ ] Restore completes successfully
- [ ] Services restart properly
- [ ] Data is restored correctly
- [ ] Platform accessible after restore

### update.sh
- [ ] Syntax check passes
- [ ] Help displays correctly
- [ ] Pre-update backup created
- [ ] Update completes successfully
- [ ] All services restart
- [ ] Platform accessible after update
- [ ] No critical errors in logs

---

## Clean Up After Testing

If you want to remove everything and start fresh:

```bash
# Stop all services
cd env
tutor local stop

# Remove all containers and volumes
tutor local dc down -v

# Remove Tutor data
cd ..
rm -rf env/data/

# Remove backups (optional)
rm -rf backups/

# Uninstall Tutor (optional)
pip3 uninstall tutor

# Clean Docker completely (optional)
docker system prune -a --volumes
```

---

## Next Steps After Successful Testing

Once all tests pass:

1. **Document any issues** you encountered
2. **Update scripts** if needed for your environment
3. **Create production deployment plan** using docs/deploy.md
4. **Set up automated backups** using cron
5. **Share testing results** with team

---

## Getting Help

If tests fail:

1. **Check logs:** `cd env && tutor local logs -f`
2. **Review documentation:** See docs/ directory
3. **Check Tutor docs:** https://docs.tutor.overhang.io/
4. **Open an issue:** With error messages and environment details

---

## Testing Notes

Record your testing results here:

**Date:**
**System:** (macOS/Linux/Windows)
**Docker Version:**
**Results:**
- setup.sh: ☐ Pass ☐ Fail
- backup.sh: ☐ Pass ☐ Fail
- restore.sh: ☐ Pass ☐ Fail
- update.sh: ☐ Pass ☐ Fail

**Issues encountered:**

**Time taken:**
- setup.sh: ___ minutes
- backup.sh: ___ minutes
- restore.sh: ___ minutes
- update.sh: ___ minutes
