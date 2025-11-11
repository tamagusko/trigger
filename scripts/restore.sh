#!/bin/bash
#
# TRIGGER Open edX Restore Script
# This script restores Open edX from a backup archive
#
# Usage: ./restore.sh BACKUP_FILE [--force]
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
TEMP_RESTORE_DIR="${PROJECT_ROOT}/backups/temp/restore"

# Options
BACKUP_FILE=""
FORCE_RESTORE=false

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
        --force)
            FORCE_RESTORE=true
            shift
            ;;
        --help)
            echo "Usage: $0 BACKUP_FILE [OPTIONS]"
            echo ""
            echo "Arguments:"
            echo "  BACKUP_FILE    Path to backup archive (.tar.gz)"
            echo ""
            echo "Options:"
            echo "  --force        Skip confirmation prompts"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 backups/trigger-backup-20240115.tar.gz"
            echo "  $0 s3://bucket/backup.tar.gz --force"
            exit 0
            ;;
        *)
            if [ -z "$BACKUP_FILE" ]; then
                BACKUP_FILE="$1"
                shift
            else
                print_error "Unknown option: $1"
                exit 1
            fi
            ;;
    esac
done

# Validate backup file
if [ -z "$BACKUP_FILE" ]; then
    print_error "No backup file specified!"
    echo ""
    echo "Usage: $0 BACKUP_FILE [--force]"
    echo "Try '$0 --help' for more information."
    exit 1
fi

# Main restore function
main() {
    print_info "=================================================="
    print_info "TRIGGER Open edX Restore - $(date)"
    print_info "=================================================="
    echo ""

    # Warning message
    print_warning "WARNING: This will restore the platform from a backup."
    print_warning "All current data will be replaced!"
    echo ""

    if [ "$FORCE_RESTORE" = false ]; then
        read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation
        if [ "$confirmation" != "yes" ]; then
            print_info "Restore cancelled."
            exit 0
        fi
    fi

    # Check prerequisites
    check_prerequisites

    # Download/extract backup
    prepare_backup

    # Create current backup before restore
    create_safety_backup

    # Stop services
    stop_services

    # Restore configuration
    restore_configuration

    # Restore databases
    restore_databases

    # Restore course data
    restore_data

    # Start services
    start_services

    # Verify restore
    verify_restore

    # Clean up
    cleanup

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

    # Check backup file exists
    if [[ "$BACKUP_FILE" == s3://* ]]; then
        # S3 backup
        if ! command -v aws &> /dev/null; then
            print_error "AWS CLI is not installed!"
            print_info "Install with: pip install awscli"
            exit 1
        fi
        print_info "Backup source: S3"
    elif [ ! -f "$BACKUP_FILE" ]; then
        print_error "Backup file not found: $BACKUP_FILE"
        exit 1
    else
        print_info "Backup source: Local file"
    fi

    print_success "Prerequisites check complete"
    echo ""
}

# Prepare backup
prepare_backup() {
    print_info "Preparing backup for restore..."

    # Create temp directory
    mkdir -p "$TEMP_RESTORE_DIR"

    # Download from S3 if needed
    if [[ "$BACKUP_FILE" == s3://* ]]; then
        print_info "Downloading backup from S3..."
        LOCAL_BACKUP="/tmp/restore-backup.tar.gz"
        if aws s3 cp "$BACKUP_FILE" "$LOCAL_BACKUP"; then
            BACKUP_FILE="$LOCAL_BACKUP"
            print_success "Backup downloaded"
        else
            print_error "Failed to download backup from S3"
            exit 1
        fi
    fi

    # Extract backup archive
    print_info "Extracting backup archive..."
    if tar -xzf "$BACKUP_FILE" -C "$TEMP_RESTORE_DIR" --strip-components=1; then
        print_success "Backup extracted"
    else
        print_error "Failed to extract backup archive"
        exit 1
    fi

    # Show backup metadata
    if [ -f "$TEMP_RESTORE_DIR/backup-metadata.txt" ]; then
        echo ""
        print_info "Backup Information:"
        cat "$TEMP_RESTORE_DIR/backup-metadata.txt" | sed 's/^/  /'
        echo ""
    fi

    echo ""
}

# Create safety backup
create_safety_backup() {
    print_info "Creating safety backup of current state..."

    if [ -x "${SCRIPT_DIR}/backup.sh" ]; then
        SAFETY_BACKUP="${PROJECT_ROOT}/backups/pre-restore-$(date +%Y%m%d-%H%M%S).tar.gz"
        if "${SCRIPT_DIR}/backup.sh" > /dev/null 2>&1; then
            print_success "Safety backup created"
            print_info "  You can restore from this if needed"
        else
            print_warning "Failed to create safety backup"
            if [ "$FORCE_RESTORE" = false ]; then
                read -p "Continue without safety backup? (y/n) " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        fi
    else
        print_warning "Backup script not found, skipping safety backup"
    fi

    echo ""
}

# Stop services
stop_services() {
    print_info "Stopping Open edX services..."

    cd "$TUTOR_ROOT"

    if tutor local stop; then
        print_success "Services stopped"
    else
        print_warning "Some services may still be running"
    fi

    echo ""
}

# Restore configuration
restore_configuration() {
    print_info "Restoring configuration..."

    # Restore config.yml
    if [ -f "$TEMP_RESTORE_DIR/config.yml" ]; then
        cp "$TEMP_RESTORE_DIR/config.yml" "$TUTOR_ROOT/config.yml"
        print_success "Configuration restored"
    else
        print_warning "config.yml not found in backup"
    fi

    echo ""
}

# Restore databases
restore_databases() {
    print_info "Restoring databases..."

    # Start database services
    cd "$TUTOR_ROOT"
    print_info "Starting database services..."
    tutor local start -d mysql mongodb
    sleep 10

    # Restore MySQL
    if [ -f "$TEMP_RESTORE_DIR/mysql.sql" ]; then
        print_info "  - Restoring MySQL database..."
        if tutor local exec -i mysql mysql < "$TEMP_RESTORE_DIR/mysql.sql" 2>/dev/null; then
            print_success "  MySQL restored"
        else
            print_error "  MySQL restore failed!"
        fi
    else
        print_warning "  MySQL backup not found"
    fi

    # Restore MongoDB
    if [ -f "$TEMP_RESTORE_DIR/mongodb.archive" ]; then
        print_info "  - Restoring MongoDB database..."
        if tutor local cp "$TEMP_RESTORE_DIR/mongodb.archive" mongodb:/tmp/restore.archive 2>/dev/null; then
            if tutor local exec mongodb mongorestore --archive=/tmp/restore.archive --gzip --drop 2>/dev/null; then
                print_success "  MongoDB restored"
            else
                print_error "  MongoDB restore failed!"
            fi
        else
            print_warning "  Failed to copy MongoDB backup"
        fi
    else
        print_warning "  MongoDB backup not found"
    fi

    echo ""
}

# Restore course data
restore_data() {
    print_info "Restoring course data and media files..."

    # Restore OpenEdX data
    if [ -f "$TEMP_RESTORE_DIR/openedx-data.tar.gz" ]; then
        print_info "  - Extracting course data..."

        # Backup current data directory (if exists)
        if [ -d "$TUTOR_ROOT/data" ]; then
            mv "$TUTOR_ROOT/data" "$TUTOR_ROOT/data.backup.$(date +%Y%m%d-%H%M%S)"
        fi

        # Extract data
        if tar -xzf "$TEMP_RESTORE_DIR/openedx-data.tar.gz" -C "$TUTOR_ROOT"; then
            print_success "  Course data restored"
        else
            print_error "  Failed to restore course data"
        fi
    else
        print_warning "  Course data backup not found"
    fi

    echo ""
}

# Start services
start_services() {
    print_info "Starting Open edX services..."

    cd "$TUTOR_ROOT"

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

# Verify restore
verify_restore() {
    print_info "Verifying restore..."

    cd "$TUTOR_ROOT"

    # Check service status
    print_info "Checking service status..."
    if tutor local status > /dev/null 2>&1; then
        print_success "All services are running"
    else
        print_warning "Some services may not be running properly"
    fi

    # Check LMS
    print_info "Checking LMS connectivity..."
    if tutor local exec lms ./manage.py lms check --deploy > /dev/null 2>&1; then
        print_success "LMS is responding"
    else
        print_warning "LMS may have issues"
    fi

    # Check CMS
    print_info "Checking Studio connectivity..."
    if tutor local exec cms ./manage.py cms check --deploy > /dev/null 2>&1; then
        print_success "Studio is responding"
    else
        print_warning "Studio may have issues"
    fi

    echo ""
}

# Cleanup
cleanup() {
    print_info "Cleaning up temporary files..."

    # Remove temp directory
    if [ -d "$TEMP_RESTORE_DIR" ]; then
        rm -rf "$TEMP_RESTORE_DIR"
    fi

    # Remove downloaded S3 backup
    if [ -f "/tmp/restore-backup.tar.gz" ]; then
        rm -f "/tmp/restore-backup.tar.gz"
    fi

    print_success "Cleanup complete"
    echo ""
}

# Print summary
print_summary() {
    print_success "=================================================="
    print_success "Restore Complete!"
    print_success "=================================================="
    echo ""
    print_info "Your Open edX platform has been restored from backup."
    echo ""
    print_info "Next steps:"
    print_info "  1. Verify platform access:"
    print_info "     - LMS: $(tutor config printvalue LMS_HOST)"
    print_info "     - Studio: $(tutor config printvalue CMS_HOST)"
    echo ""
    print_info "  2. Check logs for any errors:"
    print_info "     tutor local logs -f"
    echo ""
    print_info "  3. Test course access and functionality"
    echo ""
    print_warning "If you encounter issues, you can restore from the safety backup:"
    print_warning "  $(ls -t ${PROJECT_ROOT}/backups/pre-restore-*.tar.gz 2>/dev/null | head -n 1)"
    echo ""
}

# Run main function
main
