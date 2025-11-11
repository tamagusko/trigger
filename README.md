# TRIGGER Open edX Platform

[![TRIGGER Project](https://img.shields.io/badge/TRIGGER-Project-blue)](https://trigger-project.eu/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Open edX](https://img.shields.io/badge/Open%20edX-Palm-blue)](https://openedx.org/)
[![Tutor](https://img.shields.io/badge/Tutor-17.x-green)](https://docs.tutor.overhang.io/)

This repository contains the complete Docker-based Open edX environment for the **TRIGGER** project, powered by [Tutor](https://docs.tutor.overhang.io/).

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

For detailed instructions, see [docs/setup.md](docs/setup.md).

## Project Structure

```
TRIGGER_course/
├── docs/               # Documentation
│   ├── setup.md        # Local installation guide
│   ├── deploy.md       # AWS deployment guide
│   ├── usage.md        # Platform usage instructions
│   └── maintenance.md  # Backup and maintenance guide
├── env/                # Tutor environment files (generated)
├── scripts/            # Helper scripts
│   ├── setup.sh        # Automated setup script
│   ├── backup.sh       # Backup script
│   ├── restore.sh      # Restore script
│   └── update.sh       # Update script
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## Documentation

### Getting Started

- **[First Run Guide](docs/first-run.md)** - Quick start for first-time users
- **[Testing Guide](docs/TESTING.md)** - How to test the scripts safely

### For Developers

- **[Setup Guide](docs/setup.md)** - Install and configure Open edX locally
- **[Deployment Guide](docs/deploy.md)** - Deploy to AWS cloud services
- **[Maintenance Guide](docs/maintenance.md)** - Update, backup, and restore

### For Course Creators

- **[Usage Guide](docs/usage.md)** - Create courses, manage users, and use the platform

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

## Support

### Tutor Documentation
- Official Docs: https://docs.tutor.overhang.io/
- Community Forum: https://discuss.overhang.io/

### Open edX Documentation
- Official Docs: https://docs.openedx.org/
- Community: https://open.edx.org/community/

### TRIGGER Project
- Website: https://trigger-project.eu/
- Contact: [Add contact information]

## Troubleshooting

If you encounter issues:

1. Check the [Setup Guide](docs/setup.md) for common problems
2. Review Docker logs: `tutor local logs -f`
3. Ensure Docker has enough resources allocated
4. Visit the Tutor community forum: https://discuss.overhang.io/

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

For questions or contributions, please:
- Open an issue on GitHub
- Check existing documentation
- Contact the TRIGGER team via the project website

## License

MIT License

Copyright (c) 2024 TRIGGER Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**Note:** This project uses Open edX and Tutor, which are licensed under the GNU Affero General Public License (AGPL). See the [LICENSE](LICENSE) file for complete details.

## Acknowledgments

This project uses:
- [Open edX](https://open.edx.org/) - Open-source learning platform
- [Tutor](https://docs.tutor.overhang.io/) - Docker-based Open edX distribution
- [Docker](https://www.docker.com/) - Containerization platform

---

**TRIGGER Project** | Transformative Research on Intelligent Green Growth Education and Resources
