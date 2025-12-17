#!/bin/bash
###############################################################################
#
# POWER-BHOOMI PKG Installer Builder (Enhanced)
# Creates a macOS .pkg installer for enterprise distribution
# Supports BOTH 4-worker and 8-worker versions
#
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $1"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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
APP_NAME="POWER-BHOOMI"
APP_VERSION="3.0.0"
PKG_IDENTIFIER="com.powerbhoomi.app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build directories
BUILD_DIR="$SCRIPT_DIR/build"
PAYLOAD_DIR="$BUILD_DIR/payload"
SCRIPTS_DIR="$BUILD_DIR/scripts"
RESOURCES_DIR="$BUILD_DIR/resources"
PKG_DIR="$SCRIPT_DIR/dist"

###############################################################################
# VERSION SELECTION
###############################################################################

select_pkg_version() {
    print_header "Select PKG Version"
    
    echo "Choose which version to package:"
    echo ""
    echo "  1) 4 Workers (Standard)"
    echo "     File: bhoomi_web_app_v2.py"
    echo "     Best for: General deployment"
    echo ""
    echo "  2) 8 Workers (HIGH-SPEED)"
    echo "     File: bhoomi_web_app_v2_8workers.py"
    echo "     Best for: High-performance machines"
    echo ""
    echo "  3) BOTH (Universal Package)"
    echo "     Includes both versions, user chooses at runtime"
    echo "     Recommended for enterprise deployment"
    echo ""
    
    read -p "Enter choice [3]: " choice
    choice=${choice:-3}
    
    case $choice in
        1)
            PKG_VERSION="4"
            PKG_SUFFIX="4workers"
            print_step "4 Workers package selected"
            ;;
        2)
            PKG_VERSION="8"
            PKG_SUFFIX="8workers"
            print_step "8 Workers package selected"
            ;;
        3)
            PKG_VERSION="universal"
            PKG_SUFFIX="universal"
            print_step "Universal package selected (both versions)"
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Output file
    OUTPUT_PKG="$PKG_DIR/$APP_NAME-v$APP_VERSION-$PKG_SUFFIX-Installer.pkg"
}

###############################################################################
# PREPARATION
###############################################################################

prepare_build_environment() {
    print_header "Preparing Build Environment"
    
    # Clean previous build
    if [ -d "$BUILD_DIR" ]; then
        print_info "Cleaning previous build..."
        rm -rf "$BUILD_DIR"
    fi
    
    # Create directories
    mkdir -p "$PAYLOAD_DIR"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$RESOURCES_DIR"
    mkdir -p "$PKG_DIR"
    
    print_step "Build environment ready"
}

###############################################################################
# PAYLOAD
###############################################################################

create_payload() {
    print_header "Creating Installer Payload"
    
    # Create application structure
    APP_ROOT="$PAYLOAD_DIR/Applications/POWER-BHOOMI"
    mkdir -p "$APP_ROOT"/{app,bin,data,logs,config,docs}
    
    # Copy application files
    print_info "Copying application files..."
    
    # Common files
    files=(
        "config.yaml"
        "config_loader.py"
        "enterprise_utils.py"
        "requirements.txt"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            cp "$SCRIPT_DIR/$file" "$APP_ROOT/app/"
            print_step "Added $file"
        else
            print_info "Skipping $file (not found)"
        fi
    done
    
    # Copy version-specific files
    if [ "$PKG_VERSION" = "4" ]; then
        cp "$SCRIPT_DIR/bhoomi_web_app_v2.py" "$APP_ROOT/app/"
        print_step "Added bhoomi_web_app_v2.py (4 workers)"
    elif [ "$PKG_VERSION" = "8" ]; then
        cp "$SCRIPT_DIR/bhoomi_web_app_v2_8workers.py" "$APP_ROOT/app/"
        print_step "Added bhoomi_web_app_v2_8workers.py (8 workers)"
    else
        # Universal: Both versions
        cp "$SCRIPT_DIR/bhoomi_web_app_v2.py" "$APP_ROOT/app/"
        cp "$SCRIPT_DIR/bhoomi_web_app_v2_8workers.py" "$APP_ROOT/app/"
        print_step "Added both versions (universal package)"
    fi
    
    # Copy scripts
    if [ -f "$SCRIPT_DIR/install-enterprise.sh" ]; then
        cp "$SCRIPT_DIR/install-enterprise.sh" "$APP_ROOT/"
    fi
    
    if [ -f "$SCRIPT_DIR/com.powerbhoomi.app.plist" ]; then
        cp "$SCRIPT_DIR/com.powerbhoomi.app.plist" "$APP_ROOT/config/"
    fi
    
    # Copy documentation
    docs=(
        "README.md"
        "ENTERPRISE_README.md"
        "ENTERPRISE_INSTALL_GUIDE.md"
        "8_WORKERS_VERSION_INFO.md"
        "STOP_SEARCH_FIX.md"
    )
    
    for doc in "${docs[@]}"; do
        if [ -f "$SCRIPT_DIR/$doc" ]; then
            cp "$SCRIPT_DIR/$doc" "$APP_ROOT/docs/"
        fi
    done
    
    print_step "Payload created"
}

###############################################################################
# INSTALLER SCRIPTS
###############################################################################

create_installer_scripts() {
    print_header "Creating Installer Scripts"
    
    # Preinstall script
    cat > "$SCRIPTS_DIR/preinstall" << 'EOPREINSTALL'
#!/bin/bash
# Pre-installation checks

# Check macOS version
macos_version=$(sw_vers -productVersion)
macos_major=$(echo "$macos_version" | cut -d'.' -f1)
macos_minor=$(echo "$macos_version" | cut -d'.' -f2)

if [ "$macos_major" -lt 10 ] || ([ "$macos_major" -eq 10 ] && [ "$macos_minor" -lt 14 ]); then
    echo "ERROR: macOS 10.14 or later required"
    exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "WARNING: Python 3 not found. Installation may fail."
fi

exit 0
EOPREINSTALL
    
    # Postinstall script (enhanced for both versions)
    cat > "$SCRIPTS_DIR/postinstall" << 'EOPOSTINSTALL'
#!/bin/bash
# Post-installation setup

APP_DIR="/Applications/POWER-BHOOMI"
USER_HOME=$(eval echo ~$USER)

# Create user directories
mkdir -p "$USER_HOME/Documents/POWER-BHOOMI"
mkdir -p "$USER_HOME/Library/Logs/POWER-BHOOMI"
mkdir -p "$USER_HOME/.config/power-bhoomi"

# Copy config to user directory
cp "$APP_DIR/app/config.yaml" "$USER_HOME/.config/power-bhoomi/"

# Create virtual environment
cd "$APP_DIR/app"
python3 -m venv venv

# Install dependencies
./venv/bin/pip install --upgrade pip > /dev/null 2>&1
./venv/bin/pip install -r requirements.txt

# Determine which version is default (check which file exists)
if [ -f "$APP_DIR/app/bhoomi_web_app_v2_8workers.py" ] && [ ! -f "$APP_DIR/app/bhoomi_web_app_v2.py" ]; then
    DEFAULT_APP="bhoomi_web_app_v2_8workers.py"
    DEFAULT_WORKERS="8"
elif [ -f "$APP_DIR/app/bhoomi_web_app_v2.py" ] && [ ! -f "$APP_DIR/app/bhoomi_web_app_v2_8workers.py" ]; then
    DEFAULT_APP="bhoomi_web_app_v2.py"
    DEFAULT_WORKERS="4"
else
    # Both versions present - default to 4 workers
    DEFAULT_APP="bhoomi_web_app_v2.py"
    DEFAULT_WORKERS="4"
fi

# Create launcher scripts
cat > "$APP_DIR/bin/power-bhoomi" << EOLAUNCHER
#!/bin/bash
cd /Applications/POWER-BHOOMI/app
source venv/bin/activate
python3 $DEFAULT_APP "\$@"
EOLAUNCHER

cat > "$APP_DIR/bin/power-bhoomi-4w" << 'EOLAUNCHER4'
#!/bin/bash
cd /Applications/POWER-BHOOMI/app
source venv/bin/activate
python3 bhoomi_web_app_v2.py "$@"
EOLAUNCHER4

cat > "$APP_DIR/bin/power-bhoomi-8w" << 'EOLAUNCHER8'
#!/bin/bash
cd /Applications/POWER-BHOOMI/app
source venv/bin/activate
python3 bhoomi_web_app_v2_8workers.py "$@"
EOLAUNCHER8

chmod +x "$APP_DIR/bin/power-bhoomi"
chmod +x "$APP_DIR/bin/power-bhoomi-4w"
chmod +x "$APP_DIR/bin/power-bhoomi-8w"

# Create admin tool
cat > "$APP_DIR/bin/power-bhoomi-admin" << 'EOADMIN'
#!/bin/bash
case "$1" in
    start) /Applications/POWER-BHOOMI/bin/power-bhoomi & ;;
    start-4w) /Applications/POWER-BHOOMI/bin/power-bhoomi-4w & ;;
    start-8w) /Applications/POWER-BHOOMI/bin/power-bhoomi-8w & ;;
    stop) pkill -f "bhoomi_web_app_v2" ;;
    restart) $0 stop; sleep 2; $0 start ;;
    status) 
        if pgrep -f "bhoomi_web_app_v2" > /dev/null; then
            echo "POWER-BHOOMI is running"
            pgrep -fl "bhoomi_web_app_v2"
        else
            echo "POWER-BHOOMI is stopped"
        fi
        ;;
    logs) tail -f ~/Library/Logs/POWER-BHOOMI/application.log ;;
    version)
        if pgrep -f "bhoomi_web_app_v2_8workers" > /dev/null; then
            echo "Running: 8 Workers (HIGH-SPEED)"
        elif pgrep -f "bhoomi_web_app_v2.py" > /dev/null; then
            echo "Running: 4 Workers (Standard)"
        else
            echo "Not running"
        fi
        ;;
    *)
        echo "Usage: power-bhoomi-admin {start|start-4w|start-8w|stop|restart|status|logs|version}"
        exit 1
        ;;
esac
EOADMIN

chmod +x "$APP_DIR/bin/power-bhoomi-admin"

# Add to PATH
if [ -f "$USER_HOME/.zshrc" ]; then
    if ! grep -q "POWER-BHOOMI" "$USER_HOME/.zshrc"; then
        echo 'export PATH="/Applications/POWER-BHOOMI/bin:$PATH"' >> "$USER_HOME/.zshrc"
    fi
fi

# Set permissions
chown -R $USER:staff "$USER_HOME/Documents/POWER-BHOOMI"
chown -R $USER:staff "$USER_HOME/Library/Logs/POWER-BHOOMI"
chown -R $USER:staff "$USER_HOME/.config/power-bhoomi"

# Create version info
cat > "$APP_DIR/VERSION.txt" << EOVERSION
POWER-BHOOMI v$APP_VERSION
Installed: $(date)
Default Workers: $DEFAULT_WORKERS

Available Commands:
  power-bhoomi       - Start default ($DEFAULT_WORKERS workers)
  power-bhoomi-4w    - Start 4 workers version
  power-bhoomi-8w    - Start 8 workers version
  power-bhoomi-admin - Admin tool
EOVERSION

echo "POWER-BHOOMI installed successfully!"
exit 0
EOPOSTINSTALL
    
    # Make scripts executable
    chmod +x "$SCRIPTS_DIR/preinstall"
    chmod +x "$SCRIPTS_DIR/postinstall"
    
    print_step "Installer scripts created"
}

###############################################################################
# RESOURCES
###############################################################################

create_resources() {
    print_header "Creating Resources"
    
    # Version-specific welcome message
    if [ "$PKG_VERSION" = "universal" ]; then
        version_text="Universal Package - Choose 4 or 8 Workers"
        version_description="This package includes both 4-worker and 8-worker versions. You can choose which to use based on your system resources."
    elif [ "$PKG_VERSION" = "8" ]; then
        version_text="8 Workers HIGH-SPEED Edition"
        version_description="This package includes the high-performance 8-worker version. Requires 16GB RAM minimum for optimal performance."
    else
        version_text="4 Workers Standard Edition"
        version_description="This package includes the standard 4-worker version. Works great on systems with 8GB RAM or more."
    fi
    
    # Welcome message
    cat > "$RESOURCES_DIR/welcome.html" << EOWELCOME
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 20px; }
        h1 { color: #f59e0b; }
        .version-badge { background: #f59e0b; color: white; padding: 5px 15px; border-radius: 5px; display: inline-block; }
        .feature { margin: 10px 0; padding: 10px; background: #f3f4f6; border-radius: 5px; }
        .icon { font-size: 1.5em; margin-right: 10px; }
        .warning { background: #fef3c7; border-left: 3px solid #f59e0b; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Welcome to POWER-BHOOMI v3.0</h1>
    <p class="version-badge">$version_text</p>
    <p>Karnataka Land Records Search Tool - Enterprise Edition</p>
    <p><em>$version_description</em></p>
    
    <h2>Features</h2>
    <div class="feature"><span class="icon">🚀</span> Parallel Browser Workers</div>
    <div class="feature"><span class="icon">🛡️</span> Bulletproof Session Recovery</div>
    <div class="feature"><span class="icon">💾</span> Real-time SQLite Database</div>
    <div class="feature"><span class="icon">📊</span> Sequential Survey Checking</div>
    <div class="feature"><span class="icon">⚡</span> Responsive Stop Button (FIXED!)</div>
    <div class="feature"><span class="icon">🍎</span> Optimized for macOS</div>
    
    <h2>System Requirements</h2>
    <ul>
        <li>macOS 10.14 or later</li>
        <li>8 GB RAM minimum (16 GB for 8 workers)</li>
        <li>2 GB free disk space</li>
        <li>Google Chrome (latest version)</li>
        <li>Python 3.8 or later</li>
    </ul>
    
    <div class="warning">
        <strong>⚠️ Important:</strong> Make sure Google Chrome is installed before proceeding.
    </div>
    
    <p><strong>Click Continue to install POWER-BHOOMI.</strong></p>
</body>
</html>
EOWELCOME
    
    # README
    cat > "$RESOURCES_DIR/readme.html" << EOREADME
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 20px; }
        h1 { color: #f59e0b; }
        code { background: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
        .command-box { background: #1a2332; color: #f3f4f6; padding: 15px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Getting Started</h1>
    
    <h2>Quick Start</h2>
    <ol>
        <li>Complete the installation</li>
        <li>Open Terminal (⌘+Space, type "Terminal")</li>
        <li>Run: <code>power-bhoomi</code></li>
        <li>Open browser: <code>http://localhost:5001</code></li>
    </ol>
    
    <h2>Available Commands</h2>
    <div class="command-box">
power-bhoomi       # Start default version<br>
power-bhoomi-4w    # Start 4 workers version<br>
power-bhoomi-8w    # Start 8 workers version<br>
power-bhoomi-admin # Admin tool
    </div>
    
    <h2>Admin Commands</h2>
    <ul>
        <li><code>power-bhoomi-admin start</code> - Start service</li>
        <li><code>power-bhoomi-admin start-4w</code> - Start 4 workers</li>
        <li><code>power-bhoomi-admin start-8w</code> - Start 8 workers</li>
        <li><code>power-bhoomi-admin stop</code> - Stop service</li>
        <li><code>power-bhoomi-admin status</code> - Check status</li>
        <li><code>power-bhoomi-admin logs</code> - View logs</li>
        <li><code>power-bhoomi-admin version</code> - Show which version is running</li>
    </ul>
    
    <h2>Choosing Workers</h2>
    <p><strong>4 Workers:</strong> Use for searches with &lt;50 villages, systems with 8GB RAM</p>
    <p><strong>8 Workers:</strong> Use for searches with 50+ villages, systems with 16GB+ RAM (2x faster!)</p>
    
    <h2>Data Locations</h2>
    <ul>
        <li>Application: <code>/Applications/POWER-BHOOMI</code></li>
        <li>Data: <code>~/Documents/POWER-BHOOMI</code></li>
        <li>Logs: <code>~/Library/Logs/POWER-BHOOMI</code></li>
        <li>Config: <code>~/.config/power-bhoomi</code></li>
    </ul>
    
    <h2>Support</h2>
    <p>For documentation, see the <code>docs</code> folder in the installation directory.</p>
    <p>Access at: <code>/Applications/POWER-BHOOMI/docs/</code></p>
</body>
</html>
EOREADME
    
    # License
    cat > "$RESOURCES_DIR/license.txt" << 'EOLICENSE'
POWER-BHOOMI SOFTWARE LICENSE

Copyright (c) 2025 POWER-BHOOMI Team

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
EOLICENSE
    
    print_step "Resources created"
}

###############################################################################
# BUILD PKG
###############################################################################

build_package() {
    print_header "Building PKG Installer"
    
    print_info "This may take a few minutes..."
    
    # Build component package
    pkgbuild \
        --root "$PAYLOAD_DIR" \
        --scripts "$SCRIPTS_DIR" \
        --identifier "$PKG_IDENTIFIER" \
        --version "$APP_VERSION" \
        --install-location "/" \
        "$BUILD_DIR/component.pkg"
    
    print_step "Component package created"
    
    # Create distribution XML
    cat > "$BUILD_DIR/distribution.xml" << EODIST
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>$APP_NAME</title>
    <organization>com.powerbhoomi</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="true" hostArchitectures="x86_64,arm64"/>
    
    <welcome file="welcome.html" mime-type="text/html"/>
    <readme file="readme.html" mime-type="text/html"/>
    <license file="license.txt" mime-type="text/plain"/>
    
    <pkg-ref id="$PKG_IDENTIFIER">
        <bundle-version>
            <bundle id="$PKG_IDENTIFIER" CFBundleShortVersionString="$APP_VERSION"/>
        </bundle-version>
    </pkg-ref>
    
    <choices-outline>
        <line choice="default">
            <line choice="$PKG_IDENTIFIER"/>
        </line>
    </choices-outline>
    
    <choice id="default"/>
    <choice id="$PKG_IDENTIFIER" visible="false">
        <pkg-ref id="$PKG_IDENTIFIER"/>
    </choice>
    
    <pkg-ref id="$PKG_IDENTIFIER" version="$APP_VERSION">component.pkg</pkg-ref>
</installer-gui-script>
EODIST
    
    # Build product package
    productbuild \
        --distribution "$BUILD_DIR/distribution.xml" \
        --resources "$RESOURCES_DIR" \
        --package-path "$BUILD_DIR" \
        "$OUTPUT_PKG"
    
    print_step "Product package created"
}

###############################################################################
# FINALIZE
###############################################################################

finalize() {
    print_header "Finalization"
    
    # Get package size
    pkg_size=$(du -h "$OUTPUT_PKG" | cut -f1)
    
    print_step "Package built successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Output: $OUTPUT_PKG"
    echo "Size: $pkg_size"
    echo "Version: $PKG_VERSION workers ($PKG_SUFFIX)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To distribute:"
    echo "  1. Test the installer on a clean macOS system"
    echo "  2. Optional: Code sign with your Developer ID:"
    echo "     codesign -s \"Developer ID Installer\" \"$OUTPUT_PKG\""
    echo "  3. Distribute via:"
    echo "     • MDM (Jamf, Intune, Munki)"
    echo "     • Self-service portal"
    echo "     • Direct file transfer"
    echo ""
    echo "To test locally:"
    echo "  sudo installer -pkg \"$OUTPUT_PKG\" -target /"
    echo ""
}

###############################################################################
# MAIN
###############################################################################

main() {
    clear
    
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║               PKG Installer Builder (Enhanced)                    ║
║                   POWER-BHOOMI v3.0                               ║
║         Supports 4 Workers AND 8 Workers Versions                 ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    
    echo ""
    
    select_pkg_version
    prepare_build_environment
    create_payload
    create_installer_scripts
    create_resources
    build_package
    finalize
    
    print_step "Build complete!"
}

main "$@"

