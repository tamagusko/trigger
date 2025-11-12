# Deploying to the Internet

How to put your course online so real students can access it.

## Important: This is for Advanced Users

Deploying to the internet requires:
- A cloud account (AWS, Azure, or Google Cloud)
- A credit card for cloud services
- Technical knowledge or IT support

**Cost:** Approximately €2,000-2,500 per year for a professional setup in Europe

---

## Why Deploy Online?

**Local Setup (what you have now):**
- ✅ Free
- ✅ Great for testing
- ❌ Only works on your computer
- ❌ Students must be on your network

**Online Deployment:**
- ✅ Accessible from anywhere
- ✅ Students can access 24/7
- ✅ Handles many users at once
- ✅ Professional domain name
- ❌ Costs money
- ❌ Requires technical setup

---

## Deployment Options

### Option 1: AWS (Amazon Web Services)

**Best for:** Most common, lots of documentation

**Steps:**
1. Create AWS account at https://aws.amazon.com
2. Choose European server (Ireland region)
3. Follow Tutor AWS deployment guide: https://docs.tutor.overhang.io/

**Monthly Cost:**
- Small (100 students): €80-120/month
- Medium (500 students): €150-200/month
- Large (1000+ students): €250+/month

### Option 2: Azure (Microsoft)

**Best for:** If your organization uses Microsoft

**Steps:**
1. Create Azure account at https://azure.microsoft.com
2. Choose European server location
3. Follow Tutor Kubernetes deployment guide

**Cost:** Similar to AWS

### Option 3: Google Cloud

**Best for:** Google Workspace users

**Steps:**
1. Create account at https://cloud.google.com
2. Choose European server location
3. Follow Tutor Google Cloud guide

**Cost:** Similar to AWS

---

## What You Need for Deployment

1. **Domain Name**
   - Example: courses.trigger-project.eu
   - Cost: €10-15/year
   - Buy from: Namecheap, GoDaddy, or Google Domains

2. **SSL Certificate**
   - Makes your site secure (https://)
   - Free with Let's Encrypt
   - Tutor sets this up automatically

3. **Email Service**
   - For sending notifications to students
   - Options: AWS SES, SendGrid, Mailgun
   - Cost: €10-50/month depending on volume

4. **Backup Strategy**
   - Store course data safely
   - Automatic backups to cloud storage
   - Cost: Included in cloud services

---

## Deployment Process Overview

**Warning:** This is a simplified overview. Actual deployment requires technical expertise.

1. **Prepare Cloud Account**
   - Sign up for AWS/Azure/Google Cloud
   - Set up billing
   - Create server instance

2. **Install Tutor on Cloud Server**
   ```bash
   # Connect to your cloud server
   curl -L https://github.com/overhangio/tutor/releases/download/v20.0.2/tutor-$(uname -s)_$(uname -m) -o tutor
   chmod +x tutor
   sudo mv tutor /usr/local/bin/
   ```

3. **Configure Domain**
   ```bash
   tutor config save --set LMS_HOST=courses.yourdomain.com
   tutor config save --set CMS_HOST=studio.yourdomain.com
   ```

4. **Enable HTTPS**
   ```bash
   tutor config save --set ENABLE_HTTPS=true
   ```

5. **Launch Platform**
   ```bash
   tutor local launch
   ```

6. **Create Admin Account**
   ```bash
   tutor local do createuser --staff --superuser admin admin@yourdomain.com
   ```

---

## Getting Help with Deployment

### Hire a Professional

Consider hiring someone to deploy for you:
- DevOps consultant
- Tutor consulting services
- Cloud deployment specialist

**Cost:** €500-2,000 for initial setup

### Alternative: Managed Hosting

Some companies offer hosted Open edX:
- https://overhang.io/ (Tutor creators)
- https://www.edunext.co/
- https://appsembler.com/

**Cost:** €200-500/month, all-inclusive

---

## Maintenance After Deployment

Once deployed, you need to:

### Regular Tasks
- **Weekly:** Check system health
- **Monthly:** Apply security updates
- **Quarterly:** Backup course data
- **Yearly:** Renew domain name

### Updates
```bash
# Update Tutor
pip install --upgrade "tutor[full]"

# Update platform
tutor local upgrade --from=palm
```

---

## Security Checklist

Before going live:

- [ ] Change all default passwords
- [ ] Enable HTTPS
- [ ] Set up firewall rules
- [ ] Configure automatic backups
- [ ] Test disaster recovery
- [ ] Set up monitoring alerts
- [ ] Review privacy settings
- [ ] Create admin procedures document

---

## For TRIGGER Project

**Recommendation:**

1. **Start with local testing** (what you have now)
2. **Create all course content**
3. **Test with small group of users locally**
4. **Then deploy online** when content is ready

**Budget for deployment:**
- Initial setup: €500-1,000
- Annual running cost: €2,000-2,500
- Total first year: €2,500-3,500

---

**Questions?**
- Tutor documentation: https://docs.tutor.overhang.io/
- Tutor forum: https://discuss.overhang.io/
- Hire expert: https://overhang.io/tutor/consulting

---

**Previous:** [3-MANAGING-STUDENTS.md](3-MANAGING-STUDENTS.md)
