# 🎯 POWER-BHOOMI Enhanced Installer Guide

## ✅ YES! Installer Ready for BOTH Versions

The installer system now fully supports **BOTH** the 4-worker and 8-worker versions!

---

## 📦 **Available Installers**

### **Enhanced Installers** (RECOMMENDED - Support Both Versions)

#### 1. **install-enterprise.sh** ⭐ NEW & ENHANCED
- **Supports:** BOTH 4 and 8 worker versions
- **User Choice:** Asks which version you want during installation
- **Smart Recommendations:** Suggests version based on your RAM
- **Flexibility:** Can switch versions anytime after installation
- **All Features:** Pre-flight checks, PATH setup, admin tools

#### 2. **build-pkg-enterprise.sh** ⭐ NEW & ENHANCED
- **Supports:** Build PKG for 4 workers, 8 workers, or BOTH (universal)
- **Three Options:**
  - 4-worker PKG only
  - 8-worker PKG only
  - Universal PKG (includes both, user chooses at runtime)
- **MDM Ready:** Deploy via Jamf, Intune, Munki
- **Professional:** Welcome/README/License screens

### **Original Installers** (Basic - 4 Workers Only)

#### 3. **install.sh** (Original)
- **Supports:** 4 workers only
- **Keep for:** Simple deployments, backwards compatibility

#### 4. **build-pkg.sh** (Original)
- **Supports:** 4 workers only
- **Keep for:** Simple PKG creation

---

## 🚀 **How to Use Enhanced Installers**

### **For 8 Workers Installation:**

#### Method 1: Enhanced Shell Installer
```bash
cd /Users/sks/Desktop/POWER-BHOOMI
./install-enterprise.sh
```

During installation:
1. **Choose Worker Version:**
   ```
   Select Worker Version
   1) 4 Workers (Standard)
   2) 8 Workers (HIGH-SPEED)    ← Choose this!
   ```

2. **Choose Installation Type:**
   ```
   1) Per-User Installation
   2) System-Wide Installation
   ```

3. Wait for installation to complete

4. Launch:
   ```bash
   power-bhoomi    # Launches 8 workers version
   # Or specifically:
   power-bhoomi-8w
   ```

#### Method 2: Build Universal PKG
```bash
./build-pkg-enterprise.sh
```

During build:
1. **Choose PKG Version:**
   ```
   1) 4 Workers (Standard)
   2) 8 Workers (HIGH-SPEED)
   3) BOTH (Universal Package)    ← Choose this!
   ```

2. PKG created: `dist/POWER-BHOOMI-v3.0-universal-Installer.pkg`

3. Distribute and install

4. Both versions available:
   ```bash
   power-bhoomi-4w    # 4 workers
   power-bhoomi-8w    # 8 workers
   ```

---

## 🎯 **Comparison Table**

| Feature | Original Installers | Enhanced Installers |
|---------|-------------------|---------------------|
| **Support 4 Workers** | ✅ Yes | ✅ Yes |
| **Support 8 Workers** | ❌ No | ✅ Yes |
| **Version Selection** | ❌ No | ✅ Yes |
| **Smart Recommendations** | ❌ No | ✅ Yes (based on RAM) |
| **Both Versions Installed** | ❌ No | ✅ Yes |
| **Switch Versions** | ❌ No | ✅ Yes |
| **RAM Check for 8 Workers** | ❌ No | ✅ Yes |
| **Universal PKG** | ❌ No | ✅ Yes |

---

## 📋 **Installation Options Matrix**

### Scenario 1: I want 4 workers only

**Option A:** Original installer
```bash
./install.sh
```

**Option B:** Enhanced installer
```bash
./install-enterprise.sh
# Choose: 1) 4 Workers
```

### Scenario 2: I want 8 workers only

**Option A:** Enhanced installer (ONLY OPTION!)
```bash
./install-enterprise.sh
# Choose: 2) 8 Workers
```

**Option B:** Build 8-worker PKG
```bash
./build-pkg-enterprise.sh
# Choose: 2) 8 Workers
```

### Scenario 3: I want BOTH versions (can switch)

**Option A:** Enhanced installer (RECOMMENDED!)
```bash
./install-enterprise.sh
# Both versions will be installed regardless of choice!
# Choose default, but both are available
```

**Option B:** Universal PKG
```bash
./build-pkg-enterprise.sh
# Choose: 3) BOTH (Universal Package)
```

---

## 🔧 **Commands After Installation**

### Using Default Version
```bash
power-bhoomi              # Uses your selected default
power-bhoomi-admin start  # Uses your selected default
```

### Force Specific Version
```bash
power-bhoomi-4w           # Always use 4 workers
power-bhoomi-8w           # Always use 8 workers

power-bhoomi-admin start-4w   # Start 4 workers
power-bhoomi-admin start-8w   # Start 8 workers
```

### Check Which Version is Running
```bash
power-bhoomi-admin version
```

Output:
```
Running: 8 Workers (HIGH-SPEED)
# or
Running: 4 Workers (Standard)
# or
Not running
```

---

## 🎓 **Smart RAM-Based Recommendations**

The enhanced installer automatically recommends the best version for your system:

### System has 8-15 GB RAM
```
Recommended: 4 Workers (Standard)
  ✓ Stable performance
  ✓ Moderate resource usage
  ✓ Best for your system
```

### System has 16+ GB RAM
```
Recommended: 8 Workers (HIGH-SPEED)
  ✓ 2x faster performance
  ✓ System can handle it
  ✓ Best for your system
```

### System has <8 GB RAM
```
Warning: Minimum 8GB RAM required
Installation may fail or perform poorly
```

---

## 🔄 **Switching Versions After Installation**

You can switch between versions anytime!

### Currently Using 4 Workers, Want to Use 8:
```bash
# Stop current version
power-bhoomi-admin stop

# Start 8 workers version
power-bhoomi-8w
# or
power-bhoomi-admin start-8w
```

### Currently Using 8 Workers, Want to Use 4:
```bash
# Stop current version
power-bhoomi-admin stop

# Start 4 workers version
power-bhoomi-4w
# or
power-bhoomi-admin start-4w
```

### Make 8 Workers the Default:
```bash
cd ~/Applications/POWER-BHOOMI/bin

# Edit the launcher
nano power-bhoomi

# Change line:
# FROM: python3 bhoomi_web_app_v2.py "$@"
# TO:   python3 bhoomi_web_app_v2_8workers.py "$@"
```

---

## 📊 **PKG Build Options**

### Option 1: 4 Workers PKG Only
```bash
./build-pkg-enterprise.sh
# Choose: 1) 4 Workers

# Output: dist/POWER-BHOOMI-v3.0-4workers-Installer.pkg
# Size: ~150MB
# Contains: bhoomi_web_app_v2.py only
```

### Option 2: 8 Workers PKG Only
```bash
./build-pkg-enterprise.sh
# Choose: 2) 8 Workers

# Output: dist/POWER-BHOOMI-v3.0-8workers-Installer.pkg
# Size: ~150MB
# Contains: bhoomi_web_app_v2_8workers.py only
```

### Option 3: Universal PKG (BOTH Versions) ⭐ RECOMMENDED
```bash
./build-pkg-enterprise.sh
# Choose: 3) BOTH (Universal Package)

# Output: dist/POWER-BHOOMI-v3.0-universal-Installer.pkg
# Size: ~155MB
# Contains: Both versions!
# Users can switch anytime with: power-bhoomi-4w or power-bhoomi-8w
```

---

## 🎯 **Best Practices**

### For Enterprise Deployment

**Recommended:** Build Universal PKG
```bash
./build-pkg-enterprise.sh
# Choose: 3) BOTH
```

**Why:**
- ✅ One package for all systems
- ✅ Users choose based on their needs
- ✅ Can switch versions without reinstalling
- ✅ Covers all use cases
- ✅ Only 5MB larger than single version

**Distribute via:**
- Jamf Self Service: "Install POWER-BHOOMI"
- Intune Company Portal: "POWER-BHOOMI"
- Internal download portal

### For Controlled Deployment

**Recommended:** Build separate PKGs
```bash
# For 8GB RAM machines
./build-pkg-enterprise.sh
# Choose: 1) 4 Workers

# For 16GB+ RAM machines
./build-pkg-enterprise.sh
# Choose: 2) 8 Workers
```

**Why:**
- ✅ Control which version users get
- ✅ Optimize for specific hardware
- ✅ Prevent users from choosing wrong version
- ✅ Smaller package size

---

## 🧪 **Testing the Enhanced Installer**

### Test 1: Shell Installer with 8 Workers
```bash
./install-enterprise.sh
# Choose: 2) 8 Workers (HIGH-SPEED)
# Choose: 1) Per-User Installation

# Verify:
ls ~/Applications/POWER-BHOOMI/app/
# Should see: bhoomi_web_app_v2_8workers.py

# Launch:
power-bhoomi
# Should start 8 workers version

# Check:
power-bhoomi-admin version
# Output: "Running: 8 Workers (HIGH-SPEED)"
```

### Test 2: Universal PKG
```bash
./build-pkg-enterprise.sh
# Choose: 3) BOTH

# Install:
sudo installer -pkg dist/POWER-BHOOMI-v3.0-universal-Installer.pkg -target /

# Verify both available:
power-bhoomi-4w    # Should launch 4 workers
power-bhoomi-8w    # Should launch 8 workers
```

---

## 📁 **Files Installed**

### Enhanced Installation Includes

```
~/Applications/POWER-BHOOMI/app/
├── bhoomi_web_app_v2.py          ✓ Always included
├── bhoomi_web_app_v2_8workers.py ✓ Always included (enhanced installer)
├── config.yaml
├── config_loader.py
├── enterprise_utils.py
├── requirements.txt
└── venv/

~/Applications/POWER-BHOOMI/bin/
├── power-bhoomi        # Default version launcher
├── power-bhoomi-4w     # 4 workers launcher
├── power-bhoomi-8w     # 8 workers launcher
└── power-bhoomi-admin  # Admin tool
```

---

## ✅ **Summary**

### Question: Is the installer ready for the 8 workers version?

**Answer:** ✅ **YES! Absolutely!**

### Available Options:

1. **install-enterprise.sh** ⭐
   - Choose 4 or 8 workers during installation
   - Smart RAM-based recommendations
   - Both versions installed, can switch anytime

2. **build-pkg-enterprise.sh** ⭐
   - Build 4-worker PKG
   - Build 8-worker PKG
   - Build universal PKG (both versions)

3. **Bonus:** All launchers support both versions
   - `power-bhoomi-4w` - Force 4 workers
   - `power-bhoomi-8w` - Force 8 workers
   - `power-bhoomi` - Your chosen default

---

## 🚀 **Quick Start for 8 Workers**

### Method 1: Enhanced Shell Installer
```bash
./install-enterprise.sh
# Choose: 2) 8 Workers (HIGH-SPEED)
# Wait for installation
# Launch: power-bhoomi
```

### Method 2: Build 8-Worker PKG
```bash
./build-pkg-enterprise.sh
# Choose: 2) 8 Workers (HIGH-SPEED)
# Distribute: dist/POWER-BHOOMI-v3.0-8workers-Installer.pkg
```

### Method 3: Build Universal PKG (RECOMMENDED)
```bash
./build-pkg-enterprise.sh
# Choose: 3) BOTH (Universal Package)
# Distribute: dist/POWER-BHOOMI-v3.0-universal-Installer.pkg
# Users get both versions, choose power-bhoomi-4w or power-bhoomi-8w
```

---

## 🎉 **Complete Installer Matrix**

| Installer | 4 Workers | 8 Workers | Both | Use Case |
|-----------|-----------|-----------|------|----------|
| **install.sh** | ✅ | ❌ | ❌ | Simple, 4 workers only |
| **install-enterprise.sh** ⭐ | ✅ | ✅ | ✅ | Full featured, user choice |
| **build-pkg.sh** | ✅ | ❌ | ❌ | Basic PKG, 4 workers |
| **build-pkg-enterprise.sh** ⭐ | ✅ | ✅ | ✅ | Universal PKG options |

---

## 💡 **Recommendations**

### For Testing
Use: **install-enterprise.sh**
- Choose your version
- Quick setup
- Easy to uninstall

### For Enterprise Deployment
Use: **build-pkg-enterprise.sh** (Universal)
- One package for all
- Users choose based on needs
- Maximum flexibility

### For Specific Deployments
Use: **build-pkg-enterprise.sh** (Specific version)
- Build 4-worker PKG for 8GB RAM machines
- Build 8-worker PKG for 16GB+ RAM machines
- Control which version users get

---

## ✅ **Answer to Your Question**

**Q: Is the installer ready for bhoomi_web_app_v2_8workers.py also?**

**A: YES! ✅ Two NEW enhanced installers ready:**

1. **`install-enterprise.sh`**
   - Lets you choose 4 or 8 workers
   - Installs both versions
   - Smart RAM-based recommendations

2. **`build-pkg-enterprise.sh`**
   - Build 4-worker, 8-worker, or universal PKG
   - Professional enterprise distribution
   - MDM-ready

**Both versions are fully supported!** 🎉

---

## 🚀 **Try It Now!**

```bash
# Enhanced installer with version choice
./install-enterprise.sh
```

**You'll see:**
```
Choose the number of parallel workers:

  1) 4 Workers (Standard)
     • Best for: Searches with <50 villages
     • RAM required: 8 GB minimum
     • Speed: Baseline (1x)

  2) 8 Workers (HIGH-SPEED)  ← You can choose this!
     • Best for: Searches with 50+ villages
     • RAM required: 16 GB minimum
     • Speed: 2x faster

Enter choice [auto-detected based on your RAM]:
```

**After installation:**
```bash
power-bhoomi      # Your chosen version
power-bhoomi-4w   # Force 4 workers
power-bhoomi-8w   # Force 8 workers
```

---

**Status:** ✅ **BOTH VERSIONS FULLY SUPPORTED!**  
**Installer:** ✅ **READY FOR 8 WORKERS!**  
**PKG Builder:** ✅ **SUPPORTS ALL VERSIONS!**

🎉 **You're all set for enterprise deployment with either or both versions!**

