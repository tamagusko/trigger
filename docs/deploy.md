# AWS Deployment Guide

This guide provides step-by-step instructions for deploying Open edX to AWS (Amazon Web Services). It's designed to be beginner-friendly and suitable for users with limited technical experience.

## Table of Contents

1. [Overview](#overview)
2. [AWS Account Setup](#aws-account-setup)
3. [Deployment Options](#deployment-options)
4. [Option 1: AWS Lightsail (Easiest)](#option-1-aws-lightsail-easiest)
5. [Option 2: AWS EC2 (Recommended)](#option-2-aws-ec2-recommended)
6. [Option 3: AWS ECS (Advanced)](#option-3-aws-ecs-advanced)
7. [Domain Configuration](#domain-configuration)
8. [SSL/HTTPS Setup](#sslhttps-setup)
9. [Post-Deployment Steps](#post-deployment-steps)
10. [Common Pitfalls](#common-pitfalls)

---

## Overview

### What You'll Need

- An AWS account (free tier available)
- A domain name (e.g., `courses.trigger-project.eu`)
- Credit card for AWS (even free tier requires one)
- 2-4 hours for initial setup

### Cost Estimates

| Option | Monthly Cost (Estimate) | Best For |
|--------|-------------------------|----------|
| Lightsail | $40-80 | Testing, small deployments |
| EC2 (t3.xlarge) | $120-150 | Production, 100-500 users |
| EC2 (t3.2xlarge) | $240-300 | Production, 500+ users |
| ECS | $150-250 | Large scale, auto-scaling |

**Note:** Costs vary based on usage, storage, and data transfer.

---

## AWS Account Setup

### Step 1: Create an AWS Account

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Fill in your email, password, and AWS account name
4. Provide contact information
5. Enter payment information (required even for free tier)
6. Verify your identity via phone
7. Choose the "Basic Support - Free" plan

### Step 2: Set Up Security

**Enable Multi-Factor Authentication (MFA):**

1. Sign in to the AWS Console: https://console.aws.amazon.com/
2. Click your account name (top right) → "Security Credentials"
3. Under "Multi-factor authentication (MFA)", click "Activate MFA"
4. Follow the setup wizard (use Google Authenticator or Authy app)

**Create an IAM User (Best Practice):**

1. Go to IAM service: https://console.aws.amazon.com/iam/
2. Click "Users" → "Add users"
3. User name: `trigger-admin`
4. Select "Provide user access to the AWS Management Console"
5. Attach the "AdministratorAccess" policy
6. Download the credentials CSV file
7. Use this user for daily operations (not the root account)

### Step 3: Choose Your AWS Region

Select a region close to your users:

- **Europe (Ireland):** `eu-west-1` - Good for EU users
- **Europe (Frankfurt):** `eu-central-1` - Central Europe
- **US East (N. Virginia):** `us-east-1` - North America
- **Asia Pacific (Singapore):** `ap-southeast-1` - Asia

**To change region:** Use the dropdown in the top-right corner of the AWS Console.

---

## Deployment Options

### Decision Matrix

Choose your deployment option based on your needs:

| Criteria | Lightsail | EC2 | ECS |
|----------|-----------|-----|-----|
| **Ease of Setup** | Easiest | Moderate | Complex |
| **Technical Skill Required** | Minimal | Basic Linux | Advanced |
| **Cost** | Fixed monthly | Flexible | Pay-per-use |
| **Scalability** | Limited | Manual | Automatic |
| **Best For** | Testing, demos | Most use cases | Large deployments |

---

## Option 1: AWS Lightsail (Easiest)

**Best for:** Testing, small deployments, non-technical users

### Step 1: Create a Lightsail Instance

1. Go to Lightsail: https://lightsail.aws.amazon.com/
2. Click "Create instance"
3. Select your region (e.g., `eu-west-1`)
4. Choose platform: "Linux/Unix"
5. Select blueprint: "OS Only" → "Ubuntu 20.04 LTS"
6. Choose a plan:
   - **$40/month:** 4 GB RAM, 2 vCPUs (minimum)
   - **$80/month:** 8 GB RAM, 2 vCPUs (recommended)
7. Name your instance: `trigger-openedx`
8. Click "Create instance"

### Step 2: Configure Networking

**Open Required Ports:**

1. Click on your instance name
2. Go to "Networking" tab
3. Under "IPv4 Firewall", add these rules:
   - HTTP: TCP, Port 80
   - HTTPS: TCP, Port 443
   - Custom: TCP, Port 18000 (LMS)
   - Custom: TCP, Port 18010 (Studio)

### Step 3: Connect to Your Instance

**Option A: Browser-based SSH (Easiest)**

1. Click "Connect using SSH" in the Lightsail console
2. A terminal window will open in your browser

**Option B: SSH from your computer**

1. Download the SSH key:
   - Click "Account" (top right) → "SSH keys"
   - Download the default key for your region
2. Connect from terminal:
   ```bash
   chmod 400 ~/Downloads/LightsailDefaultKey-eu-west-1.pem
   ssh -i ~/Downloads/LightsailDefaultKey-eu-west-1.pem ubuntu@<YOUR_IP_ADDRESS>
   ```

### Step 4: Install Open edX

Once connected via SSH, run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Log out and back in
exit
# Reconnect via SSH

# Install Tutor
pip3 install --user "tutor[full]"
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Clone TRIGGER repository
git clone <YOUR_REPO_URL> trigger-course
cd trigger-course

# Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Step 5: Configure Your Domain

See [Domain Configuration](#domain-configuration) section below.

---

## Option 2: AWS EC2 (Recommended)

**Best for:** Production deployments, full control, most use cases

### Step 1: Launch an EC2 Instance

1. Go to EC2 Dashboard: https://console.aws.amazon.com/ec2/
2. Click "Launch Instance"
3. **Name:** `trigger-openedx-production`
4. **AMI (Amazon Machine Image):** Ubuntu Server 22.04 LTS
5. **Instance Type:**
   - Testing: `t3.large` (2 vCPU, 8 GB RAM)
   - Production: `t3.xlarge` (4 vCPU, 16 GB RAM)
   - Large scale: `t3.2xlarge` (8 vCPU, 32 GB RAM)

### Step 2: Configure Instance Details

**Key Pair:**
- Click "Create new key pair"
- Name: `trigger-openedx-key`
- Type: RSA
- Format: `.pem` (Mac/Linux) or `.ppk` (Windows/PuTTY)
- Download and save securely

**Network Settings:**
- Create a new security group
- Name: `trigger-openedx-sg`
- Add rules:
  - SSH (22) - Your IP only
  - HTTP (80) - Anywhere
  - HTTPS (443) - Anywhere

**Storage:**
- Root volume: 50 GB (minimum)
- Volume type: General Purpose SSD (gp3)

### Step 3: Launch and Connect

1. Click "Launch instance"
2. Wait for instance to be "Running" (2-3 minutes)
3. Note the "Public IPv4 address"

**Connect via SSH:**

```bash
# Mac/Linux
chmod 400 ~/Downloads/trigger-openedx-key.pem
ssh -i ~/Downloads/trigger-openedx-key.pem ubuntu@<YOUR_EC2_PUBLIC_IP>

# Windows (using PuTTY)
# Use PuTTYgen to convert .pem to .ppk
# Open PuTTY, enter IP address, load .ppk key under SSH → Auth
```

### Step 4: Install Open edX

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Log out and back in for group changes
exit
# Reconnect via SSH

# Install Tutor
pip3 install --user "tutor[full]"
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Clone repository
git clone <YOUR_REPO_URL> trigger-course
cd trigger-course

# Configure for production
cd env
tutor config save --interactive
```

**Important Production Configuration:**

When prompted, set:
- LMS Host: `courses.trigger-project.eu` (your domain)
- CMS Host: `studio.trigger-project.eu` (your domain)
- Enable HTTPS: `yes`
- Platform name: `TRIGGER`

**Initialize and Launch:**

```bash
# Build images
tutor images build openedx

# Initialize database
tutor local do init

# Start services
tutor local start -d

# Check status
tutor local status
```

### Step 5: Set Up Elastic IP (Recommended)

By default, EC2 instances get a new IP address when restarted. To keep a permanent IP:

1. In EC2 Dashboard, go to "Elastic IPs"
2. Click "Allocate Elastic IP address"
3. Click "Allocate"
4. Select the new IP → "Actions" → "Associate Elastic IP address"
5. Choose your instance → "Associate"

---

## Option 3: AWS ECS (Advanced)

**Best for:** Large deployments, auto-scaling, containerized architecture

### Overview

ECS (Elastic Container Service) is AWS's container orchestration service. This setup is more complex but offers:

- Auto-scaling based on load
- High availability across multiple zones
- Better resource management
- Ideal for 1000+ concurrent users

### Prerequisites

- AWS CLI installed locally
- ECS CLI installed
- Docker Hub account (optional)
- Advanced Docker/Kubernetes knowledge

### Simplified ECS Deployment

**1. Install AWS CLI:**

```bash
# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download and run: https://awscli.amazonaws.com/AWSCLIV2.msi
```

**2. Configure AWS CLI:**

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-west-1
# Default output format: json
```

**3. Use Tutor with k8s (Kubernetes):**

Tutor supports Kubernetes deployments which work well with ECS:

```bash
# Install Tutor with k8s support
pip install "tutor[full]"

# Initialize for Kubernetes
tutor config save --set K8S_NAMESPACE=trigger-prod
tutor k8s quickstart
```

**Note:** ECS deployment is complex. Consider hiring a DevOps consultant or using EC2 for simpler deployments.

---

## Domain Configuration

### Step 1: Purchase a Domain (if needed)

Options:
- **Route 53 (AWS):** Integrated with AWS services
- **Namecheap:** Budget-friendly
- **GoDaddy:** Popular option
- **Cloudflare:** Free DNS management

### Step 2: Configure DNS Records

You need to point your domain to your server's IP address.

**Using AWS Route 53:**

1. Go to Route 53: https://console.aws.amazon.com/route53/
2. Click "Hosted zones" → "Create hosted zone"
3. Domain name: `trigger-project.eu`
4. Type: Public hosted zone
5. Click "Create hosted zone"

**Add DNS Records:**

Create these records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | courses | `<YOUR_SERVER_IP>` | 300 |
| A | studio | `<YOUR_SERVER_IP>` | 300 |
| A | apps | `<YOUR_SERVER_IP>` | 300 |

**Using External DNS Provider:**

1. Log in to your DNS provider (Namecheap, GoDaddy, etc.)
2. Find "DNS Management" or "Advanced DNS"
3. Add A records:
   - Host: `courses`, Points to: `<YOUR_SERVER_IP>`
   - Host: `studio`, Points to: `<YOUR_SERVER_IP>`
   - Host: `apps`, Points to: `<YOUR_SERVER_IP>`
4. Save changes

**Wait for DNS Propagation:**
- Can take 5 minutes to 48 hours
- Usually completes in 30-60 minutes
- Check status: https://www.whatsmydns.net/

---

## SSL/HTTPS Setup

### Option 1: Automatic SSL with Tutor (Recommended)

Tutor can automatically obtain and renew SSL certificates using Let's Encrypt:

```bash
# Enable HTTPS
tutor config save --set ENABLE_HTTPS=true

# Tutor will automatically get SSL certificates
tutor local restart
```

**Requirements:**
- Your domain must be pointing to your server (DNS configured)
- Ports 80 and 443 must be open
- Server must be accessible from the internet

### Option 2: Manual SSL with Certbot

If automatic SSL doesn't work:

```bash
# Install Certbot
sudo apt install certbot

# Get certificates
sudo certbot certonly --standalone -d courses.trigger-project.eu -d studio.trigger-project.eu -d apps.trigger-project.eu

# Certificates will be in: /etc/letsencrypt/live/courses.trigger-project.eu/
```

Configure Tutor to use these certificates:

```bash
tutor config save --set ENABLE_HTTPS=true
tutor local restart
```

### Option 3: AWS Certificate Manager (ACM)

For ECS or when using AWS Load Balancer:

1. Go to ACM: https://console.aws.amazon.com/acm/
2. Click "Request a certificate"
3. Choose "Request a public certificate"
4. Add domain names:
   - `courses.trigger-project.eu`
   - `studio.trigger-project.eu`
   - `*.trigger-project.eu` (wildcard)
5. Validation method: DNS validation
6. Add the validation CNAME records to your DNS
7. Wait for validation (5-30 minutes)

---

## Post-Deployment Steps

### 1. Create Admin User

```bash
cd ~/trigger-course/env
tutor local do createuser --staff --superuser admin admin@trigger-project.eu
```

### 2. Configure Email

Edit configuration:

```bash
tutor config save --set SMTP_HOST=smtp.gmail.com \
  --set SMTP_PORT=587 \
  --set SMTP_USE_TLS=true \
  --set SMTP_USERNAME=your-email@gmail.com \
  --set SMTP_PASSWORD=your-app-password
tutor local restart
```

### 3. Set Up Backups

```bash
# Schedule daily backups
crontab -e

# Add this line (backup at 2 AM daily):
0 2 * * * /home/ubuntu/trigger-course/scripts/backup.sh
```

### 4. Configure Monitoring

**Install monitoring tools:**

```bash
# Install CloudWatch agent (AWS)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

**Monitor logs:**

```bash
# View Open edX logs
tutor local logs -f

# View system resources
htop  # install with: sudo apt install htop
```

### 5. Performance Tuning

**Increase worker processes:**

```bash
tutor config save --set OPENEDX_LMS_UWSGI_WORKERS=4
tutor config save --set OPENEDX_CMS_UWSGI_WORKERS=2
tutor local restart
```

---

## Common Pitfalls

### Pitfall 1: Insufficient Server Resources

**Problem:** Platform is slow or crashes

**Solution:**
- Upgrade to larger instance (t3.xlarge minimum)
- Add swap space:
  ```bash
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  ```

### Pitfall 2: DNS Not Propagating

**Problem:** Domain doesn't resolve to server

**Solution:**
- Wait longer (up to 48 hours)
- Check DNS with: `nslookup courses.trigger-project.eu`
- Verify DNS records in provider dashboard
- Try flushing local DNS cache

### Pitfall 3: SSL Certificate Fails

**Problem:** Can't get SSL certificate

**Solution:**
- Ensure DNS is fully propagated first
- Check ports 80 and 443 are open:
  ```bash
  sudo netstat -tlnp | grep -E '80|443'
  ```
- Stop Tutor temporarily to free ports:
  ```bash
  tutor local stop
  sudo certbot certonly --standalone -d your-domain.com
  tutor local start -d
  ```

### Pitfall 4: Out of Disk Space

**Problem:** "No space left on device" error

**Solution:**
- Clean Docker images:
  ```bash
  docker system prune -a
  ```
- Increase EBS volume size:
  1. Stop instance
  2. Modify volume in EC2 console
  3. Start instance
  4. Resize filesystem:
     ```bash
     sudo growpart /dev/xvda 1
     sudo resize2fs /dev/xvda1
     ```

### Pitfall 5: Firewall Blocking Access

**Problem:** Can't access platform from browser

**Solution:**
- Check security group rules in AWS console
- Ensure these ports are open:
  - 80 (HTTP)
  - 443 (HTTPS)
- Test connectivity:
  ```bash
  curl http://<YOUR_IP>
  ```

### Pitfall 6: Forgot Admin Credentials

**Problem:** Can't log in to admin panel

**Solution:**
```bash
# Reset admin password
tutor local exec lms ./manage.py lms changepassword admin
```

---

## Deployment Checklist

Use this checklist to ensure everything is configured correctly:

- [ ] AWS account created and MFA enabled
- [ ] Server/instance launched and running
- [ ] SSH access working
- [ ] Docker installed and running
- [ ] Tutor installed
- [ ] Domain DNS configured and propagated
- [ ] SSL certificate obtained and working
- [ ] Open edX initialized and running
- [ ] Admin user created
- [ ] Email configured (if needed)
- [ ] Backups scheduled
- [ ] Firewall/security groups configured
- [ ] Monitoring set up
- [ ] Performance tested with multiple users

---

## Cost Optimization Tips

1. **Use Reserved Instances:** Save up to 70% by committing to 1-3 years
2. **Stop instances during off-hours:** For development/testing environments
3. **Use Auto Scaling:** For ECS, only pay for what you use
4. **Enable CloudWatch alarms:** Get notified of high costs
5. **Use S3 for media storage:** Cheaper than EBS
6. **Clean up unused resources:** Regularly review and delete

---

## Next Steps

After successful deployment:

1. **Create your first course** - See [usage.md](usage.md)
2. **Set up regular maintenance** - See [maintenance.md](maintenance.md)
3. **Configure integrations** - Payment gateways, SSO, etc.
4. **Customize branding** - Theme, logo, colors

---

## Getting Help

**AWS Support:**
- AWS Documentation: https://docs.aws.amazon.com/
- AWS Support Center: https://console.aws.amazon.com/support/

**Tutor Support:**
- Tutor Docs: https://docs.tutor.overhang.io/
- Community Forum: https://discuss.overhang.io/

**TRIGGER Project:**
- Website: https://trigger-project.eu/
- Technical contact: [Add contact]

---

**Previous:** [Setup Guide](setup.md) | **Next:** [Usage Guide](usage.md) | [Maintenance](maintenance.md)
