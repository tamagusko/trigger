#!/bin/bash
#
# TRIGGER Open edX Setup Script
# This script automates the installation and configuration of Tutor and Open edX
#
# Usage: ./setup.sh [--production] [--domain DOMAIN]
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PRODUCTION=false
DOMAIN=""
TUTOR_ROOT="${HOME}/trigger-course/env"

# Print colored message
print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_header() {
    echo ""
    print_message "$BLUE" "=================================================="
    print_message "$BLUE" "$1"
    print_message "$BLUE" "=================================================="
    echo ""
}

print_success() {
    print_message "$GREEN" "✓ $1"
}

print_error() {
    print_message "$RED" "✗ $1"
}

print_warning() {
    print_message "$YELLOW" "⚠ $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --production)
            PRODUCTION=true
            shift
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --production       Set up for production deployment"
            echo "  --domain DOMAIN    Set domain name (e.g., trigger-project.eu)"
            echo "  --help             Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main installation function
main() {
    print_header "TRIGGER Open edX Setup"

    print_message "$BLUE" "This script will install and configure Open edX using Tutor."
    print_message "$BLUE" "Please ensure you have:"
    print_message "$BLUE" "  - Docker installed and running"
    print_message "$BLUE" "  - At least 8GB RAM available"
    print_message "$BLUE" "  - 20GB+ free disk space"
    echo ""

    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled."
        exit 0
    fi

    # Check prerequisites
    check_prerequisites

    # Install Tutor
    install_tutor

    # Configure Tutor
    configure_tutor

    # Build images
    build_images

    # Initialize platform
    initialize_platform

    # Enable plugins
    enable_plugins

    # Start services
    start_services

    # Print completion message
    print_completion
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        print_message "$YELLOW" "Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker is installed"

    # Check Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running!"
        print_message "$YELLOW" "Please start Docker Desktop and try again."
        exit 1
    fi
    print_success "Docker is running"

    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed!"
        exit 1
    fi
    print_success "Python 3 is installed"

    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed!"
        exit 1
    fi
    print_success "pip3 is installed"

    # Check disk space (need at least 20GB)
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 20 ]; then
        print_warning "Low disk space: ${available_space}GB available (20GB+ recommended)"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Sufficient disk space available (${available_space}GB)"
    fi

    echo ""
}

# Install Tutor
install_tutor() {
    print_header "Installing Tutor"

    # Check if Tutor is already installed
    if command -v tutor &> /dev/null; then
        TUTOR_VERSION=$(tutor --version 2>&1 | head -n 1)
        print_warning "Tutor is already installed: $TUTOR_VERSION"
        read -p "Reinstall/upgrade? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message "$BLUE" "Skipping Tutor installation"
            return
        fi
    fi

    print_message "$BLUE" "Installing Tutor..."
    pip3 install --user --upgrade "tutor[full]"

    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Add to shell profile
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi

    # Verify installation
    if ! command -v tutor &> /dev/null; then
        print_error "Tutor installation failed!"
        exit 1
    fi

    TUTOR_VERSION=$(tutor --version 2>&1 | head -n 1)
    print_success "Tutor installed: $TUTOR_VERSION"
    echo ""
}

# Configure Tutor
configure_tutor() {
    print_header "Configuring Tutor"

    # Create env directory if it doesn't exist
    mkdir -p "$TUTOR_ROOT"
    cd "$TUTOR_ROOT"

    if [ "$PRODUCTION" = true ]; then
        print_message "$BLUE" "Configuring for PRODUCTION deployment"

        if [ -z "$DOMAIN" ]; then
            read -p "Enter your domain name (e.g., trigger-project.eu): " DOMAIN
        fi

        # Production configuration
        tutor config save \
            --set PLATFORM_NAME="TRIGGER" \
            --set CONTACT_EMAIL="admin@${DOMAIN}" \
            --set LMS_HOST="courses.${DOMAIN}" \
            --set CMS_HOST="studio.${DOMAIN}" \
            --set ENABLE_HTTPS=true \
            --set ENABLE_WEB_PROXY=true
    else
        print_message "$BLUE" "Configuring for LOCAL development"

        # Local development configuration
        tutor config save \
            --set PLATFORM_NAME="TRIGGER" \
            --set CONTACT_EMAIL="admin@trigger.eu" \
            --set LMS_HOST="local.overhang.io" \
            --set CMS_HOST="studio.local.overhang.io" \
            --set ENABLE_HTTPS=false \
            --set ENABLE_WEB_PROXY=true
    fi

    print_success "Tutor configuration complete"
    echo ""
}

# Build Docker images
build_images() {
    print_header "Building Docker Images"

    print_message "$BLUE" "This may take 15-30 minutes on first run..."
    print_message "$BLUE" "Building Open edX image..."

    cd "$TUTOR_ROOT"

    # Build openedx image
    if ! tutor images build openedx; then
        print_error "Failed to build Open edX image!"
        exit 1
    fi

    print_success "Docker images built successfully"
    echo ""
}

# Initialize platform
initialize_platform() {
    print_header "Initializing Platform"

    print_message "$BLUE" "Setting up database and running migrations..."
    print_message "$BLUE" "This may take 10-15 minutes..."

    cd "$TUTOR_ROOT"

    if ! tutor local do init; then
        print_error "Platform initialization failed!"
        exit 1
    fi

    print_success "Platform initialized successfully"
    echo ""
}

# Enable plugins
enable_plugins() {
    print_header "Enabling Plugins"

    cd "$TUTOR_ROOT"

    # Enable discovery plugin
    print_message "$BLUE" "Enabling discovery plugin..."
    if tutor plugins enable discovery 2>/dev/null; then
        tutor local do init -p discovery
        print_success "Discovery plugin enabled"
    else
        print_warning "Discovery plugin not available (may require separate installation)"
    fi

    # Enable forum plugin
    print_message "$BLUE" "Enabling forum plugin..."
    if tutor plugins enable forum 2>/dev/null; then
        print_success "Forum plugin enabled"
    else
        print_warning "Forum plugin not available"
    fi

    # Enable MFE plugin
    print_message "$BLUE" "Enabling MFE (Micro-Frontends) plugin..."
    if tutor plugins enable mfe 2>/dev/null; then
        tutor config save
        print_success "MFE plugin enabled"
    else
        print_warning "MFE plugin not available"
    fi

    echo ""
}

# Start services
start_services() {
    print_header "Starting Services"

    cd "$TUTOR_ROOT"

    print_message "$BLUE" "Starting all services..."

    if ! tutor local start -d; then
        print_error "Failed to start services!"
        exit 1
    fi

    print_success "All services started"

    print_message "$BLUE" "Waiting for services to be ready (this may take 2-3 minutes)..."
    sleep 30

    # Check service status
    tutor local status

    echo ""
}

# Print completion message
print_completion() {
    print_header "Installation Complete!"

    print_success "TRIGGER Open edX platform is ready!"
    echo ""

    if [ "$PRODUCTION" = true ]; then
        print_message "$GREEN" "Access your platform at:"
        print_message "$GREEN" "  LMS (Students):  https://courses.${DOMAIN}"
        print_message "$GREEN" "  Studio (Authoring): https://studio.${DOMAIN}"
        echo ""
        print_message "$YELLOW" "IMPORTANT: Make sure DNS is configured and pointing to this server!"
    else
        print_message "$GREEN" "Access your platform at:"
        print_message "$GREEN" "  LMS (Students):  http://local.overhang.io"
        print_message "$GREEN" "  Studio (Authoring): http://studio.local.overhang.io"
        echo ""
        print_message "$YELLOW" "Note: First page load may take 1-2 minutes"
    fi

    echo ""
    print_message "$BLUE" "Next steps:"
    print_message "$BLUE" "  1. Create an admin user:"
    print_message "$BLUE" "     cd $TUTOR_ROOT"
    print_message "$BLUE" "     tutor local do createuser --staff --superuser admin admin@trigger.eu"
    print_message "$BLUE" ""
    print_message "$BLUE" "  2. View logs:"
    print_message "$BLUE" "     tutor local logs -f"
    print_message "$BLUE" ""
    print_message "$BLUE" "  3. Stop the platform:"
    print_message "$BLUE" "     tutor local stop"
    print_message "$BLUE" ""
    print_message "$BLUE" "  4. Documentation:"
    print_message "$BLUE" "     See docs/setup.md for detailed instructions"
    print_message "$BLUE" "     See docs/usage.md for creating courses"
    echo ""

    print_message "$GREEN" "Happy teaching! 🎓"
}

# Run main function
main
