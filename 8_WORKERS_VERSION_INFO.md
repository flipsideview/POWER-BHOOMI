# POWER-BHOOMI: 4 Workers vs 8 Workers Comparison

## 📁 Files Available

### **Version 1: 4 Workers (Original)**
- **File:** `bhoomi_web_app_v2.py`
- **Workers:** 4 parallel browser instances
- **Best For:** Standard searches, balanced system load
- **Startup Delay:** 0.5s between workers
- **Layout:** 2x2 worker grid

### **Version 2: 8 Workers (HIGH-SPEED)**
- **File:** `bhoomi_web_app_v2_8workers.py`
- **Workers:** 8 parallel browser instances
- **Best For:** Large-scale searches, maximum speed
- **Startup Delay:** 0.7s between workers (prevents Chrome conflicts)
- **Layout:** 4x2 worker grid

---

## 🚀 Performance Comparison

| Metric | 4 Workers | 8 Workers |
|--------|-----------|-----------|
| **Village Distribution** | Every 4th village per worker | Every 8th village per worker |
| **Theoretical Speed** | Baseline (1x) | 2x faster |
| **Memory Usage** | ~2-3 GB | ~4-6 GB |
| **Chrome Instances** | 4 headless browsers | 8 headless browsers |
| **CPU Usage** | Moderate (50-70%) | High (80-100%) |
| **Best For** | <50 villages | 50+ villages |

---

## 📊 Example Search Time Estimates

**Search Scenario:** 100 villages, 200 surveys each = 20,000 survey numbers

| Version | Estimated Time | Villages per Worker |
|---------|---------------|---------------------|
| **4 Workers** | ~60-90 minutes | 25 villages each |
| **8 Workers** | ~30-45 minutes | 12-13 villages each |

*Note: Actual time depends on data density and portal response times*

---

## 🔧 Key Differences

### Configuration Changes
```python
# 4 Workers Version
MAX_WORKERS = 4
WORKER_STARTUP_DELAY = 0.5

# 8 Workers Version
MAX_WORKERS = 8
WORKER_STARTUP_DELAY = 0.7  # Slightly longer to prevent conflicts
```

### UI Changes
- **Worker Grid:** Expanded from 2x2 to 4x2 layout
- **Responsive Design:** Adapts to 3 columns on medium screens
- **Version Badge:** Updated to show "8 HIGH-SPEED Workers"

---

## 💻 System Requirements

### 4 Workers Version
- **RAM:** Minimum 8 GB
- **CPU:** 4+ cores recommended
- **macOS:** 10.14+
- **Chrome:** Latest version

### 8 Workers Version
- **RAM:** Minimum 16 GB (**Important!**)
- **CPU:** 6+ cores recommended
- **macOS:** 10.14+
- **Chrome:** Latest version
- **Note:** May cause system slowdown on lower-spec machines

---

## 🎯 When to Use Each Version

### Use 4 Workers Version When:
- ✅ Searching fewer than 50 villages
- ✅ Running on 8 GB RAM systems
- ✅ Need to use computer for other tasks simultaneously
- ✅ First time using the tool (more stable)
- ✅ Dealing with slower internet connections

### Use 8 Workers Version When:
- ✅ Searching 50+ villages (large-scale searches)
- ✅ Have 16+ GB RAM available
- ✅ Computer can be dedicated to search task
- ✅ Maximum speed is priority
- ✅ Fast, stable internet connection

---

## 🚀 How to Run

### 4 Workers Version
```bash
cd /Users/sks/Desktop/POWER-BHOOMI
python3 bhoomi_web_app_v2.py
```

### 8 Workers Version
```bash
cd /Users/sks/Desktop/POWER-BHOOMI
python3 bhoomi_web_app_v2_8workers.py
```

Both versions run on: **http://localhost:5001**

---

## ⚠️ Important Notes

### Memory Management
- **8 Workers uses significantly more memory**
- Monitor Activity Monitor (macOS) during searches
- If system becomes sluggish, use 4 Workers version instead

### Chrome Driver
- Both versions use the same ChromeDriver
- The `webdriver_manager` will auto-download compatible driver
- 8 Workers version may trigger Chrome rate limiting (handled automatically)

### Database Compatibility
- Both versions use the **same SQLite database**
- Search sessions from either version are stored together
- You can switch between versions without data loss

### Port Conflict
- **Cannot run both versions simultaneously** (both use port 5001)
- Stop one version before starting the other

---

## 🔍 Technical Details

### Worker Distribution Algorithm
Both versions use round-robin distribution:

**4 Workers:**
- Worker 0: Villages 0, 4, 8, 12...
- Worker 1: Villages 1, 5, 9, 13...
- Worker 2: Villages 2, 6, 10, 14...
- Worker 3: Villages 3, 7, 11, 15...

**8 Workers:**
- Worker 0: Villages 0, 8, 16, 24...
- Worker 1: Villages 1, 9, 17, 25...
- Worker 2: Villages 2, 10, 18, 26...
- Worker 3: Villages 3, 11, 19, 27...
- Worker 4: Villages 4, 12, 20, 28...
- Worker 5: Villages 5, 13, 21, 29...
- Worker 6: Villages 6, 14, 22, 30...
- Worker 7: Villages 7, 15, 23, 31...

---

## 🛡️ Same Bulletproof Features

Both versions include:
- ✅ Session expiration detection & recovery
- ✅ Browser crash recovery
- ✅ Portal alert handling
- ✅ Real-time SQLite database saves
- ✅ CSV backup exports
- ✅ Village progress tracking
- ✅ Search resume capability
- ✅ Skipped items retry queue
- ✅ Thread-safe data writing

---

## 📈 Recommended Usage Strategy

1. **Start with 4 Workers** for initial testing
2. **Monitor system performance** during a small search
3. **If system handles it well**, try 8 Workers version
4. **Stick with the version** that best balances speed and stability for your machine

---

## 🆘 Troubleshooting

### 8 Workers Version Running Slow
- **Reduce to 4 Workers** version
- Close other applications
- Check available RAM in Activity Monitor
- Ensure stable internet connection

### Chrome Conflicts at Startup
- This is normal with 8 workers
- The `WORKER_STARTUP_DELAY = 0.7s` helps prevent this
- If issues persist, increase delay in Config (line 59)

### System Overheating
- 8 workers can cause high CPU usage
- Use 4 workers version on laptops without external cooling
- Ensure proper ventilation

---

## 📊 Data Output

Both versions produce identical output:
- **CSV Files:** Saved to `~/Downloads/`
- **SQLite Database:** `~/Documents/POWER-BHOOMI/bhoomi_data.db`
- **Format:** Identical column structure
- **Compatibility:** Files from both versions can be merged

---

**Created:** December 17, 2025  
**Author:** POWER-BHOOMI Development Team  
**Version:** 3.0 - Bulletproof Edition

