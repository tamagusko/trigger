# Lessons Learned: TRIGGER Open edX Deployment

This document captures important lessons learned during the development, testing, and deployment of the TRIGGER Open edX platform. These insights will help future developers and administrators avoid common pitfalls and make informed decisions.

---

## Table of Contents

1. [Cross-Platform Compatibility](#cross-platform-compatibility)
2. [Tutor Version Management](#tutor-version-management)
3. [Docker Configuration](#docker-configuration)
4. [Database Management](#database-management)
5. [Troubleshooting Strategies](#troubleshooting-strategies)
6. [Documentation Best Practices](#documentation-best-practices)
7. [Script Development](#script-development)
8. [Security Considerations](#security-considerations)

---

## Cross-Platform Compatibility

### macOS vs Linux Command Differences

**Issue:** Many Linux commands don't work the same way on macOS (BSD-based).

**Example:**
```bash
# Linux
df -BG .  # Works fine

# macOS
df -BG .  # Error: invalid option -- B
df -g .   # Correct macOS syntax
```

**Lesson:** Always check command compatibility across operating systems.

**Solution Pattern:**
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific commands
    available_space=$(df -g . | awk 'NR==2 {print $4}')
else
    # Linux-specific commands
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
fi
```

**Best Practices:**
- ✅ Use `$OSTYPE` for OS detection
- ✅ Test scripts on all target platforms
- ✅ Document platform-specific behavior
- ✅ Provide alternative commands in docs
- ❌ Don't assume Linux commands work everywhere

**Impact:** Medium - Script failures, user confusion

**Prevention:**
1. Test on macOS, Linux, and Windows (WSL2)
2. Use portable commands when possible
3. Add OS detection to critical scripts
4. Document known platform differences

---

## Tutor Version Management

### Breaking Changes Between Versions

**Issue:** Tutor 20.x introduced breaking changes from 17.x that broke our scripts.

**Example:**
```bash
# Tutor 17.x (OLD)
tutor plugins enable discovery
tutor local do init -p discovery  # -p flag for plugin

# Tutor 20.x (NEW)
tutor plugins enable discovery
tutor config save  # No -p flag, auto-init
```

**Error Received:**
```
Error: No such option: -p
Try 'tutor local do init -h' for help.
```

**Lesson:** Always pin versions or test with latest releases.

**Solution:**
1. Remove `-p` flag from init commands
2. Use `tutor config save` after plugin changes
3. Update documentation with new syntax

**Best Practices:**
- ✅ Document which Tutor version scripts support
- ✅ Test with latest stable release before deploying
- ✅ Read release notes for breaking changes
- ✅ Pin Tutor version in production
- ❌ Don't blindly upgrade without testing

**Version Compatibility Matrix:**

| Feature | Tutor 17.x | Tutor 20.x |
|---------|-----------|-----------|
| Plugin init | `-p flag` | Automatic |
| Config save | After changes | Required |
| Image building | Manual | Auto/Manual |

**Impact:** High - Script failures, deployment blocks

**Prevention:**
1. Subscribe to Tutor release notifications
2. Maintain a test environment for upgrades
3. Create version-specific documentation
4. Use version checks in scripts:
   ```bash
   TUTOR_VERSION=$(tutor --version | grep -oE '[0-9]+\.[0-9]+')
   if [[ "$TUTOR_VERSION" < "20.0" ]]; then
       # Use old syntax
   else
       # Use new syntax
   fi
   ```

---

## Docker Configuration

### Resource Allocation

**Issue:** Insufficient Docker resources cause platform failures or poor performance.

**Minimum vs Recommended:**

| Resource | Minimum | Recommended | Tested |
|----------|---------|-------------|--------|
| RAM | 8 GB | 16 GB | 7.65 GB |
| CPU | 2 cores | 4+ cores | 10 cores |
| Disk | 20 GB | 50+ GB | 67 GB |

**Lesson:** "Minimum" is truly minimum - allocate more for better experience.

**Symptoms of Insufficient Resources:**
- 502 Bad Gateway errors
- Services failing to start
- Slow response times
- Container crashes
- Out of memory errors

**Solution:**
1. **Check Current Allocation:**
   ```bash
   docker info | grep -E "CPUs|Total Memory"
   ```

2. **Increase Resources (Docker Desktop):**
   - Settings → Resources
   - Increase Memory to 16GB
   - Increase CPUs to 4+
   - Apply & Restart

3. **Monitor Usage:**
   ```bash
   docker stats --no-stream
   ```

**Best Practices:**
- ✅ Allocate 2x minimum for production
- ✅ Monitor resource usage regularly
- ✅ Set up alerts for resource exhaustion
- ✅ Document actual resource usage in your environment
- ❌ Don't run at minimum specs in production

**Impact:** High - Platform stability, performance

---

## Database Management

### Clean State After Failed Initialization

**Issue:** Partial database initialization causes duplicate entry errors on retry.

**Error Example:**
```
django.db.utils.IntegrityError: (1062, "Duplicate entry 'local.overhang.io'
for key 'django_site.django_site_domain_a2e37b91_uniq'")
```

**Root Cause:**
- First launch fails mid-initialization
- Database partially populated
- Second launch tries to recreate existing records

**Lesson:** Always clean volumes after failed initialization.

**Solution:**
```bash
# Stop all services
tutor local stop

# Remove ALL volumes (WARNING: This deletes data!)
tutor local dc down -v

# Start fresh
tutor local launch
```

**Best Practices:**
- ✅ Document cleanup procedures clearly
- ✅ Create safety backups before major operations
- ✅ Make initialization idempotent where possible
- ✅ Add cleanup commands to troubleshooting docs
- ❌ Don't retry failed initialization without cleanup

**Prevention Strategy:**
1. Test initialization on clean environment
2. Add rollback capability to scripts
3. Implement checkpoint/resume system
4. Log initialization steps for debugging

**Impact:** High - Blocks deployment, requires manual intervention

---

## Troubleshooting Strategies

### Systematic Debugging Approach

**Lesson:** Follow a structured approach to diagnose issues efficiently.

**Recommended Process:**

1. **Identify the Problem**
   ```bash
   # Check what's running
   docker ps
   tutor local status

   # Check recent logs
   tutor local logs --tail=100
   ```

2. **Isolate the Component**
   ```bash
   # Check specific service
   tutor local logs -f lms
   tutor local logs -f mysql
   ```

3. **Verify Configuration**
   ```bash
   # Check config
   tutor config printroot
   tutor config printvalue LMS_HOST
   ```

4. **Test Connectivity**
   ```bash
   # Test endpoints
   curl -I http://local.overhang.io

   # Test database
   tutor local exec mysql mysql -u root -p
   ```

5. **Review Recent Changes**
   - What changed since it last worked?
   - Recent updates or configuration changes?
   - New plugins enabled?

6. **Consult Documentation**
   - Check Tutor docs
   - Search Tutor forum
   - Review project docs

**Best Practices:**
- ✅ Document error messages exactly
- ✅ Check one component at a time
- ✅ Save logs before cleanup
- ✅ Test fixes on isolated systems first
- ❌ Don't make multiple changes simultaneously

**Common Patterns:**

| Symptom | Likely Cause | First Check |
|---------|--------------|-------------|
| 502 Gateway | Services not ready | `tutor local status` |
| Connection refused | Port conflict | `lsof -i :80` |
| Slow performance | Insufficient RAM | `docker stats` |
| Database errors | Migration issues | `tutor local logs mysql` |

---

## Documentation Best Practices

### Write for Non-Technical Users

**Lesson:** Documentation should be accessible to users with varying technical skills.

**Before:**
```markdown
Execute the Docker containerization orchestration script.
```

**After:**
```markdown
Run the setup script to install Open edX:
./scripts/setup.sh

This will take about 30 minutes.
```

**Best Practices:**
- ✅ Use simple, clear language
- ✅ Include expected outcomes
- ✅ Provide time estimates
- ✅ Add troubleshooting for common issues
- ✅ Use visual indicators (✓, ✗, ⏰)
- ✅ Include actual command output examples
- ❌ Don't assume technical knowledge
- ❌ Don't use jargon without explanation

**Documentation Structure:**

1. **Overview** - What is this?
2. **Prerequisites** - What do you need?
3. **Step-by-Step** - How to do it?
4. **Verification** - How to know it worked?
5. **Troubleshooting** - What if it doesn't work?
6. **Next Steps** - What's next?

**Example Structure:**
```markdown
## Installing Docker

### What You Need
- macOS 10.15 or newer
- 8GB RAM available
- Administrator access

### How to Install
1. Download Docker Desktop
2. Open the .dmg file
3. Drag Docker to Applications
4. Wait 2 minutes for installation

### Verify It Works
docker --version
# Should show: Docker version 24.x.x

### Common Issues
- If you see "command not found", restart your terminal
- If Docker won't start, check System Preferences → Security
```

---

## Script Development

### Error Handling and User Feedback

**Lesson:** Good scripts provide clear feedback and handle errors gracefully.

**Bad Example:**
```bash
df -BG .
```
- Fails silently on macOS
- No error message
- User doesn't know what went wrong

**Good Example:**
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    available_space=$(df -g . | awk 'NR==2 {print $4}')
else
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
fi

if [ -z "$available_space" ]; then
    print_error "Could not determine available disk space"
    print_info "Please check manually: df -h ."
    exit 1
fi

if [ "$available_space" -lt 20 ]; then
    print_warning "Low disk space: ${available_space}GB (20GB+ recommended)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

**Best Practices:**

1. **Always Check Commands Succeed:**
   ```bash
   if ! some_command; then
       print_error "Command failed!"
       exit 1
   fi
   ```

2. **Provide Context:**
   ```bash
   print_info "Installing Tutor (this may take 5 minutes)..."
   pip install tutor
   print_success "Tutor installed!"
   ```

3. **Use Color for Clarity:**
   ```bash
   GREEN='\033[0;32m'
   RED='\033[0;31m'
   NC='\033[0m'  # No Color

   echo -e "${GREEN}✓ Success${NC}"
   echo -e "${RED}✗ Failed${NC}"
   ```

4. **Make Scripts Idempotent:**
   ```bash
   if command -v tutor &> /dev/null; then
       print_warning "Tutor already installed"
   else
       print_info "Installing Tutor..."
       pip install tutor
   fi
   ```

5. **Add Help Text:**
   ```bash
   if [[ "$1" == "--help" ]]; then
       echo "Usage: $0 [--production] [--domain DOMAIN]"
       exit 0
   fi
   ```

**Impact:** High - User experience, debugging ease

---

## Security Considerations

### Credential Management

**Lesson:** Never hardcode credentials, always use secure generation and storage.

**Issues Found:**
- Auto-generated passwords logged to console
- Credentials visible in process lists
- Secrets in configuration files

**Best Practices:**

1. **Generate Strong Credentials:**
   ```bash
   # Good: Random, strong password
   PASSWORD=$(openssl rand -base64 32)

   # Bad: Predictable password
   PASSWORD="password123"
   ```

2. **Store Securely:**
   ```bash
   # Store in secure location
   chmod 600 config/secrets.yml

   # Never commit secrets
   echo "secrets.yml" >> .gitignore
   ```

3. **Use Environment Variables:**
   ```bash
   export DB_PASSWORD="$(cat /secure/location/db_pass)"
   ```

4. **Document Secret Locations:**
   ```markdown
   ## Credentials

   Credentials are stored in:
   - `/path/to/secrets` (never commit!)
   - Use password manager for backup
   - Rotate every 90 days in production
   ```

5. **Separate Dev and Prod:**
   - Different credentials for development
   - Prod credentials only on production servers
   - Use secret management tools (Vault, AWS Secrets Manager)

**Checklist for Production:**
- [ ] All default passwords changed
- [ ] Strong passwords (16+ characters)
- [ ] Credentials stored securely
- [ ] Access logs monitored
- [ ] MFA enabled for admin accounts
- [ ] Regular security audits scheduled

**Impact:** Critical - Security breaches, data loss

---

## Key Takeaways

### Top 10 Lessons

1. **Test Cross-Platform** - Commands vary between macOS and Linux
2. **Pin Versions** - Breaking changes happen between major versions
3. **Allocate Resources** - Minimum specs are truly minimum
4. **Clean Failed Attempts** - Remove volumes after failed initialization
5. **Document Everything** - Future you will thank present you
6. **Write for Beginners** - Assume no technical knowledge
7. **Handle Errors Gracefully** - Provide clear, actionable messages
8. **Use Version Control** - Commit tested, working code
9. **Secure Credentials** - Never hardcode, always protect
10. **Test, Test, Test** - If it's not tested, it doesn't work

### Before Starting Any Project

- [ ] Define target platforms (macOS, Linux, Windows)
- [ ] Check minimum system requirements
- [ ] Review latest version documentation
- [ ] Set up test environment
- [ ] Plan rollback procedures
- [ ] Document as you go
- [ ] Test on clean systems
- [ ] Get feedback from non-technical users

### When Things Go Wrong

- [ ] Check logs first
- [ ] Isolate the problem
- [ ] Search existing issues/forums
- [ ] Document the error exactly
- [ ] Test solutions in isolation
- [ ] Update documentation with fix
- [ ] Commit working solution
- [ ] Add to troubleshooting guide

---

## Resources

### Useful Links

- **Tutor Documentation:** https://docs.tutor.overhang.io/
- **Tutor Forum:** https://discuss.overhang.io/
- **Open edX Docs:** https://docs.openedx.org/
- **Docker Docs:** https://docs.docker.com/
- **Our Repository:** https://github.com/tamagusko/trigger

### Our Documentation

- [First Run Guide](first-run.md) - For first-time users
- [Testing Guide](TESTING.md) - How to test the setup
- [Test Report](TEST_REPORT.md) - Actual test results
- [Setup Guide](setup.md) - Detailed installation
- [Deployment Guide](deploy.md) - AWS deployment
- [Usage Guide](usage.md) - Creating courses
- [Maintenance Guide](maintenance.md) - Operations

---

## Contributing Your Lessons

Found a new issue? Learned something useful? Please contribute!

1. **Document the Issue:**
   - What happened?
   - What did you expect?
   - How did you fix it?

2. **Update This Document:**
   - Add to relevant section
   - Include code examples
   - Explain the lesson learned

3. **Submit Changes:**
   ```bash
   git checkout -b lesson/your-topic
   git commit -m "Add lesson learned: your topic"
   git push origin lesson/your-topic
   # Create pull request
   ```

4. **Share with Community:**
   - Post on Tutor forum
   - Update project README
   - Help others avoid the same issue

---

## Conclusion

These lessons represent real challenges encountered and overcome during the TRIGGER project. By documenting them, we hope to:

- Help future team members avoid these pitfalls
- Contribute to the Open edX community
- Improve our processes and tools
- Build more reliable systems

Remember: **Every problem is a learning opportunity!**

---

**Document Version:** 1.0
**Last Updated:** November 11, 2025
**Contributors:** Claude Code, TRIGGER Team
**Status:** Living Document (continuously updated)
