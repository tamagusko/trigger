# Local Setup Guide

This guide will walk you through installing and configuring Open edX locally using Tutor and Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install Docker](#install-docker)
3. [Install Tutor](#install-tutor)
4. [Configure Open edX](#configure-open-edx)
5. [Launch the Platform](#launch-the-platform)
6. [Create Your First User](#create-your-first-user)
7. [Enable Plugins](#enable-plugins)
8. [Common Issues](#common-issues)

---

## Prerequisites

Before starting, ensure your computer meets these requirements:

- **Operating System:** macOS, Windows 10/11, or Linux
- **RAM:** 8GB minimum (16GB recommended)
- **Storage:** 20GB free space
- **Internet:** Stable connection for downloading Docker images

---

## Install Docker

Docker is required to run Open edX. Follow the instructions for your operating system:

### macOS

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Open the downloaded `.dmg` file
3. Drag Docker to your Applications folder
4. Launch Docker Desktop from Applications
5. Wait for Docker to start (you'll see a whale icon in your menu bar)

**Configure Docker Resources:**
- Click the Docker whale icon in the menu bar
- Select "Preferences" → "Resources"
- Set Memory to at least 8GB (16GB recommended)
- Set CPUs to at least 2 (4 recommended)
- Click "Apply & Restart"

### Windows

1. Enable WSL 2 (Windows Subsystem for Linux):
   - Open PowerShell as Administrator
   - Run: `wsl --install`
   - Restart your computer

2. Download Docker Desktop from https://www.docker.com/products/docker-desktop
3. Run the installer
4. Launch Docker Desktop
5. Follow the setup wizard

**Configure Docker Resources:**
- Right-click the Docker icon in the system tray
- Select "Settings" → "Resources"
- Set Memory to at least 8GB (16GB recommended)
- Set CPUs to at least 2 (4 recommended)
- Click "Apply & Restart"

### Linux

Install Docker Engine:

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

**Verify Docker Installation:**

```bash
docker --version
docker compose version
```

---

## Install Tutor

Tutor is the easiest way to run Open edX. We'll use the automated setup script.

### Option 1: Automated Installation (Recommended)

From the project root directory, run:

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

This script will:
- Install Tutor
- Configure the environment
- Set up plugins
- Launch the platform

Skip to [Create Your First User](#create-your-first-user) if using this method.

### Option 2: Manual Installation

If you prefer to install manually, follow these steps:

**macOS/Linux:**

```bash
# Install Tutor using pip
python3 -m pip install --user "tutor[full]"

# Add Tutor to your PATH (add this to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"

# Reload your shell configuration
source ~/.bashrc  # or source ~/.zshrc for zsh
```

**Windows:**

```powershell
# Open PowerShell and run:
pip install "tutor[full]"
```

**Verify Installation:**

```bash
tutor --version
```

You should see the Tutor version (e.g., `Tutor 17.0.0`).

---

## Configure Open edX

### Initialize Tutor

Navigate to the project's `env/` directory and initialize Tutor:

```bash
cd env
tutor config save --interactive
```

You'll be prompted to configure several settings. Here are recommended values:

| Setting | Recommended Value | Description |
|---------|-------------------|-------------|
| Release | `palm` or latest | Open edX release version |
| LMS Domain | `local.overhang.io` | Main platform URL (default for local) |
| CMS Domain | `studio.local.overhang.io` | Course authoring URL |
| Platform name | `TRIGGER` | Your platform name |
| Contact email | `admin@trigger.eu` | Admin contact email |

**Important Notes:**

- For local development, use the default domains (`local.overhang.io` and `studio.local.overhang.io`)
- These domains automatically resolve to `127.0.0.1` without modifying `/etc/hosts`
- For production deployment, you'll use your actual domain names

### Advanced Configuration (Optional)

Edit the configuration file directly:

```bash
tutor config save
nano config.yml  # or use your preferred editor
```

Common configuration options:

```yaml
# Platform branding
PLATFORM_NAME: "TRIGGER"
CONTACT_EMAIL: "admin@trigger.eu"

# Language and timezone
LANGUAGE_CODE: en
TIME_ZONE: Europe/Dublin

# Enable/disable features
ENABLE_HTTPS: false  # true for production
ENABLE_WEB_PROXY: true

# Resource limits (optional)
DOCKER_IMAGE_OPENEDX: "docker.io/overhangio/openedx:17.0.0"
```

---

## Launch the Platform

### Build Docker Images

Build the Open edX Docker images (this may take 15-30 minutes):

```bash
tutor images build openedx
```

### Initialize the Database

Set up the database and create initial data:

```bash
tutor local do init
```

This command will:
- Create database tables
- Run migrations
- Create default site configuration
- Set up OAuth2 applications

**Note:** You'll be prompted to create a superuser during this step. Remember the credentials!

### Start the Platform

Launch all services:

```bash
tutor local start -d
```

The `-d` flag runs services in detached mode (background).

**Verify Services are Running:**

```bash
tutor local status
```

You should see all services showing as "Up".

### Access the Platform

Open your web browser and navigate to:

- **LMS (Student View):** http://local.overhang.io
- **Studio (Course Authoring):** http://studio.local.overhang.io
- **Admin Panel:** http://local.overhang.io/admin

**First Launch Notes:**

- Initial page load may take 1-2 minutes
- You may see a "502 Bad Gateway" error initially - wait and refresh
- Clear your browser cache if you see styling issues

---

## Create Your First User

### Create a Superuser (Admin)

```bash
tutor local do createuser --staff --superuser admin admin@trigger.eu
```

You'll be prompted to set a password. This user will have full administrative access.

### Create a Regular User

```bash
tutor local do createuser student student@example.com
```

### Create Users via Web Interface

1. Go to http://local.overhang.io/register
2. Fill in the registration form
3. Check the logs for the activation email:
   ```bash
   tutor local logs -f lms
   ```
4. Look for the activation link in the logs and open it in your browser

---

## Enable Plugins

Tutor supports plugins to extend Open edX functionality. The automated setup script enables these by default:

### List Available Plugins

```bash
tutor plugins list
```

### Enable Plugins Manually

**Discovery (Course Catalog):**
```bash
tutor plugins enable discovery
tutor local do init -p discovery
```

**E-commerce:**
```bash
tutor plugins enable ecommerce
tutor local do init -p ecommerce
```

**Forum (Discussions):**
```bash
tutor plugins enable forum
tutor local do init -p forum
```

**Micro-Frontends (Modern UI):**
```bash
tutor plugins enable mfe
tutor config save
tutor images build mfe
tutor local do init -p mfe
```

### Restart After Enabling Plugins

```bash
tutor local restart
```

---

## Common Issues

### Issue: "502 Bad Gateway"

**Cause:** Services are still starting up

**Solution:**
- Wait 2-3 minutes after running `tutor local start`
- Check service status: `tutor local status`
- View logs: `tutor local logs -f`

### Issue: "Port already in use"

**Cause:** Another service is using ports 80 or 443

**Solution:**
```bash
# Check what's using the port
sudo lsof -i :80

# Stop the conflicting service or configure Tutor to use different ports
tutor config save --set WEB_PROXY_HTTP_PORT=8080
tutor local restart
```

### Issue: Not Enough Memory

**Cause:** Docker doesn't have enough RAM allocated

**Solution:**
- Increase Docker memory allocation to at least 8GB
- Close other applications
- Restart Docker Desktop

### Issue: "Cannot connect to Docker daemon"

**Cause:** Docker is not running

**Solution:**
- Start Docker Desktop
- Verify Docker is running: `docker ps`
- On Linux, ensure your user is in the docker group

### Issue: Database Connection Errors

**Cause:** Database container not ready

**Solution:**
```bash
# Stop all services
tutor local stop

# Remove volumes (WARNING: This deletes data!)
tutor local do volumes purge

# Reinitialize
tutor local do init
tutor local start -d
```

### Issue: Slow Performance

**Possible Causes:**
- Insufficient RAM allocated to Docker
- Disk space running low
- Too many plugins enabled

**Solutions:**
- Increase Docker resources
- Free up disk space
- Disable unused plugins:
  ```bash
  tutor plugins disable <plugin-name>
  tutor local restart
  ```

---

## Next Steps

Now that your platform is running:

1. **Create Courses** - See [usage.md](usage.md)
2. **Deploy to Production** - See [deploy.md](deploy.md)
3. **Set Up Backups** - See [maintenance.md](maintenance.md)

---

## Useful Commands Reference

```bash
# Start platform
tutor local start -d

# Stop platform
tutor local stop

# Restart platform
tutor local restart

# View logs
tutor local logs -f

# View logs for specific service
tutor local logs -f lms

# Execute commands in LMS container
tutor local exec lms bash

# Update Tutor
pip install --upgrade "tutor[full]"

# Rebuild images after configuration changes
tutor images build openedx

# Check configuration
tutor config printroot
tutor config printvalue LMS_HOST
```

---

## Support

If you encounter issues not covered here:

1. Check Tutor documentation: https://docs.tutor.overhang.io/
2. Visit the Tutor forum: https://discuss.overhang.io/
3. Review Docker logs: `tutor local logs -f`
4. Check Docker resource allocation

---

**Next:** [Deploy to AWS](deploy.md) | [Usage Guide](usage.md) | [Maintenance](maintenance.md)
