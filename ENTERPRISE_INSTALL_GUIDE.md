# POWER-BHOOMI Enterprise Installation Guide

## 📦 Installation Options

POWER-BHOOMI offers three enterprise installation methods:

### 1. **PKG Installer** (Recommended for Enterprise)
Professional macOS installer package for mass deployment

### 2. **Shell Script Installer** (Quick Setup)
Interactive command-line installer for individual machines

### 3. **Manual Installation** (Advanced Users)
Step-by-step manual setup with full control

---

## 🚀 Method 1: PKG Installer (Enterprise Deployment)

### Building the PKG Installer

```bash
cd /Users/sks/Desktop/POWER-BHOOMI
./build-pkg.sh
```

This creates: `dist/POWER-BHOOMI-v3.0-Installer.pkg`

### Distributing the PKG

#### Option A: Direct Installation
```bash
# Double-click the .pkg file
# Or run from terminal:
sudo installer -pkg POWER-BHOOMI-v3.0-Installer.pkg -target /
```

#### Option B: MDM Distribution (Jamf, Intune, etc.)
1. Upload PKG to your MDM system
2. Create deployment policy
3. Push to target MacBook Pros
4. Monitor installation status

#### Option C: Self-Service Portal
1. Host PKG on internal web server
2. Users download and install
3. Track downloads via web logs

### Post-PKG Installation

The installer automatically:
- ✅ Installs to `/Applications/POWER-BHOOMI`
- ✅ Creates user data directories
- ✅ Sets up Python virtual environment
- ✅ Installs all dependencies
- ✅ Adds commands to PATH
- ✅ Creates launcher scripts

**First Launch:**
```bash
# Open new terminal
power-bhoomi

# Or use admin tool
power-bhoomi-admin start
```

---

## 🛠️ Method 2: Shell Script Installer (Quick Setup)

### Prerequisites
- macOS 10.14 or later
- Admin access (for system-wide installation)
- Internet connection (for dependencies)

### Installation Steps

1. **Download the installer:**
   ```bash
   cd /Users/sks/Desktop/POWER-BHOOMI
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

3. **Follow the prompts:**
   - Choose installation type (per-user or system-wide)
   - Wait for dependency installation
   - Confirm completion

4. **Launch the application:**
   ```bash
   # Open new terminal window
   power-bhoomi
   ```

### Installation Types

#### Per-User Installation
- **No admin password required**
- Location: `~/Applications/POWER-BHOOMI`
- Data: `~/Documents/POWER-BHOOMI`
- Best for: Individual users, personal laptops

#### System-Wide Installation
- **Requires admin password**
- Location: `/Applications/POWER-BHOOMI`
- Data: `/var/lib/power-bhoomi`
- Best for: Shared machines, enterprise deployment

---

## 📖 Method 3: Manual Installation (Advanced)

### Step 1: Prepare Environment

```bash
# Create installation directory
mkdir -p ~/Applications/POWER-BHOOMI/{app,bin,data,logs,config,docs}

# Create data directories
mkdir -p ~/Documents/POWER-BHOOMI
mkdir -p ~/Library/Logs/POWER-BHOOMI
mkdir -p ~/.config/power-bhoomi
```

### Step 2: Copy Application Files

```bash
cd /Users/sks/Desktop/POWER-BHOOMI

# Copy main application files
cp bhoomi_web_app_v2.py ~/Applications/POWER-BHOOMI/app/
cp config.yaml ~/Applications/POWER-BHOOMI/app/
cp config_loader.py ~/Applications/POWER-BHOOMI/app/
cp enterprise_utils.py ~/Applications/POWER-BHOOMI/app/
cp requirements.txt ~/Applications/POWER-BHOOMI/app/

# Copy configuration
cp config.yaml ~/.config/power-bhoomi/
```

### Step 3: Create Virtual Environment

```bash
cd ~/Applications/POWER-BHOOMI/app

# Create venv
python3 -m venv venv

# Activate
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Create Launcher Script

```bash
cat > ~/Applications/POWER-BHOOMI/bin/power-bhoomi << 'EOF'
#!/bin/bash
cd ~/Applications/POWER-BHOOMI/app
source venv/bin/activate
python3 bhoomi_web_app_v2.py "$@"
EOF

chmod +x ~/Applications/POWER-BHOOMI/bin/power-bhoomi
```

### Step 5: Add to PATH

```bash
echo 'export PATH="$HOME/Applications/POWER-BHOOMI/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Step 6: Test Installation

```bash
power-bhoomi
```

---

## 🔧 Post-Installation Configuration

### Setting Up Auto-Start

```bash
cd /Users/sks/Desktop/POWER-BHOOMI
./setup-launchagent.sh
```

This configures POWER-BHOOMI to start automatically on login.

### Configuring Application Settings

Edit the configuration file:
```bash
nano ~/.config/power-bhoomi/config.yaml
```

Key settings to customize:
```yaml
app:
  port: 5001  # Change if port conflict
  debug: false  # Set to true for troubleshooting

workers:
  max_workers: 4  # 4 or 8 depending on system

database:
  path: "${DATA_DIR}/bhoomi_data.db"
  backup_enabled: true

logging:
  level: "INFO"  # DEBUG for troubleshooting
```

---

## ✅ Verifying Installation

### Check Installation Status

```bash
# Check if files are in place
ls -la ~/Applications/POWER-BHOOMI

# Check if commands are available
which power-bhoomi
which power-bhoomi-admin

# Check Python dependencies
~/Applications/POWER-BHOOMI/app/venv/bin/pip list
```

### Test Application Launch

```bash
# Start application
power-bhoomi

# Check if running
curl http://localhost:5001/health

# View logs
tail -f ~/Library/Logs/POWER-BHOOMI/application.log
```

### Expected Output

```json
{
  "status": "healthy",
  "version": "3.0.0",
  "uptime_seconds": 10.5,
  "memory": { "rss_mb": 250.5 },
  "database": { "status": "healthy" }
}
```

---

## 🔍 Troubleshooting Installation

### Issue: Python 3 not found

**Solution:**
```bash
# Install Python 3 via Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install python@3.12
```

### Issue: Chrome not found

**Solution:**
Download and install Google Chrome:
https://www.google.com/chrome/

### Issue: Permission denied

**Solution:**
```bash
# Fix permissions
chmod +x ~/Applications/POWER-BHOOMI/bin/*
chmod +x ~/Applications/POWER-BHOOMI/install.sh
```

### Issue: Port 5001 already in use

**Solution 1: Change port in config**
```bash
nano ~/.config/power-bhoomi/config.yaml
# Change port: 5001 to port: 5002
```

**Solution 2: Stop conflicting service**
```bash
lsof -i :5001
kill <PID>
```

### Issue: Dependencies fail to install

**Solution:**
```bash
# Update pip and try again
~/Applications/POWER-BHOOMI/app/venv/bin/pip install --upgrade pip
~/Applications/POWER-BHOOMI/app/venv/bin/pip install -r requirements.txt --verbose
```

### Issue: Chrome driver fails

**Solution:**
The application auto-downloads ChromeDriver. If it fails:
```bash
# Manual download
~/Applications/POWER-BHOOMI/app/venv/bin/python3 -c "from webdriver_manager.chrome import ChromeDriverManager; ChromeDriverManager().install()"
```

---

## 🗑️ Uninstallation

### Quick Uninstall

```bash
~/Applications/POWER-BHOOMI/uninstall.sh
```

### Manual Uninstall

```bash
# Stop service
power-bhoomi-admin stop

# Remove LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.powerbhoomi.app.plist
rm ~/Library/LaunchAgents/com.powerbhoomi.app.plist

# Remove application
rm -rf ~/Applications/POWER-BHOOMI

# Remove logs
rm -rf ~/Library/Logs/POWER-BHOOMI

# Remove config
rm -rf ~/.config/power-bhoomi

# Optional: Remove data
rm -rf ~/Documents/POWER-BHOOMI

# Remove from PATH
sed -i.bak '/POWER-BHOOMI/d' ~/.zshrc
```

---

## 📊 Enterprise Deployment Best Practices

### Pre-Deployment

1. **Test on Representative Machines**
   - Different macOS versions
   - Various hardware configurations
   - Different user permission levels

2. **Prepare Documentation**
   - Internal wiki page
   - Quick start guide
   - IT support contacts

3. **Set Up Support Channels**
   - Help desk tickets
   - Slack/Teams channel
   - Email support

### Deployment Phase

1. **Pilot Group** (Week 1)
   - Deploy to 10-20 users
   - Gather feedback
   - Fix issues

2. **Phased Rollout** (Weeks 2-4)
   - Deploy to departments
   - 25% → 50% → 75% → 100%
   - Monitor support tickets

3. **Communication**
   - Announce before deployment
   - Provide training materials
   - Schedule training sessions

### Post-Deployment

1. **Monitor Usage**
   - Check application logs
   - Track error reports
   - Survey user satisfaction

2. **Provide Support**
   - Dedicated IT support
   - User training
   - Troubleshooting guide

3. **Regular Updates**
   - Monthly maintenance
   - Security patches
   - Feature updates

---

## 🔐 Security Considerations

### Network Security

- Application runs on `localhost:5001` by default
- No external network access required (except portal access)
- Data stored locally, not transmitted

### Data Security

- Database encrypted at rest (macOS FileVault)
- No passwords stored in application
- User data in user-controlled directories

### Access Control

- Per-user installation: User-level access
- System-wide installation: All-users access
- No elevated privileges required at runtime

---

## 📱 Integration with Enterprise Tools

### Jamf Pro

```xml
<!-- Jamf policy for POWER-BHOOMI -->
<policy>
  <package>POWER-BHOOMI-v3.0-Installer.pkg</package>
  <scope>
    <target>Marketing Department</target>
  </scope>
  <self_service>true</self_service>
</policy>
```

### Microsoft Intune

1. Upload PKG to Intune
2. Create macOS LOB app
3. Assign to device groups
4. Monitor deployment status

### Munki

```python
# pkginfo for Munki
{
    "name": "POWER-BHOOMI",
    "version": "3.0.0",
    "installer_item_location": "apps/POWER-BHOOMI-v3.0-Installer.pkg",
    "uninstall_method": "uninstall_script",
    "uninstall_script": "rm -rf /Applications/POWER-BHOOMI"
}
```

---

## 📞 Support & Maintenance

### Getting Help

- **Documentation:** See `docs/` folder in installation
- **Logs:** `~/Library/Logs/POWER-BHOOMI/`
- **Config:** `~/.config/power-bhoomi/config.yaml`
- **Database:** `~/Documents/POWER-BHOOMI/bhoomi_data.db`

### Maintenance Tasks

**Weekly:**
- Review error logs
- Check disk space
- Verify backups

**Monthly:**
- Update application
- Clean old logs
- Optimize database

**Quarterly:**
- Security audit
- Performance review
- User training refresh

---

## 🎯 Quick Reference

### Installation Commands

```bash
# PKG Installer (build)
./build-pkg.sh

# Shell Script Installer
./install.sh

# Setup auto-start
./setup-launchagent.sh
```

### Admin Commands

```bash
power-bhoomi-admin start     # Start service
power-bhoomi-admin stop      # Stop service
power-bhoomi-admin restart   # Restart service
power-bhoomi-admin status    # Check status
power-bhoomi-admin logs      # View logs
```

### Locations

| Item | Location |
|------|----------|
| Application | `~/Applications/POWER-BHOOMI` |
| Data | `~/Documents/POWER-BHOOMI` |
| Logs | `~/Library/Logs/POWER-BHOOMI` |
| Config | `~/.config/power-bhoomi` |
| LaunchAgent | `~/Library/LaunchAgents/com.powerbhoomi.app.plist` |

---

**Installation Guide Version:** 3.0.0  
**Last Updated:** December 17, 2025  
**Status:** ✅ Production Ready

