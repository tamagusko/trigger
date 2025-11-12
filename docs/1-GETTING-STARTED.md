# Getting Started with TRIGGER Platform

Simple guide to set up and run your online course platform.

## What You Need

- A computer with at least 8GB RAM
- 20GB of free disk space
- Internet connection

## Installation Steps

### For Mac/Linux

**Step 1: Install Docker**
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Install it
3. Open Docker Desktop and wait for it to start

**Step 2: Setup the Platform**
Open Terminal and run:
```bash
./scripts/setup.sh
```

Wait about 20 minutes for installation.

**Step 3: Fix Local Addresses**
Run:
```bash
./scripts/fix-hosts.sh
```
Enter your computer password when asked.

### For Windows

**Step 1: Install Docker**
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Install it
3. Open Docker Desktop and wait for it to start

**Step 2: Install Git Bash**
1. Download from https://git-scm.com/downloads
2. Install it

**Step 3: Setup the Platform**
Open Git Bash and run:
```bash
./scripts/setup.sh
```

Wait about 20 minutes for installation.

**Step 4: Fix Local Addresses**
1. Open Notepad as Administrator (right-click → Run as administrator)
2. Open file: `C:\Windows\System32\drivers\etc\hosts`
3. Add this line at the end:
```
127.0.0.1 local.overhang.io studio.local.overhang.io apps.local.overhang.io
```
4. Save and close

---

## Accessing Your Platform

Open your web browser and go to:

**For Teachers (Create Courses):**
http://studio.local.overhang.io

**For Students (Take Courses):**
http://local.overhang.io

**Login Information:**
- Email: email@email.com
- Password: (set during installation)

---

## Daily Use

### Starting the Platform
```bash
tutor local start -d
```

### Stopping the Platform
```bash
tutor local stop
```

### Checking if it's Running
```bash
tutor local status
```

---

## Troubleshooting

**Problem: Docker not starting**
- Open Docker Desktop manually
- Wait 2-3 minutes for it to fully start
- Try again

**Problem: Website not loading**
- Run the fix-hosts script again
- Close browser completely and reopen
- Clear browser cache

**Problem: Slow performance**
- Make sure Docker has at least 4GB RAM allocated
- Close other programs
- Restart Docker Desktop

---

**Next:** Read [2-CREATING-COURSES.md](2-CREATING-COURSES.md) to learn how to create your first course.
