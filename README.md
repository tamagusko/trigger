# TRIGGER Open edX Platform

[![TRIGGER Project](https://img.shields.io/badge/TRIGGER-Project-blue)](https://trigger-project.eu/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Open edX](https://img.shields.io/badge/Open%20edX-Palm-blue)](https://openedx.org/)
[![Tutor](https://img.shields.io/badge/Tutor-17.x-green)](https://docs.tutor.overhang.io/)

This repository contains a Docker-based Open edX environment for the **TRIGGER** project, powered by [Tutor](https://docs.tutor.overhang.io/).

**Repository:** https://github.com/tamagusko/trigger

## Overview

TRIGGER (Transformative Research on Intelligent Green Growth Education and Resources) uses Open edX to deliver online courses and educational content. This setup is designed to be:

- **Easy to develop locally** using Docker
- **Simple to deploy to the cloud** (AWS, Lightsail, EC2, or ECS)
- **Maintainable by non-technical users** with clear documentation

## Project Website

Visit the official TRIGGER project website: [https://trigger-project.eu/](https://trigger-project.eu/)

## Quick Start

### Prerequisites

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- At least 8GB of RAM available for Docker
- 20GB of free disk space

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/tamagusko/trigger.git
   cd trigger
   ```

2. **Run the automated setup:**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. **Access your platform:**
   - LMS (Learning Management System): http://local.overhang.io
   - Studio (Course Authoring): http://studio.local.overhang.io

For detailed instructions, see [docs/1-GETTING-STARTED.md](docs/1-GETTING-STARTED.md).

## Project Structure

```
TRIGGER_course/
├── docs/                      # Documentation
│   ├── README.md              # Documentation index
│   ├── 1-GETTING-STARTED.md   # Installation guide
│   ├── 2-CREATING-COURSES.md  # Course creation guide
│   ├── 3-MANAGING-STUDENTS.md # Student management guide
│   └── 4-DEPLOYMENT.md        # Cloud deployment guide
├── env/                       # Tutor environment files (generated)
├── scripts/                   # Helper scripts
│   ├── setup.sh               # Automated setup script
│   ├── fix-hosts.sh           # Fix local domain resolution
│   ├── backup.sh              # Backup script
│   ├── restore.sh             # Restore script
│   └── update.sh              # Update script
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## Documentation

Read the complete guides in the [docs](docs/) folder:

1. **[Getting Started](docs/1-GETTING-STARTED.md)** - Install and setup (Mac/Linux/Windows)
2. **[Creating Courses](docs/2-CREATING-COURSES.md)** - Make your first online course
3. **[Managing Students](docs/3-MANAGING-STUDENTS.md)** - Enroll and track students
4. **[Deployment](docs/4-DEPLOYMENT.md)** - Deploy to the cloud (advanced)

## Common Commands

### Start the platform
```bash
tutor local start -d
```

### Stop the platform
```bash
tutor local stop
```

### Create a superuser account
```bash
tutor local do createuser --staff --superuser admin admin@trigger.eu
```

### View logs
```bash
tutor local logs -f
```

### Backup data
```bash
./scripts/backup.sh
```

## Helper Scripts

All scripts are located in the `scripts/` directory:

- **setup.sh** - Automates Tutor installation and initial configuration
- **backup.sh** - Creates backups of your Open edX data
- **restore.sh** - Restores from a backup file
- **update.sh** - Updates Tutor and all plugins

## Plugins Enabled

This installation includes the following Tutor plugins:

- **discovery** - Course discovery and search
- **ecommerce** - E-commerce functionality
- **forum** - Discussion forums
- **mfe** (Micro-Frontends) - Modern user interface

## System Requirements

### Local Development
- **CPU:** 2+ cores
- **RAM:** 8GB minimum (16GB recommended)
- **Storage:** 20GB free space
- **OS:** macOS, Windows 10/11, or Linux

### Production (AWS)
- **EC2 Instance:** t3.xlarge or larger
- **Storage:** 50GB+ EBS volume
- **RAM:** 16GB minimum
- **OS:** Ubuntu 20.04 or 22.04 LTS


## License

MIT License. See the [LICENSE](LICENSE) file for complete details.

## Acknowledgments

This project uses:
- [Open edX](https://open.edx.org/) - Open-source learning platform
- [Tutor](https://docs.tutor.overhang.io/) - Docker-based Open edX distribution
- [Docker](https://www.docker.com/) - Containerization platform

---

**TRIGGER Project** | Transformative Research on Intelligent Green Growth Education and Resources
