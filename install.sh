#!/bin/bash
###############################################################################
#
# POWER-BHOOMI Enterprise Installer (Enhanced)
# Version: 3.0.0
# Platform: macOS 10.14+
#
# Supports BOTH 4-worker and 8-worker versions
#
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="POWER-BHOOMI"
APP_VERSION="3.0.0"
INSTALL_TYPE=""  # user or system
INSTALL_DIR=""
DATA_DIR=""
LOG_DIR=""
CONFIG_DIR=""
WORKER_VERSION=""  # 4 or 8
APP_FILE=""  # bhoomi_web_app_v2.py or bhoomi_web_app_v2_8workers.py

# System check flags
PYTHON_OK=false
CHROME_OK=false
DISK_OK=false
RAM_OK=false

###############################################################################
# UTILITY FUNCTIONS
###############################################################################

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

confirm() {
    read -p "$1 [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

###############################################################################
# PRE-FLIGHT CHECKS
###############################################################################

check_macos_version() {
    print_info "Checking macOS version..."
    
    macos_version=$(sw_vers -productVersion)
    macos_major=$(echo "$macos_version" | cut -d'.' -f1)
    macos_minor=$(echo "$macos_version" | cut -d'.' -f2)
    
    if [ "$macos_major" -ge 11 ] || ([ "$macos_major" -eq 10 ] && [ "$macos_minor" -ge 14 ]); then
        print_step "macOS $macos_version (supported)"
        return 0
    else
        print_error "macOS $macos_version (requires 10.14 or later)"
        return 1
    fi
}

check_python() {
    print_info "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version | awk '{print $2}')
        python_major=$(echo "$python_version" | cut -d'.' -f1)
        python_minor=$(echo "$python_version" | cut -d'.' -f2)
        
        if [ "$python_major" -ge 3 ] && [ "$python_minor" -ge 8 ]; then
            print_step "Python $python_version (supported)"
            PYTHON_OK=true
            return 0
        fi
    fi
    
    print_warning "Python 3.8+ not found"
    PYTHON_OK=false
    return 1
}

check_chrome() {
    print_info "Checking Google Chrome..."
    
    chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    if [ -f "$chrome_path" ]; then
        chrome_version=$("$chrome_path" --version | awk '{print $3}')
        print_step "Google Chrome $chrome_version found"
        CHROME_OK=true
        return 0
    else
        print_warning "Google Chrome not found (required for web scraping)"
        CHROME_OK=false
        return 1
    fi
}

check_disk_space() {
    print_info "Checking disk space..."
    
    available=$(df -H / | awk 'NR==2 {print $4}' | sed 's/G//')
    available_int=$(echo "$available" | cut -d'.' -f1)
    
    if [ "$available_int" -ge 2 ]; then
        print_step "Disk space: ${available}GB available (sufficient)"
        DISK_OK=true
        return 0
    else
        print_error "Disk space: ${available}GB available (need at least 2GB)"
        DISK_OK=false
        return 1
    fi
}

check_memory() {
    print_info "Checking system memory..."
    
    total_ram=$(sysctl -n hw.memsize)
    ram_gb=$((total_ram / 1024 / 1024 / 1024))
    
    if [ "$ram_gb" -ge 8 ]; then
        print_step "RAM: ${ram_gb}GB (sufficient)"
        RAM_OK=true
        
        # Warn if 8 workers selected but only 8GB RAM
        if [ "$WORKER_VERSION" = "8" ] && [ "$ram_gb" -lt 16 ]; then
            print_warning "RAM: ${ram_gb}GB detected. 16GB recommended for 8 workers."
            print_warning "You may experience slowdowns with 8 workers on this system."
            if ! confirm "Continue anyway?"; then
                print_info "Consider using 4 workers version for this system"
                return 1
            fi
        fi
        return 0
    else
        print_warning "RAM: ${ram_gb}GB (8GB recommended)"
        RAM_OK=false
        return 1
    fi
}

run_preflight_checks() {
    print_header "Running Pre-Flight Checks"
    
    check_macos_version
    check_python
    check_chrome
    check_disk_space
    check_memory
    
    echo ""
    
    if ! $PYTHON_OK || ! $CHROME_OK || ! $DISK_OK; then
        print_error "Some requirements not met. Cannot continue."
        echo ""
        
        if ! $PYTHON_OK; then
            print_info "Python 3.8+ required. Install from: https://www.python.org/downloads/"
        fi
        
        if ! $CHROME_OK; then
            print_info "Google Chrome required. Install from: https://www.google.com/chrome/"
        fi
        
        if ! $DISK_OK; then
            print_info "Free up at least 2GB of disk space."
        fi
        
        exit 1
    fi
    
    print_step "All pre-flight checks passed!"
}

###############################################################################
# VERSION SELECTION
###############################################################################

select_worker_version() {
    print_header "Select Worker Version"
    
    total_ram=$(sysctl -n hw.memsize)
    ram_gb=$((total_ram / 1024 / 1024 / 1024))
    
    echo "Choose the number of parallel workers:"
    echo ""
    echo "  1) 4 Workers (Standard)"
    echo "     • Best for: Searches with <50 villages"
    echo "     • RAM required: 8 GB minimum"
    echo "     • Speed: Baseline (1x)"
    echo "     • File: bhoomi_web_app_v2.py"
    if [ "$ram_gb" -lt 16 ]; then
        echo -e "     ${GREEN}• RECOMMENDED for your system (${ram_gb}GB RAM)${NC}"
    fi
    echo ""
    echo "  2) 8 Workers (HIGH-SPEED)"
    echo "     • Best for: Searches with 50+ villages"
    echo "     • RAM required: 16 GB minimum"
    echo "     • Speed: 2x faster than 4 workers"
    echo "     • File: bhoomi_web_app_v2_8workers.py"
    if [ "$ram_gb" -ge 16 ]; then
        echo -e "     ${GREEN}• RECOMMENDED for your system (${ram_gb}GB RAM)${NC}"
    fi
    echo ""
    
    # Auto-recommend based on RAM
    if [ "$ram_gb" -ge 16 ]; then
        default_choice=2
    else
        default_choice=1
    fi
    
    read -p "Enter choice [$default_choice]: " choice
    choice=${choice:-$default_choice}
    
    case $choice in
        1)
            WORKER_VERSION="4"
            APP_FILE="bhoomi_web_app_v2.py"
            print_step "4 Workers version selected"
            ;;
        2)
            WORKER_VERSION="8"
            APP_FILE="bhoomi_web_app_v2_8workers.py"
            print_step "8 Workers (HIGH-SPEED) version selected"
            
            # Extra RAM check for 8 workers
            if [ "$ram_gb" -lt 16 ]; then
                print_warning "Your system has ${ram_gb}GB RAM. 16GB recommended for 8 workers."
                if ! confirm "Continue anyway?"; then
                    print_info "Please select 4 workers version instead"
                    select_worker_version  # Recursive call
                    return
                fi
            fi
            ;;
        *)
            print_error "Invalid choice"
            select_worker_version  # Try again
            ;;
    esac
}

###############################################################################
# INSTALLATION TYPE SELECTION
###############################################################################

select_install_type() {
    print_header "Installation Type"
    
    echo "Choose installation type:"
    echo ""
    echo "  1) Per-User Installation (Recommended)"
    echo "     Location: ~/Applications/POWER-BHOOMI"
    echo "     Data: ~/Documents/POWER-BHOOMI"
    echo "     No admin password required"
    echo ""
    echo "  2) System-Wide Installation (All Users)"
    echo "     Location: /Applications/POWER-BHOOMI"
    echo "     Data: /var/lib/power-bhoomi"
    echo "     Requires admin password"
    echo ""
    
    read -p "Enter choice [1]: " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            INSTALL_TYPE="user"
            INSTALL_DIR="$HOME/Applications/POWER-BHOOMI"
            DATA_DIR="$HOME/Documents/POWER-BHOOMI"
            LOG_DIR="$HOME/Library/Logs/POWER-BHOOMI"
            CONFIG_DIR="$HOME/.config/power-bhoomi"
            print_step "Per-User installation selected"
            ;;
        2)
            INSTALL_TYPE="system"
            INSTALL_DIR="/Applications/POWER-BHOOMI"
            DATA_DIR="/var/lib/power-bhoomi"
            LOG_DIR="/var/log/power-bhoomi"
            CONFIG_DIR="/etc/power-bhoomi"
            
            # Check for admin rights
            if ! sudo -v; then
                print_error "Admin rights required for system-wide installation"
                exit 1
            fi
            
            print_step "System-wide installation selected"
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

###############################################################################
# INSTALLATION
###############################################################################

create_directories() {
    print_header "Creating Directories"
    
    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo mkdir -p "$INSTALL_DIR"/{app,bin,data,logs,config,docs}
        sudo mkdir -p "$DATA_DIR"
        sudo mkdir -p "$LOG_DIR"
        sudo mkdir -p "$CONFIG_DIR"
    else
        mkdir -p "$INSTALL_DIR"/{app,bin,data,logs,config,docs}
        mkdir -p "$DATA_DIR"
        mkdir -p "$LOG_DIR"
        mkdir -p "$CONFIG_DIR"
    fi
    
    print_step "Directory structure created"
}

copy_application_files() {
    print_header "Installing Application Files"
    
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # List of files to copy (BOTH versions included!)
    files=(
        "$APP_FILE"                    # Selected version
        "config.yaml"
        "config_loader.py"
        "enterprise_utils.py"
        "requirements.txt"
    )
    
    # Also copy the other version (for switching later)
    if [ "$WORKER_VERSION" = "4" ]; then
        other_file="bhoomi_web_app_v2_8workers.py"
    else
        other_file="bhoomi_web_app_v2.py"
    fi
    
    for file in "${files[@]}"; do
        if [ -f "$script_dir/$file" ]; then
            if [ "$INSTALL_TYPE" = "system" ]; then
                sudo cp "$script_dir/$file" "$INSTALL_DIR/app/"
            else
                cp "$script_dir/$file" "$INSTALL_DIR/app/"
            fi
            print_step "Copied $file"
        else
            print_warning "$file not found, skipping"
        fi
    done
    
    # Copy the other version too (optional)
    if [ -f "$script_dir/$other_file" ]; then
        if [ "$INSTALL_TYPE" = "system" ]; then
            sudo cp "$script_dir/$other_file" "$INSTALL_DIR/app/"
        else
            cp "$script_dir/$other_file" "$INSTALL_DIR/app/"
        fi
        print_info "Also installed $other_file (for version switching)"
    fi
}

create_virtual_environment() {
    print_header "Creating Python Virtual Environment"
    
    cd "$INSTALL_DIR/app"
    
    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo python3 -m venv venv
        print_step "Virtual environment created"
    else
        python3 -m venv venv
        print_step "Virtual environment created"
    fi
}

install_python_dependencies() {
    print_header "Installing Python Dependencies"
    
    cd "$INSTALL_DIR/app"
    
    print_info "This may take a few minutes..."
    
    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo ./venv/bin/pip install --upgrade pip > /dev/null 2>&1
        sudo ./venv/bin/pip install -r requirements.txt
    else
        ./venv/bin/pip install --upgrade pip > /dev/null 2>&1
        ./venv/bin/pip install -r requirements.txt
    fi
    
    print_step "Python dependencies installed"
}

create_launcher_script() {
    print_header "Creating Launcher Scripts"
    
    launcher_path="$INSTALL_DIR/bin/power-bhoomi"
    launcher_8w_path="$INSTALL_DIR/bin/power-bhoomi-8w"
    
    # Main launcher (selected version)
    cat > /tmp/power-bhoomi-launcher << EOLAUNCHER
#!/bin/bash
# POWER-BHOOMI Launcher ($WORKER_VERSION Workers)

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="\$(dirname "\$SCRIPT_DIR")/app"

cd "\$APP_DIR"
source venv/bin/activate
python3 $APP_FILE "\$@"
EOLAUNCHER

    # Alternative launcher (4 workers)
    cat > /tmp/power-bhoomi-4w << 'EOLAUNCHER4'
#!/bin/bash
# POWER-BHOOMI Launcher (4 Workers)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")/app"

cd "$APP_DIR"
source venv/bin/activate
python3 bhoomi_web_app_v2.py "$@"
EOLAUNCHER4

    # Alternative launcher (8 workers)
    cat > /tmp/power-bhoomi-8w << 'EOLAUNCHER8'
#!/bin/bash
# POWER-BHOOMI Launcher (8 Workers HIGH-SPEED)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")/app"

cd "$APP_DIR"
source venv/bin/activate
python3 bhoomi_web_app_v2_8workers.py "$@"
EOLAUNCHER8

    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo mv /tmp/power-bhoomi-launcher "$launcher_path"
        sudo mv /tmp/power-bhoomi-4w "$INSTALL_DIR/bin/power-bhoomi-4w"
        sudo mv /tmp/power-bhoomi-8w "$INSTALL_DIR/bin/power-bhoomi-8w"
        sudo chmod +x "$launcher_path"
        sudo chmod +x "$INSTALL_DIR/bin/power-bhoomi-4w"
        sudo chmod +x "$INSTALL_DIR/bin/power-bhoomi-8w"
    else
        mv /tmp/power-bhoomi-launcher "$launcher_path"
        mv /tmp/power-bhoomi-4w "$INSTALL_DIR/bin/power-bhoomi-4w"
        mv /tmp/power-bhoomi-8w "$INSTALL_DIR/bin/power-bhoomi-8w"
        chmod +x "$launcher_path"
        chmod +x "$INSTALL_DIR/bin/power-bhoomi-4w"
        chmod +x "$INSTALL_DIR/bin/power-bhoomi-8w"
    fi
    
    print_step "Launcher scripts created:"
    print_info "  - power-bhoomi     (default: $WORKER_VERSION workers)"
    print_info "  - power-bhoomi-4w  (force 4 workers)"
    print_info "  - power-bhoomi-8w  (force 8 workers)"
}

create_admin_tool() {
    print_header "Creating Admin Tool"
    
    admin_path="$INSTALL_DIR/bin/power-bhoomi-admin"
    
    cat > /tmp/power-bhoomi-admin << EOADMIN
#!/bin/bash
# POWER-BHOOMI Admin Tool

INSTALL_DIR="${INSTALL_DIR}"
LOG_DIR="${LOG_DIR}"

case "\$1" in
    start)
        echo "Starting POWER-BHOOMI ($WORKER_VERSION workers)..."
        \$INSTALL_DIR/bin/power-bhoomi &
        echo "Started! Open http://localhost:5001"
        ;;
    start-4w)
        echo "Starting POWER-BHOOMI (4 workers)..."
        \$INSTALL_DIR/bin/power-bhoomi-4w &
        echo "Started! Open http://localhost:5001"
        ;;
    start-8w)
        echo "Starting POWER-BHOOMI (8 workers HIGH-SPEED)..."
        \$INSTALL_DIR/bin/power-bhoomi-8w &
        echo "Started! Open http://localhost:5001"
        ;;
    stop)
        echo "Stopping POWER-BHOOMI..."
        pkill -f "bhoomi_web_app_v2"
        ;;
    restart)
        echo "Restarting POWER-BHOOMI..."
        \$0 stop
        sleep 2
        \$0 start
        ;;
    status)
        if pgrep -f "bhoomi_web_app_v2" > /dev/null; then
            echo "POWER-BHOOMI is running"
            pgrep -fl "bhoomi_web_app_v2"
        else
            echo "POWER-BHOOMI is stopped"
        fi
        ;;
    logs)
        tail -f "\$LOG_DIR/application.log"
        ;;
    version)
        if pgrep -f "bhoomi_web_app_v2_8workers" > /dev/null; then
            echo "Currently running: 8 Workers (HIGH-SPEED)"
        elif pgrep -f "bhoomi_web_app_v2.py" > /dev/null; then
            echo "Currently running: 4 Workers (Standard)"
        else
            echo "Not running"
        fi
        ;;
    *)
        echo "POWER-BHOOMI Admin Tool"
        echo ""
        echo "Usage: power-bhoomi-admin {COMMAND}"
        echo ""
        echo "Commands:"
        echo "  start       Start POWER-BHOOMI (default: $WORKER_VERSION workers)"
        echo "  start-4w    Start with 4 workers (standard)"
        echo "  start-8w    Start with 8 workers (HIGH-SPEED)"
        echo "  stop        Stop POWER-BHOOMI"
        echo "  restart     Restart POWER-BHOOMI"
        echo "  status      Check if running"
        echo "  logs        View logs (tail -f)"
        echo "  version     Show which version is running"
        echo ""
        exit 1
        ;;
esac
EOADMIN

    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo mv /tmp/power-bhoomi-admin "$admin_path"
        sudo chmod +x "$admin_path"
    else
        mv /tmp/power-bhoomi-admin "$admin_path"
        chmod +x "$admin_path"
    fi
    
    print_step "Admin tool created"
}

setup_path() {
    print_header "Setting up PATH"
    
    if [ "$INSTALL_TYPE" = "user" ]; then
        # Add to user's PATH
        shell_rc="$HOME/.zshrc"
        if [ ! -f "$shell_rc" ]; then
            shell_rc="$HOME/.bashrc"
        fi
        
        if ! grep -q "POWER-BHOOMI/bin" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# POWER-BHOOMI" >> "$shell_rc"
            echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$shell_rc"
            print_step "Added to PATH in $shell_rc"
        else
            print_info "Already in PATH"
        fi
    fi
}

create_version_info() {
    print_header "Creating Version Info"
    
    version_file="$INSTALL_DIR/VERSION.txt"
    
    cat > /tmp/version.txt << EOVERSION
POWER-BHOOMI v$APP_VERSION
Installed: $(date)
Type: $INSTALL_TYPE
Workers: $WORKER_VERSION ($APP_FILE)
Location: $INSTALL_DIR
Data: $DATA_DIR

Available Commands:
  power-bhoomi       - Start default ($WORKER_VERSION workers)
  power-bhoomi-4w    - Start 4 workers version
  power-bhoomi-8w    - Start 8 workers version
  power-bhoomi-admin - Admin tool

Available Versions:
  • 4 Workers: bhoomi_web_app_v2.py
  • 8 Workers: bhoomi_web_app_v2_8workers.py

To switch versions:
  power-bhoomi-admin start-4w
  power-bhoomi-admin start-8w
EOVERSION

    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo mv /tmp/version.txt "$version_file"
    else
        mv /tmp/version.txt "$version_file"
    fi
    
    print_step "Version info created"
}

create_uninstaller() {
    print_header "Creating Uninstaller"
    
    uninstall_script="$INSTALL_DIR/uninstall.sh"
    
    cat > /tmp/uninstall.sh << EOUNINSTALL
#!/bin/bash
# POWER-BHOOMI Uninstaller

echo "Uninstalling POWER-BHOOMI..."

# Stop application
pkill -f "bhoomi_web_app_v2"

# Remove LaunchAgent if exists
if [ -f ~/Library/LaunchAgents/com.powerbhoomi.app.plist ]; then
    launchctl unload ~/Library/LaunchAgents/com.powerbhoomi.app.plist 2>/dev/null
    rm ~/Library/LaunchAgents/com.powerbhoomi.app.plist
    echo "LaunchAgent removed"
fi

# Remove directories
rm -rf "$INSTALL_DIR"
rm -rf "$LOG_DIR"
rm -rf "$CONFIG_DIR"

echo "Application uninstalled"

# Optionally remove data (ask user)
read -p "Remove data directory ($DATA_DIR)? [y/N]: " remove_data
if [[ \$remove_data =~ ^[Yy]\$ ]]; then
    rm -rf "$DATA_DIR"
    echo "Data directory removed"
else
    echo "Data directory preserved at: $DATA_DIR"
fi

# Remove from PATH
if [ -f ~/.zshrc ]; then
    sed -i.bak '/POWER-BHOOMI/d' ~/.zshrc
fi
if [ -f ~/.bashrc ]; then
    sed -i.bak '/POWER-BHOOMI/d' ~/.bashrc
fi

echo ""
echo "POWER-BHOOMI uninstalled successfully"
echo "Restart your terminal for PATH changes to take effect"
EOUNINSTALL

    if [ "$INSTALL_TYPE" = "system" ]; then
        sudo mv /tmp/uninstall.sh "$uninstall_script"
        sudo chmod +x "$uninstall_script"
    else
        mv /tmp/uninstall.sh "$uninstall_script"
        chmod +x "$uninstall_script"
    fi
    
    print_step "Uninstaller created"
}

###############################################################################
# POST-INSTALLATION
###############################################################################

show_completion_message() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}${BOLD}✓ POWER-BHOOMI v$APP_VERSION installed successfully!${NC}"
    echo ""
    echo "Installation Details:"
    echo "  • Version: $WORKER_VERSION Workers ($APP_FILE)"
    echo "  • Location: $INSTALL_DIR"
    echo "  • Data: $DATA_DIR"
    echo "  • Logs: $LOG_DIR"
    echo "  • Config: $CONFIG_DIR"
    echo ""
    echo "Quick Start:"
    echo "  1. Open a NEW terminal window (to load PATH)"
    echo "  2. Run: ${BOLD}power-bhoomi${NC}"
    echo "  3. Open browser: ${BOLD}http://localhost:5001${NC}"
    echo ""
    echo "Admin Commands:"
    echo "  • power-bhoomi-admin start       - Start ($WORKER_VERSION workers)"
    echo "  • power-bhoomi-admin start-4w    - Start 4 workers"
    echo "  • power-bhoomi-admin start-8w    - Start 8 workers"
    echo "  • power-bhoomi-admin stop        - Stop service"
    echo "  • power-bhoomi-admin status      - Check status"
    echo "  • power-bhoomi-admin logs        - View logs"
    echo "  • power-bhoomi-admin version     - Show running version"
    echo ""
    echo "Version Info:"
    echo "  • Both versions installed!"
    echo "  • Switch anytime with: power-bhoomi-4w or power-bhoomi-8w"
    echo "  • Default: $WORKER_VERSION workers"
    echo ""
    echo "To uninstall:"
    echo "  $INSTALL_DIR/uninstall.sh"
    echo ""
    
    if confirm "Start POWER-BHOOMI now ($WORKER_VERSION workers)?"; then
        echo ""
        print_info "Starting POWER-BHOOMI..."
        "$INSTALL_DIR/bin/power-bhoomi" &
        sleep 3
        open "http://localhost:5001"
        print_step "Application started and browser opened"
        echo ""
        print_info "Close this terminal to keep it running in background"
        print_info "Or press Ctrl+C to stop it"
    fi
}

###############################################################################
# MAIN
###############################################################################

main() {
    clear
    
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██████╗  ██████╗ ██╗    ██╗███████╗██████╗                     ║
║   ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗                    ║
║   ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝                    ║
║   ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗                    ║
║   ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║                    ║
║   ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝                    ║
║                                                                   ║
║   ██████╗ ██╗  ██╗ ██████╗  ██████╗ ███╗   ███╗██╗               ║
║   ██╔══██╗██║  ██║██╔═══██╗██╔═══██╗████╗ ████║██║               ║
║   ██████╔╝███████║██║   ██║██║   ██║██╔████╔██║██║               ║
║   ██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╔╝██║██║               ║
║   ██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██║               ║
║   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝               ║
║                                                                   ║
║              Enterprise Installer v3.0 (Enhanced)                ║
║          Karnataka Land Records Search Tool                      ║
║          Supports 4 Workers AND 8 Workers Versions               ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF

    echo ""
    print_info "This script will install POWER-BHOOMI on your Mac"
    print_info "You can choose between 4 or 8 worker versions"
    echo ""
    
    if ! confirm "Continue with installation?"; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    # Run installation steps
    select_worker_version      # NEW: Choose 4 or 8 workers
    run_preflight_checks
    select_install_type
    create_directories
    copy_application_files
    create_virtual_environment
    install_python_dependencies
    create_launcher_script
    create_admin_tool
    setup_path
    create_version_info         # NEW: Version info file
    create_uninstaller
    show_completion_message
    
    echo ""
    print_step "Thank you for installing POWER-BHOOMI!"
}

# Run main function
main "$@"

