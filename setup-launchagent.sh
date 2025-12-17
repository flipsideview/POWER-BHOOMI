#!/bin/bash
###############################################################################
# POWER-BHOOMI LaunchAgent Setup Script
# Sets up the application to run automatically on login
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Configuration
PLIST_TEMPLATE="com.powerbhoomi.app.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_DEST="$LAUNCH_AGENTS_DIR/com.powerbhoomi.app.plist"
APP_DIR="$HOME/Applications/POWER-BHOOMI"

# Check if template exists
if [ ! -f "$PLIST_TEMPLATE" ]; then
    print_error "Template file not found: $PLIST_TEMPLATE"
    exit 1
fi

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Copy and customize plist
print_info "Configuring LaunchAgent..."

# Replace USER placeholder with actual username
sed "s/USER/$USER/g" "$PLIST_TEMPLATE" > "$PLIST_DEST"

print_step "LaunchAgent configuration created"

# Unload existing service (if any)
if launchctl list | grep -q "com.powerbhoomi.app"; then
    print_info "Stopping existing service..."
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
fi

# Load the new service
print_info "Loading LaunchAgent..."
launchctl load "$PLIST_DEST"

# Verify it's running
sleep 2
if launchctl list | grep -q "com.powerbhoomi.app"; then
    print_step "LaunchAgent loaded successfully"
    print_info "POWER-BHOOMI will now start automatically on login"
else
    print_error "Failed to load LaunchAgent"
    exit 1
fi

echo ""
print_info "LaunchAgent Commands:"
echo "  Start:   launchctl start com.powerbhoomi.app"
echo "  Stop:    launchctl stop com.powerbhoomi.app"
echo "  Remove:  launchctl unload $PLIST_DEST"
echo ""

print_step "Setup complete!"

