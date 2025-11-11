#!/bin/bash
#
# TRIGGER Open edX Backup Script
# This script creates comprehensive backups of the Open edX platform
#
# Usage: ./backup.sh [--s3] [--retention DAYS]
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
BACKUP_ROOT="${PROJECT_ROOT}/backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="trigger-backup-${DATE}"
TEMP_BACKUP_DIR="${BACKUP_ROOT}/temp/${BACKUP_NAME}"

# Options
UPLOAD_TO_S3=false
RETENTION_DAYS=7
S3_BUCKET=""

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
        --s3)
            UPLOAD_TO_S3=true
            S3_BUCKET="$2"
            shift 2
            ;;
        --retention)
            RETENTION_DAYS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --s3 BUCKET        Upload backup to S3 bucket"
            echo "  --retention DAYS   Number of days to keep backups (default: 7)"
            echo "  --help             Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main backup function
main() {
    print_info "=================================================="
    print_info "TRIGGER Open edX Backup - $(date)"
    print_info "=================================================="
    echo ""

    # Create backup directories
    create_backup_directories

    # Check prerequisites
    check_prerequisites

    # Backup databases
    backup_databases

    # Backup Tutor configuration
    backup_configuration

    # Backup course data
    backup_data

    # Create backup archive
    create_archive

    # Upload to S3 if requested
    if [ "$UPLOAD_TO_S3" = true ]; then
        upload_to_s3
    fi

    # Clean up old backups
    cleanup_old_backups

    # Print summary
    print_summary
}

# Create backup directories
create_backup_directories() {
    mkdir -p "${BACKUP_ROOT}"
    mkdir -p "${TEMP_BACKUP_DIR}"
    mkdir -p "${BACKUP_ROOT}/weekly"
    mkdir -p "${BACKUP_ROOT}/monthly"
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

    # Check if services are running
    cd "$TUTOR_ROOT"
    if ! tutor local status &> /dev/null; then
        print_warning "Some services may not be running"
    fi

    # Check disk space
    available_space=$(df -BG "${BACKUP_ROOT}" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 10 ]; then
        print_warning "Low disk space: ${available_space}GB available"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_success "Prerequisites check complete"
    echo ""
}

# Backup databases
backup_databases() {
    print_info "Backing up databases..."

    cd "$TUTOR_ROOT"

    # Backup MySQL
    print_info "  - MySQL database..."
    if tutor local exec mysql mysqldump --all-databases --single-transaction --quick --lock-tables=false > "${TEMP_BACKUP_DIR}/mysql.sql" 2>/dev/null; then
        print_success "  MySQL backup complete ($(du -h "${TEMP_BACKUP_DIR}/mysql.sql" | cut -f1))"
    else
        print_error "  MySQL backup failed!"
        # Continue with other backups
    fi

    # Backup MongoDB
    print_info "  - MongoDB database..."
    if tutor local exec mongodb mongodump --archive=/tmp/mongodb-backup.archive --gzip 2>/dev/null; then
        if tutor local cp mongodb:/tmp/mongodb-backup.archive "${TEMP_BACKUP_DIR}/mongodb.archive" 2>/dev/null; then
            print_success "  MongoDB backup complete ($(du -h "${TEMP_BACKUP_DIR}/mongodb.archive" | cut -f1))"
        else
            print_warning "  Failed to copy MongoDB backup"
        fi
    else
        print_error "  MongoDB backup failed!"
    fi

    echo ""
}

# Backup configuration
backup_configuration() {
    print_info "Backing up configuration files..."

    cd "$TUTOR_ROOT"

    # Backup config.yml (without secrets)
    if [ -f "config.yml" ]; then
        cp config.yml "${TEMP_BACKUP_DIR}/config.yml"
        print_success "  Configuration backed up"
    else
        print_warning "  config.yml not found"
    fi

    # Create a metadata file
    cat > "${TEMP_BACKUP_DIR}/backup-metadata.txt" << EOF
Backup Date: $(date)
Backup Name: ${BACKUP_NAME}
Tutor Version: $(tutor --version 2>&1 | head -n 1)
Docker Version: $(docker --version)
Platform: $(uname -a)
EOF

    print_success "  Metadata created"
    echo ""
}

# Backup course data
backup_data() {
    print_info "Backing up course data and media files..."

    cd "$TUTOR_ROOT"

    # Check if data directory exists
    if [ ! -d "data" ]; then
        print_warning "  Data directory not found, skipping..."
        return
    fi

    # Backup OpenEdX data (excluding logs)
    print_info "  - Course content and media files..."

    # Create tar of data directory, excluding logs
    if tar -czf "${TEMP_BACKUP_DIR}/openedx-data.tar.gz" \
        --exclude='data/*/logs/*' \
        --exclude='data/*/log/*' \
        --exclude='*.log' \
        -C "$TUTOR_ROOT" data/ 2>/dev/null; then
        print_success "  Course data backed up ($(du -h "${TEMP_BACKUP_DIR}/openedx-data.tar.gz" | cut -f1))"
    else
        print_error "  Failed to backup course data"
    fi

    echo ""
}

# Create backup archive
create_archive() {
    print_info "Creating backup archive..."

    cd "${BACKUP_ROOT}/temp"

    # Create compressed archive
    if tar -czf "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"; then
        ARCHIVE_SIZE=$(du -h "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" | cut -f1)
        print_success "Backup archive created: ${BACKUP_NAME}.tar.gz (${ARCHIVE_SIZE})"
    else
        print_error "Failed to create backup archive!"
        exit 1
    fi

    # Remove temporary directory
    rm -rf "${TEMP_BACKUP_DIR}"

    # Create weekly backup (Sundays)
    if [ $(date +%u) -eq 7 ]; then
        cp "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" "${BACKUP_ROOT}/weekly/${BACKUP_NAME}.tar.gz"
        print_info "Weekly backup copy created"
    fi

    # Create monthly backup (1st of month)
    if [ $(date +%d) -eq 01 ]; then
        cp "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" "${BACKUP_ROOT}/monthly/${BACKUP_NAME}.tar.gz"
        print_info "Monthly backup copy created"
    fi

    echo ""
}

# Upload to S3
upload_to_s3() {
    print_info "Uploading backup to S3..."

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed!"
        print_info "Install with: pip install awscli"
        return
    fi

    # Check if bucket is specified
    if [ -z "$S3_BUCKET" ]; then
        print_error "S3 bucket not specified!"
        return
    fi

    # Upload to S3
    if aws s3 cp "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" "s3://${S3_BUCKET}/backups/" 2>/dev/null; then
        print_success "Backup uploaded to s3://${S3_BUCKET}/backups/${BACKUP_NAME}.tar.gz"
    else
        print_error "Failed to upload backup to S3"
    fi

    echo ""
}

# Clean up old backups
cleanup_old_backups() {
    print_info "Cleaning up old backups..."

    # Remove backups older than retention period
    if [ "$RETENTION_DAYS" -gt 0 ]; then
        find "${BACKUP_ROOT}" -maxdepth 1 -name "trigger-backup-*.tar.gz" -mtime +"${RETENTION_DAYS}" -delete
        print_success "Removed backups older than ${RETENTION_DAYS} days"
    fi

    # Keep only last 4 weekly backups
    cd "${BACKUP_ROOT}/weekly"
    ls -t trigger-backup-*.tar.gz 2>/dev/null | tail -n +5 | xargs -r rm
    print_info "Kept last 4 weekly backups"

    # Keep only last 12 monthly backups
    cd "${BACKUP_ROOT}/monthly"
    ls -t trigger-backup-*.tar.gz 2>/dev/null | tail -n +13 | xargs -r rm
    print_info "Kept last 12 monthly backups"

    echo ""
}

# Print summary
print_summary() {
    print_success "=================================================="
    print_success "Backup Complete!"
    print_success "=================================================="
    echo ""
    print_info "Backup Details:"
    print_info "  Name: ${BACKUP_NAME}.tar.gz"
    print_info "  Location: ${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz"
    print_info "  Size: $(du -h "${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz" | cut -f1)"
    print_info "  Date: $(date)"
    echo ""
    print_info "Available backups:"
    ls -lh "${BACKUP_ROOT}"/trigger-backup-*.tar.gz 2>/dev/null | tail -n 5
    echo ""
    print_info "To restore from this backup, run:"
    print_info "  ./scripts/restore.sh ${BACKUP_ROOT}/${BACKUP_NAME}.tar.gz"
    echo ""
}

# Run main function
main
