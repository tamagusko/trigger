# First Run Guide

Welcome! This guide will help you get TRIGGER Open edX running on your computer for the first time.

## ⏱️ Time Required

**Total time:** 1-2 hours
- Setup: 30-45 minutes
- Testing: 15-30 minutes

## 📋 Before You Start

### What You Need

1. **Computer Requirements:**
   - macOS, Windows 10/11, or Linux
   - 8GB+ RAM (16GB recommended)
   - 20GB+ free disk space
   - Stable internet connection

2. **Software to Install:**
   - Docker Desktop (we'll help you install this)
   - Nothing else! The script handles everything

### What You'll Get

After completing this guide, you'll have:
- ✅ A fully functional Open edX platform running locally
- ✅ Access to the Learning Management System (LMS)
- ✅ Access to Studio (course authoring tool)
- ✅ An admin account to manage everything

---

## 🚀 Step-by-Step Instructions

### Step 1: Install Docker Desktop (15 minutes)

Docker is required to run Open edX. Choose your operating system:

#### macOS

1. **Download Docker Desktop:**
   - Visit: https://www.docker.com/products/docker-desktop
   - Click "Download for Mac"
   - Choose the right version:
     - **Apple Silicon (M1/M2/M3):** Choose "Apple Chip"
     - **Intel Mac:** Choose "Intel Chip"

2. **Install:**
   - Open the downloaded `.dmg` file
   - Drag Docker icon to Applications folder
   - Open Docker from Applications

3. **Configure Resources:**
   - Click Docker icon in menu bar (whale icon)
   - Select "Settings" → "Resources"
   - Set **Memory to 8GB** (or more)
   - Set **CPUs to 4** (or more)
   - Click "Apply & Restart"

4. **Verify:**
   ```bash
   docker --version
   # Should show: Docker version 24.x.x or higher
   ```

#### Windows

1. **Enable WSL 2:**
   - Open PowerShell as Administrator
   - Run: `wsl --install`
   - Restart your computer

2. **Download Docker Desktop:**
   - Visit: https://www.docker.com/products/docker-desktop
   - Click "Download for Windows"
   - Run the installer

3. **Configure Resources:**
   - Right-click Docker icon in system tray
   - Select "Settings" → "Resources"
   - Set **Memory to 8GB** (or more)
   - Set **CPUs to 4** (or more)
   - Click "Apply & Restart"

4. **Verify:**
   ```powershell
   docker --version
   # Should show: Docker version 24.x.x or higher
   ```

#### Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in for changes to take effect
```

**Verify:**
```bash
docker --version
# Should show: Docker version 24.x.x or higher
```

---

### Step 2: Download TRIGGER (2 minutes)

Open your terminal (or Command Prompt on Windows) and run:

```bash
# Clone the repository
git clone https://github.com/tamagusko/trigger.git

# Enter the directory
cd trigger

# List contents to verify
ls
```

**You should see:**
```
CONTRIBUTING.md  LICENSE  README.md  docs/  env/  scripts/
```

---

### Step 3: Run the Setup Script (30-45 minutes)

This is the main step. The script will download and configure everything automatically.

```bash
# Make the script executable (first time only)
chmod +x scripts/setup.sh

# Run the setup
./scripts/setup.sh
```

**What happens during setup:**

1. **Prerequisites Check** (~1 minute)
   ```
   ✓ Docker is installed
   ✓ Docker is running
   ✓ Python 3 is installed
   ✓ Sufficient disk space available
   ```

2. **Installing Tutor** (~5 minutes)
   ```
   Installing Tutor...
   ✓ Tutor installed: Tutor 17.0.0
   ```

3. **Configuration** (~1 minute)
   ```
   Configuring for LOCAL development
   ✓ Tutor configuration complete
   ```

4. **Building Docker Images** (~15-30 minutes) ⏰
   ```
   Building Docker images...
   This may take 15-30 minutes...
   [Progress bars showing downloads and builds]
   ✓ Docker images built successfully
   ```

   **This is the longest step!** The script is downloading and building all necessary software. You can:
   - Leave it running in the background
   - Check progress in Docker Desktop
   - Get a coffee ☕

5. **Initializing Platform** (~10-15 minutes)
   ```
   Initializing Platform...
   Setting up database and running migrations...
   ✓ Platform initialized successfully
   ```

6. **Enabling Plugins** (~2 minutes)
   ```
   Enabling discovery plugin...
   ✓ Discovery plugin enabled
   ```

7. **Starting Services** (~2 minutes)
   ```
   Starting all services...
   ✓ All services started
   ```

**When complete, you'll see:**
```
==================================================
✓ Installation Complete!
==================================================

Access your platform at:
  LMS (Students):  http://local.overhang.io
  Studio (Authoring): http://studio.local.overhang.io

Next steps:
  1. Create an admin user:
     cd env
     tutor local do createuser --staff --superuser admin admin@trigger.eu
```

---

### Step 4: Create Your Admin Account (2 minutes)

After setup completes, create an admin account:

```bash
# Navigate to env directory
cd env

# Create admin user
tutor local do createuser --staff --superuser admin admin@trigger.eu
```

**You'll be prompted for:**
- Password (choose something secure)
- Full name (enter your name)

**Example interaction:**
```
Password: ********
Password (again): ********
Full name: John Doe
✓ User admin created successfully
```

---

### Step 5: Access Your Platform (1 minute)

Open your web browser and visit:

**For Students (LMS):**
- URL: http://local.overhang.io
- You should see the Open edX homepage

**For Course Authors (Studio):**
- URL: http://studio.local.overhang.io
- You should see the Studio login page

**Admin Panel:**
- URL: http://local.overhang.io/admin
- Log in with your admin credentials

**First page load may take 1-2 minutes.** If you see "502 Bad Gateway", wait a moment and refresh.

---

## ✅ Testing Your Installation

Let's verify everything works correctly.

### Test 1: Check Services (1 minute)

```bash
# From the env/ directory
tutor local status
```

**Expected output:**
```
Name                  Status
lms                   Up
cms                   Up
mysql                 Up
mongodb               Up
redis                 Up
...
```

All services should show "Up".

### Test 2: View Logs (2 minutes)

```bash
# Check logs for errors
tutor local logs --tail=50
```

**Look for:**
- ✅ No "ERROR" or "CRITICAL" messages
- ✅ Services starting successfully
- ❌ If you see errors, see Troubleshooting below

### Test 3: Log In (2 minutes)

1. **Visit:** http://local.overhang.io
2. **Click:** "Sign In" (top right)
3. **Enter:**
   - Username: `admin`
   - Password: (what you set earlier)
4. **Success:** You should see your profile

### Test 4: Access Studio (2 minutes)

1. **Visit:** http://studio.local.overhang.io
2. **Log in** with same credentials
3. **Success:** You should see the Studio dashboard

### Test 5: Create a Test Course (5 minutes)

1. **In Studio**, click "+ New Course"
2. **Fill in:**
   - Course Name: `Test Course`
   - Organization: `TRIGGER`
   - Course Number: `TEST101`
   - Course Run: `2024`
3. **Click:** "Create"
4. **Success:** You should see your new course in Studio

---

## 🎉 Success!

If all tests passed, congratulations! You now have:
- ✅ Open edX running locally
- ✅ Access to LMS and Studio
- ✅ Admin account created
- ✅ Ability to create courses

---

## 🔧 Common Issues and Solutions

### Issue: "Docker is not running"

**Solution:**
```bash
# Start Docker Desktop
# - macOS: Open Docker from Applications
# - Windows: Open Docker Desktop from Start Menu
# - Linux: sudo systemctl start docker

# Wait 30 seconds, then try again
./scripts/setup.sh
```

### Issue: "502 Bad Gateway" in Browser

**Solution:**
This is normal during first startup. Services are still initializing.

```bash
# Wait 2-3 minutes
# Check service status
cd env
tutor local status

# View logs to see progress
tutor local logs -f
```

### Issue: "Port already in use"

**Solution:**
Another service is using port 80.

```bash
# Find what's using port 80
sudo lsof -i :80

# Stop that service, or configure Tutor to use different port
cd env
tutor config save --set WEB_PROXY_HTTP_PORT=8080
tutor local restart
```

### Issue: "Out of disk space"

**Solution:**
```bash
# Clean Docker
docker system prune -a

# Free up disk space
# Delete unused files/applications

# Check available space
df -h
```

### Issue: Script stops or freezes

**Solution:**
```bash
# Press Ctrl+C to stop
# Check Docker Desktop is running
# Try again
./scripts/setup.sh
```

### Issue: "Cannot connect to Docker daemon"

**Solution:**
```bash
# Restart Docker Desktop
# On Linux:
sudo systemctl restart docker

# Verify Docker is running
docker ps
```

---

## 📱 What's Next?

Now that your platform is running, you can:

### Learn to Create Courses
📖 **Read:** [Usage Guide](usage.md)
- How to create course content
- Add videos, text, and quizzes
- Manage students
- Set up grading

### Deploy to Production
☁️ **Read:** [Deployment Guide](deploy.md)
- Deploy to AWS
- Configure domains
- Set up SSL/HTTPS
- Production best practices

### Set Up Backups
💾 **Read:** [Maintenance Guide](maintenance.md)
- Create backups
- Schedule automatic backups
- Restore from backup
- Update the platform

---

## 🛠️ Useful Commands

Keep these handy for daily use:

```bash
# Always run these from the env/ directory
cd env

# Start platform
tutor local start -d

# Stop platform
tutor local stop

# Restart platform
tutor local restart

# View all logs
tutor local logs -f

# View specific service logs
tutor local logs -f lms
tutor local logs -f cms

# Check service status
tutor local status

# Create new user
tutor local do createuser USERNAME EMAIL

# Access container shell
tutor local exec lms bash

# Update platform
cd ..
./scripts/update.sh

# Create backup
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh backups/backup-file.tar.gz
```

---

## 📚 Additional Resources

### Documentation
- **Setup Guide:** Detailed installation instructions
- **Testing Guide:** How to test scripts before using
- **Usage Guide:** Creating and managing courses
- **Deployment Guide:** AWS deployment instructions
- **Maintenance Guide:** Backups, updates, troubleshooting

### External Resources
- **Tutor Documentation:** https://docs.tutor.overhang.io/
- **Open edX Documentation:** https://docs.openedx.org/
- **Tutor Forum:** https://discuss.overhang.io/
- **Docker Documentation:** https://docs.docker.com/

### Getting Help

If you're stuck:

1. **Check logs:**
   ```bash
   cd env
   tutor local logs -f | grep -i error
   ```

2. **Search documentation:**
   - Check docs/ folder
   - Visit Tutor documentation
   - Search Tutor forum

3. **Ask for help:**
   - Open GitHub issue
   - Post on Tutor forum
   - Contact TRIGGER team

---

## 💡 Tips for Success

1. **Be patient:** First setup takes time (30-45 minutes)
2. **Check resources:** Ensure Docker has 8GB+ RAM
3. **Wait for services:** First page load can take 2-3 minutes
4. **Save your password:** You'll need it to log in
5. **Bookmark URLs:** Keep LMS and Studio URLs handy
6. **Regular backups:** Use `./scripts/backup.sh` weekly
7. **Read docs:** Check usage.md before creating courses

---

## 🎓 Learning Path

**Week 1: Setup and Exploration**
1. Complete this guide
2. Explore the LMS and Studio interfaces
3. Create a test course
4. Add basic content

**Week 2: Course Creation**
1. Read the Usage Guide
2. Plan your first real course
3. Create course structure
4. Add initial content

**Week 3: Advanced Features**
1. Add videos and interactive content
2. Set up grading
3. Configure discussions
4. Test student experience

**Week 4: Deployment**
1. Test backups
2. Read Deployment Guide
3. Plan production deployment
4. Deploy to AWS (if needed)

---

## ✨ Congratulations!

You've successfully set up your TRIGGER Open edX platform! 🎉

You're now ready to:
- Create engaging online courses
- Manage students and content
- Build your educational platform

**Need help?** Check the docs/ folder or open an issue on GitHub.

**Ready to learn more?** Continue to the [Usage Guide](usage.md) to start creating courses!

---

**TRIGGER Project** | Empowering Education Through Technology
