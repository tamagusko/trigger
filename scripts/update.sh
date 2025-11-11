#!/bin/bash
#
# TRIGGER Open edX Update Script
# This script updates Tutor, plugins, and Open edX
#
# Usage: ./update.sh [--skip-backup] [--force]
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TUTOR_ROOT="${PROJECT_ROOT}/env"

# Options
SKIP_BACKUP=false
FORCE_UPDATE=false

# Print colored message
print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
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

print_info() {
    print_message "$BLUE" "ℹ $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-backup  Skip pre-update backup"
            echo "  --force        Skip confirmation prompts"
            echo "  --help         Show this help message"
            echo ""
            echo "This script will:"
            echo "  1. Create a backup (unless --skip-backup)"
            echo "  2. Update Tutor and plugins"
            echo "  3. Update Docker images"
            echo "  4. Run database migrations"
            echo "  5. Restart services"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main update function
main() {
    print_info "=================================================="
    print_info "TRIGGER Open edX Update - $(date)"
    print_info "=================================================="
    echo ""

    # Warning message
    print_warning "This script will update your Open edX platform."
    print_warning "The platform will be temporarily unavailable during the update."
    echo ""

    if [ "$FORCE_UPDATE" = false ]; then
        read -p "Continue with update? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Update cancelled."
            exit 0
        fi
    fi

    # Check prerequisites
    check_prerequisites

    # Create backup
    if [ "$SKIP_BACKUP" = false ]; then
        create_backup
    fi

    # Show current versions
    show_current_versions

    # Update system packages
    update_system_packages

    # Update Tutor
    update_tutor

    # Update plugins
    update_plugins

    # Update configuration
    update_configuration

    # Update Docker images
    update_images

    # Run migrations
    run_migrations

    # Restart services
    restart_services

    # Verify update
    verify_update

    # Print summary
    print_summary
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if Tutor is installed
    if ! command -v tutor &> /dev/null; then
        print_error "Tutor is not installed!"
        exit 1
    fi

    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running!"
        exit 1
    fi

    # Check disk space (need at least 10GB)
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 10 ]; then
        print_warning "Low disk space: ${available_space}GB available"
        if [ "$FORCE_UPDATE" = false ]; then
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    print_success "Prerequisites check complete"
    echo ""
}

# Create backup
create_backup() {
    print_info "Creating pre-update backup..."

    if [ ! -x "${SCRIPT_DIR}/backup.sh" ]; then
        print_warning "Backup script not found or not executable"
        print_warning "Skipping backup..."
        return
    fi

    print_info "This may take several minutes..."
    if "${SCRIPT_DIR}/backup.sh" > /dev/null 2>&1; then
        print_success "Backup created successfully"
    else
        print_error "Backup failed!"
        if [ "$FORCE_UPDATE" = false ]; then
            read -p "Continue without backup? (y/n) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    echo ""
}

# Show current versions
show_current_versions() {
    print_info "Current versions:"

    # Tutor version
    CURRENT_TUTOR_VERSION=$(tutor --version 2>&1 | head -n 1 || echo "Unknown")
    print_info "  Tutor: ${CURRENT_TUTOR_VERSION}"

    # Open edX version
    cd "$TUTOR_ROOT"
    if [ -f "config.yml" ]; then
        OPENEDX_VERSION=$(grep "OPENEDX_COMMON_VERSION:" config.yml | awk '{print $2}' || echo "Unknown")
        print_info "  Open edX: ${OPENEDX_VERSION}"
    fi

    # Docker version
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    print_info "  Docker: ${DOCKER_VERSION}"

    echo ""
}

# Update system packages
update_system_packages() {
    print_info "Updating system packages..."

    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS=$(uname -s)
    fi

    case "$OS" in
        ubuntu|debian)
            print_info "Updating Ubuntu/Debian packages..."
            sudo apt update
            sudo apt upgrade -y
            print_success "System packages updated"
            ;;
        centos|rhel|fedora)
            print_info "Updating RedHat/CentOS packages..."
            sudo yum update -y
            print_success "System packages updated"
            ;;
        darwin)
            print_info "macOS detected - skipping system package update"
            print_info "Please update macOS manually via System Preferences"
            ;;
        *)
            print_warning "Unknown OS - skipping system package update"
            ;;
    esac

    echo ""
}

# Update Tutor
update_tutor() {
    print_info "Updating Tutor..."

    # Update Tutor
    if pip3 install --user --upgrade "tutor[full]"; then
        NEW_TUTOR_VERSION=$(tutor --version 2>&1 | head -n 1)
        print_success "Tutor updated: ${NEW_TUTOR_VERSION}"
    else
        print_error "Failed to update Tutor!"
        exit 1
    fi

    echo ""
}

# Update plugins
update_plugins() {
    print_info "Updating plugins..."

    cd "$TUTOR_ROOT"

    # List enabled plugins
    ENABLED_PLUGINS=$(tutor plugins list | grep "enabled" | awk '{print $1}' || true)

    if [ -z "$ENABLED_PLUGINS" ]; then
        print_info "No plugins enabled"
        return
    fi

    print_info "Enabled plugins: ${ENABLED_PLUGINS}"

    # Update each plugin
    for plugin in $ENABLED_PLUGINS; do
        print_info "  - Updating ${plugin}..."
        if pip3 install --user --upgrade "tutor-${plugin}" 2>/dev/null; then
            print_success "    ${plugin} updated"
        else
            print_warning "    ${plugin} update failed or not available via pip"
        fi
    done

    echo ""
}

# Update configuration
update_configuration() {
    print_info "Updating configuration..."

    cd "$TUTOR_ROOT"

    # Save configuration (this will update to new defaults)
    if tutor config save; then
        print_success "Configuration updated"
    else
        print_error "Failed to update configuration"
        exit 1
    fi

    echo ""
}

# Update Docker images
update_images() {
    print_info "Updating Docker images..."
    print_info "This may take 15-30 minutes..."

    cd "$TUTOR_ROOT"

    # Pull latest images
    print_info "Pulling latest images..."
    if tutor images pull all 2>/dev/null; then
        print_success "Images pulled successfully"
    else
        print_warning "Some images may have failed to pull"
    fi

    # Build custom images
    print_info "Building Open edX image..."
    if tutor images build openedx; then
        print_success "Open edX image built"
    else
        print_error "Failed to build Open edX image"
        exit 1
    fi

    # Build MFE if enabled
    if tutor plugins list | grep -q "mfe.*enabled"; then
        print_info "Building MFE image..."
        if tutor images build mfe; then
            print_success "MFE image built"
        else
            print_warning "Failed to build MFE image"
        fi
    fi

    echo ""
}

# Run migrations
run_migrations() {
    print_info "Running database migrations..."

    cd "$TUTOR_ROOT"

    # Stop services first
    print_info "Stopping services..."
    tutor local stop

    # Start database services
    print_info "Starting database services..."
    tutor local start -d mysql mongodb redis
    sleep 10

    # Run migrations
    print_info "Running LMS migrations..."
    if tutor local do init --limit=lms; then
        print_success "LMS migrations complete"
    else
        print_warning "LMS migrations may have issues"
    fi

    print_info "Running CMS migrations..."
    if tutor local do init --limit=cms; then
        print_success "CMS migrations complete"
    else
        print_warning "CMS migrations may have issues"
    fi

    echo ""
}

# Restart services
restart_services() {
    print_info "Restarting all services..."

    cd "$TUTOR_ROOT"

    # Stop all services
    print_info "Stopping services..."
    tutor local stop

    # Start all services
    print_info "Starting services..."
    if tutor local start -d; then
        print_success "Services started"
    else
        print_error "Failed to start services"
        exit 1
    fi

    print_info "Waiting for services to be ready..."
    sleep 30

    echo ""
}

# Verify update
verify_update() {
    print_info "Verifying update..."

    cd "$TUTOR_ROOT"

    # Check service status
    print_info "Checking service status..."
    if tutor local status > /dev/null 2>&1; then
        print_success "All services are running"
    else
        print_warning "Some services may not be running properly"
    fi

    # Check LMS
    print_info "Checking LMS..."
    if tutor local exec lms ./manage.py lms check > /dev/null 2>&1; then
        print_success "LMS is healthy"
    else
        print_warning "LMS may have issues"
    fi

    # Check CMS
    print_info "Checking Studio..."
    if tutor local exec cms ./manage.py cms check > /dev/null 2>&1; then
        print_success "Studio is healthy"
    else
        print_warning "Studio may have issues"
    fi

    # Check for errors in logs
    print_info "Checking logs for errors..."
    ERROR_COUNT=$(tutor local logs --tail=100 2>/dev/null | grep -i "error\|exception" | wc -l || echo "0")
    if [ "$ERROR_COUNT" -eq 0 ]; then
        print_success "No errors found in recent logs"
    else
        print_warning "Found ${ERROR_COUNT} errors in recent logs"
        print_info "Review logs with: tutor local logs -f"
    fi

    echo ""
}

# Print summary
print_summary() {
    print_success "=================================================="
    print_success "Update Complete!"
    print_success "=================================================="
    echo ""

    print_info "Updated versions:"
    NEW_TUTOR_VERSION=$(tutor --version 2>&1 | head -n 1)
    print_info "  Tutor: ${NEW_TUTOR_VERSION}"

    cd "$TUTOR_ROOT"
    if [ -f "config.yml" ]; then
        OPENEDX_VERSION=$(grep "OPENEDX_COMMON_VERSION:" config.yml | awk '{print $2}' || echo "Unknown")
        print_info "  Open edX: ${OPENEDX_VERSION}"
    fi

    echo ""
    print_info "Your platform has been updated successfully!"
    echo ""
    print_info "Platform URLs:"
    print_info "  LMS: http://$(tutor config printvalue LMS_HOST)"
    print_info "  Studio: http://$(tutor config printvalue CMS_HOST)"
    echo ""
    print_info "Next steps:"
    print_info "  1. Test platform functionality"
    print_info "  2. Check course access"
    print_info "  3. Monitor logs: tutor local logs -f"
    echo ""

    if [ "$SKIP_BACKUP" = false ]; then
        print_info "If you encounter issues, restore from backup:"
        LATEST_BACKUP=$(ls -t ${PROJECT_ROOT}/backups/trigger-backup-*.tar.gz 2>/dev/null | head -n 1)
        if [ ! -z "$LATEST_BACKUP" ]; then
            print_info "  ./scripts/restore.sh ${LATEST_BACKUP}"
        fi
    fi

    echo ""
    print_success "Update completed at $(date)"
}

# Run main function
main
