# 🚀 Install POWER-BHOOMI on Other MacBook Pros

## Quick Install Guide (5 Minutes)

---

## 📋 **Prerequisites**

On the target MacBook Pro, you need:
- ✅ macOS 10.14 or later
- ✅ Google Chrome installed
- ✅ Internet connection

**That's it!** Python will be installed automatically if needed.

---

## 🎯 **Method 1: Git Clone + Installer (RECOMMENDED)**

### **Step 1: Clone the Repository**

Open Terminal and run:

```bash
cd ~/Desktop
git clone https://github.com/flipsideview/POWER-BHOOMI.git
cd POWER-BHOOMI
```

### **Step 2: Run the Installer**

```bash
./install.sh
```

### **Step 3: Follow the Prompts**

The installer will ask you:

#### **Question 1: Continue with installation?**
```
→ Type: y
```

#### **Question 2: Choose Worker Version**
```
Choose the number of parallel workers:

  1) 4 Workers (Standard)
     • Best for: Searches with <50 villages
     • RAM required: 8 GB minimum
     
  2) 8 Workers (HIGH-SPEED)
     • Best for: Searches with 50+ villages  
     • RAM required: 16 GB minimum

Enter choice [auto-suggested]:
```

**If MacBook Pro has 16GB+ RAM:**
```
→ Type: 2  (for 8 workers - faster!)
```

**If MacBook Pro has 8-15GB RAM:**
```
→ Type: 1  (for 4 workers - stable)
```

#### **Question 3: Installation Type**
```
Choose installation type:

  1) Per-User Installation (Recommended)
     No admin password required
     
  2) System-Wide Installation (All Users)
     Requires admin password

Enter choice [1]:
```

**Recommended:**
```
→ Type: 1  (or just press Enter)
```

#### **Question 4: Start Now?**
```
Start POWER-BHOOMI now? [y/N]:
```

```
→ Type: y
```

### **Step 4: Done!**

✅ Application starts automatically  
✅ Browser opens to http://localhost:5001  
✅ Ready to search!

---

## 🎯 **Method 2: Direct Download + Install (NO GIT)**

If Git is not available:

### **Step 1: Download the Repository**

1. Open browser: https://github.com/flipsideview/POWER-BHOOMI
2. Click: **Code** → **Download ZIP**
3. Extract the ZIP to Desktop
4. Rename folder to: `POWER-BHOOMI`

### **Step 2: Run Installer**

Open Terminal:

```bash
cd ~/Desktop/POWER-BHOOMI
./install.sh
```

Then follow Step 3 from Method 1 above.

---

## 🎯 **Method 3: Direct Run (NO INSTALL)**

For quick testing without installation:

### **Step 1: Clone Repository**

```bash
cd ~/Desktop
git clone https://github.com/flipsideview/POWER-BHOOMI.git
cd POWER-BHOOMI
```

### **Step 2: Create Virtual Environment**

```bash
python3 -m venv venv
source venv/bin/activate
```

### **Step 3: Install Dependencies**

```bash
pip install -r requirements.txt
```

### **Step 4: Run Application**

**For 4 Workers:**
```bash
python3 bhoomi_web_app_v2.py
```

**For 8 Workers (HIGH-SPEED):**
```bash
python3 bhoomi_web_app_v2_8workers.py
```

### **Step 5: Open Browser**

```
http://localhost:5001
```

---

## 📦 **Method 4: Enterprise PKG Deployment**

For IT departments deploying to multiple Macs:

### **Step 1: Build PKG (On Admin Mac)**

```bash
cd ~/Desktop/POWER-BHOOMI
./build-pkg.sh
```

Choose:
- **1)** 4 Workers PKG
- **2)** 8 Workers PKG  
- **3)** Universal PKG (RECOMMENDED - both versions)

### **Step 2: Distribute PKG**

PKG file created at: `dist/POWER-BHOOMI-v3.0-*.pkg`

**Option A: Manual Distribution**
- Copy PKG to USB drive
- Distribute to MacBook Pros
- Double-click to install

**Option B: MDM Distribution (Jamf, Intune, Munki)**
- Upload PKG to MDM system
- Create deployment policy
- Push to target devices

**Option C: Self-Service Portal**
- Host PKG on internal server
- Users download and install

### **Step 3: Users Run**

After PKG installation:

```bash
power-bhoomi
# or
power-bhoomi-admin start
```

---

## 🔧 **Post-Installation Commands**

### **Launch Application**

```bash
# Default version (what you chose during install)
power-bhoomi

# Force 4 workers
power-bhoomi-4w

# Force 8 workers (HIGH-SPEED)
power-bhoomi-8w
```

### **Manage Service**

```bash
power-bhoomi-admin start       # Start service
power-bhoomi-admin start-4w    # Start 4 workers
power-bhoomi-admin start-8w    # Start 8 workers
power-bhoomi-admin stop        # Stop service
power-bhoomi-admin restart     # Restart
power-bhoomi-admin status      # Check if running
power-bhoomi-admin logs        # View logs
power-bhoomi-admin version     # Show which version is running
```

### **Setup Auto-Start (Optional)**

```bash
cd ~/Desktop/POWER-BHOOMI
./setup-launchagent.sh
```

Now POWER-BHOOMI starts automatically on login!

---

## 📍 **Installation Locations**

After installation, files will be at:

```
~/Applications/POWER-BHOOMI/    # Application
~/Documents/POWER-BHOOMI/       # Database & data
~/Library/Logs/POWER-BHOOMI/    # Log files
~/.config/power-bhoomi/         # Configuration
```

---

## 🧪 **Verify Installation**

### **Check Installation**

```bash
# Check if installed
ls ~/Applications/POWER-BHOOMI

# Check if commands available
which power-bhoomi
which power-bhoomi-admin

# Check version
cat ~/Applications/POWER-BHOOMI/VERSION.txt
```

### **Test Application**

```bash
# Start application
power-bhoomi

# Check if running
curl http://localhost:5001/health

# Open in browser
open http://localhost:5001
```

---

## 🔄 **Complete Installation Script (Copy-Paste)**

### **For Quick Installation (All Steps Combined):**

```bash
# Navigate to Desktop
cd ~/Desktop

# Clone repository
git clone https://github.com/flipsideview/POWER-BHOOMI.git

# Enter directory
cd POWER-BHOOMI

# Run installer
./install.sh

# The installer will guide you through the rest!
```

---

## 🎓 **First Time User Guide**

After installation:

### **1. Launch Application**

```bash
power-bhoomi
```

### **2. Open Browser**

Navigate to: **http://localhost:5001**

### **3. Configure Search**

1. **Enter Owner Name** (in Kannada or English)
2. **Select District** from dropdown
3. **Select Taluk** from dropdown
4. **Select Hobli** (or choose "All Hoblis")
5. **Select Village** (or choose "All Villages")
6. **Set Max Survey Number** (default: 200)

### **4. Start Search**

Click: **⚡ Start Parallel Search**

### **5. Monitor Progress**

- Watch worker cards update in real-time
- See records appear in the table
- Check activity log for progress

### **6. Stop Anytime**

Click: **Stop Search** (responds instantly!)

### **7. Download Results**

Click: **📥 Download CSV**

Files also saved to:
- `~/Downloads/bhoomi_all_records_*.csv`
- `~/Downloads/bhoomi_matches_*.csv`

---

## 🆘 **Troubleshooting**

### **Issue: ./install.sh not found**

**Solution:**
```bash
# Make sure you're in the right directory
cd ~/Desktop/POWER-BHOOMI

# List files
ls install.sh

# If not found, you might need to pull latest
git pull
```

### **Issue: Permission denied**

**Solution:**
```bash
# Make executable
chmod +x install.sh

# Run again
./install.sh
```

### **Issue: Python not found**

**Solution:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python
brew install python@3.12
```

### **Issue: Chrome not found**

**Solution:**  
Download and install: https://www.google.com/chrome/

### **Issue: Port 5001 already in use**

**Solution:**
```bash
# Check what's using it
lsof -i :5001

# Kill it
kill <PID>

# Or use different port (edit config.yaml)
```

---

## 📊 **Installation Time Estimates**

| Method | Time | Internet Required | Best For |
|--------|------|-------------------|----------|
| **Git + Installer** | 5-10 min | Yes | Most users |
| **Direct Run** | 10-15 min | Yes | Testing |
| **PKG Install** | 2-3 min | No (if PKG available) | Enterprise |

---

## 🔒 **Security Note**

All data stays on your Mac:
- Database: `~/Documents/POWER-BHOOMI/bhoomi_data.db`
- CSV files: `~/Downloads/`
- No cloud, no external servers (except Karnataka Land Records portal)

---

## 🗑️ **Uninstall (If Needed)**

```bash
~/Applications/POWER-BHOOMI/uninstall.sh
```

This removes:
- Application files
- Configuration
- Logs
- Asks before removing data

---

## 📞 **Getting Help**

### **Documentation**

```bash
# Open documentation folder
open ~/Applications/POWER-BHOOMI/docs/

# Or view online
# https://github.com/flipsideview/POWER-BHOOMI
```

### **Logs Location**

```bash
# Application logs
tail -f ~/Library/Logs/POWER-BHOOMI/application.log

# Error logs
tail -f ~/Library/Logs/POWER-BHOOMI/error.log
```

### **Health Check**

```bash
curl http://localhost:5001/health
```

---

## 🎯 **Quick Reference Card**

### **Installation**
```bash
cd ~/Desktop
git clone https://github.com/flipsideview/POWER-BHOOMI.git
cd POWER-BHOOMI
./install.sh
```

### **Daily Use**
```bash
power-bhoomi                  # Start application
open http://localhost:5001    # Open in browser
power-bhoomi-admin stop       # Stop when done
```

### **Switching Versions**
```bash
power-bhoomi-admin stop       # Stop current
power-bhoomi-4w              # Start 4 workers
# or
power-bhoomi-8w              # Start 8 workers
```

---

## 🌟 **Success!**

After following these steps, you'll have POWER-BHOOMI installed and ready on any MacBook Pro!

**Total time:** 5-10 minutes  
**Difficulty:** Easy (just follow prompts)  
**Result:** Professional land records search tool

---

**Guide Version:** 3.0  
**Last Updated:** December 17, 2025  
**Status:** ✅ Production Ready

**Questions?** Check the documentation in `~/Applications/POWER-BHOOMI/docs/`
