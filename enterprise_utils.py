#!/usr/bin/env python3
"""
Enterprise Utilities for POWER-BHOOMI
Logging, health checks, monitoring, and system utilities
"""

import os
import sys
import time
import psutil
import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, Any
import json


# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING SETUP
# ═══════════════════════════════════════════════════════════════════════════════

def setup_enterprise_logging(config: Dict[str, Any]) -> logging.Logger:
    """
    Set up enterprise-grade logging with rotation and multiple handlers
    """
    log_config = config['logging']
    log_file = log_config['file']
    log_level = getattr(logging, log_config['level'].upper())
    
    # Ensure log directory exists
    Path(log_file).parent.mkdir(parents=True, exist_ok=True)
    
    # Create formatter
    formatter = logging.Formatter(
        log_config['format'],
        datefmt=log_config.get('date_format', '%Y-%m-%d %H:%M:%S')
    )
    
    # Root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    
    # Remove existing handlers
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # File handler with rotation
    if log_config.get('file_enabled', True):
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=log_config['max_size'],
            backupCount=log_config['backup_count'],
            encoding='utf-8'
        )
        file_handler.setFormatter(formatter)
        file_handler.setLevel(log_level)
        root_logger.addHandler(file_handler)
    
    # Console handler
    if log_config.get('console_enabled', True):
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        console_handler.setLevel(log_level)
        root_logger.addHandler(console_handler)
    
    # Error file handler (separate file for errors)
    error_log = Path(log_file).parent / 'error.log'
    error_handler = RotatingFileHandler(
        str(error_log),
        maxBytes=log_config['max_size'],
        backupCount=log_config['backup_count'],
        encoding='utf-8'
    )
    error_handler.setFormatter(formatter)
    error_handler.setLevel(logging.ERROR)
    root_logger.addHandler(error_handler)
    
    return root_logger


# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

class HealthMonitor:
    """System health monitoring"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.start_time = datetime.now()
        self.pid = os.getpid()
    
    def get_uptime(self) -> float:
        """Get application uptime in seconds"""
        return (datetime.now() - self.start_time).total_seconds()
    
    def get_memory_usage(self) -> Dict[str, Any]:
        """Get current memory usage"""
        process = psutil.Process(self.pid)
        mem_info = process.memory_info()
        
        return {
            'rss_mb': round(mem_info.rss / (1024 * 1024), 2),
            'vms_mb': round(mem_info.vms / (1024 * 1024), 2),
            'percent': round(process.memory_percent(), 2),
            'system_total_mb': round(psutil.virtual_memory().total / (1024 * 1024), 2),
            'system_available_mb': round(psutil.virtual_memory().available / (1024 * 1024), 2),
            'system_percent': round(psutil.virtual_memory().percent, 2)
        }
    
    def get_cpu_usage(self) -> Dict[str, Any]:
        """Get CPU usage"""
        process = psutil.Process(self.pid)
        
        return {
            'process_percent': round(process.cpu_percent(interval=0.1), 2),
            'system_percent': round(psutil.cpu_percent(interval=0.1), 2),
            'num_threads': process.num_threads(),
            'num_cpus': psutil.cpu_count()
        }
    
    def get_disk_usage(self) -> Dict[str, Any]:
        """Get disk usage for data directory"""
        data_dir = self.config['paths']['data_dir']
        disk = psutil.disk_usage(data_dir)
        
        return {
            'total_gb': round(disk.total / (1024**3), 2),
            'used_gb': round(disk.used / (1024**3), 2),
            'free_gb': round(disk.free / (1024**3), 2),
            'percent': round(disk.percent, 2)
        }
    
    def check_database(self) -> Dict[str, Any]:
        """Check database health"""
        db_path = self.config['database']['path']
        
        try:
            if not Path(db_path).exists():
                return {'status': 'not_found', 'healthy': False}
            
            # Get database size
            size_mb = round(Path(db_path).stat().st_size / (1024 * 1024), 2)
            
            # Try to connect
            import sqlite3
            conn = sqlite3.connect(db_path, timeout=5)
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
            table_count = cursor.fetchone()[0]
            conn.close()
            
            return {
                'status': 'healthy',
                'healthy': True,
                'size_mb': size_mb,
                'tables': table_count,
                'path': db_path
            }
        except Exception as e:
            return {
                'status': 'error',
                'healthy': False,
                'error': str(e)
            }
    
    def get_health_status(self) -> Dict[str, Any]:
        """Get complete health status"""
        return {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'version': self.config['app']['version'],
            'uptime_seconds': round(self.get_uptime(), 2),
            'uptime_human': self._format_uptime(self.get_uptime()),
            'memory': self.get_memory_usage(),
            'cpu': self.get_cpu_usage(),
            'disk': self.get_disk_usage(),
            'database': self.check_database(),
            'pid': self.pid,
            'python_version': f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
        }
    
    def _format_uptime(self, seconds: float) -> str:
        """Format uptime in human-readable format"""
        duration = timedelta(seconds=int(seconds))
        days = duration.days
        hours, remainder = divmod(duration.seconds, 3600)
        minutes, seconds = divmod(remainder, 60)
        
        parts = []
        if days > 0:
            parts.append(f"{days}d")
        if hours > 0:
            parts.append(f"{hours}h")
        if minutes > 0:
            parts.append(f"{minutes}m")
        parts.append(f"{seconds}s")
        
        return " ".join(parts)


# ═══════════════════════════════════════════════════════════════════════════════
# METRICS COLLECTION
# ═══════════════════════════════════════════════════════════════════════════════

class MetricsCollector:
    """Collect application metrics"""
    
    def __init__(self):
        self.metrics = {
            'searches_total': 0,
            'searches_completed': 0,
            'searches_failed': 0,
            'records_total': 0,
            'matches_total': 0,
            'villages_processed': 0,
            'session_recoveries': 0,
            'browser_crashes': 0,
            'api_requests': {},
            'errors': []
        }
    
    def increment(self, metric: str, amount: int = 1):
        """Increment a metric"""
        if metric in self.metrics:
            self.metrics[metric] += amount
    
    def set(self, metric: str, value: Any):
        """Set a metric value"""
        self.metrics[metric] = value
    
    def record_api_request(self, endpoint: str):
        """Record an API request"""
        if endpoint not in self.metrics['api_requests']:
            self.metrics['api_requests'][endpoint] = 0
        self.metrics['api_requests'][endpoint] += 1
    
    def record_error(self, error: Dict[str, Any]):
        """Record an error"""
        error['timestamp'] = datetime.now().isoformat()
        self.metrics['errors'].append(error)
        # Keep only last 100 errors
        if len(self.metrics['errors']) > 100:
            self.metrics['errors'] = self.metrics['errors'][-100:]
    
    def get_metrics(self) -> Dict[str, Any]:
        """Get all metrics"""
        return self.metrics.copy()
    
    def export_metrics(self, filepath: str):
        """Export metrics to JSON file"""
        with open(filepath, 'w') as f:
            json.dump(self.metrics, f, indent=2)


# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

def check_system_requirements() -> Dict[str, Any]:
    """Check if system meets minimum requirements"""
    results = {
        'meets_requirements': True,
        'checks': {}
    }
    
    # Check Python version
    py_version = (sys.version_info.major, sys.version_info.minor)
    results['checks']['python_version'] = {
        'required': '3.8+',
        'current': f"{py_version[0]}.{py_version[1]}",
        'pass': py_version >= (3, 8)
    }
    
    # Check RAM
    mem = psutil.virtual_memory()
    mem_gb = mem.total / (1024**3)
    results['checks']['memory'] = {
        'required_gb': 8,
        'current_gb': round(mem_gb, 2),
        'pass': mem_gb >= 8
    }
    
    # Check disk space
    disk = psutil.disk_usage('/')
    disk_free_gb = disk.free / (1024**3)
    results['checks']['disk_space'] = {
        'required_gb': 2,
        'free_gb': round(disk_free_gb, 2),
        'pass': disk_free_gb >= 2
    }
    
    # Check Chrome
    chrome_paths = [
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        '/Applications/Chromium.app/Contents/MacOS/Chromium'
    ]
    chrome_found = any(Path(p).exists() for p in chrome_paths)
    results['checks']['chrome'] = {
        'required': True,
        'found': chrome_found,
        'pass': chrome_found
    }
    
    # Overall result
    results['meets_requirements'] = all(
        check['pass'] for check in results['checks'].values()
    )
    
    return results


def create_pid_file(config: Dict[str, Any]):
    """Create PID file to prevent multiple instances"""
    pid_file = config['system']['pid_file']
    
    if Path(pid_file).exists():
        # Check if process is still running
        try:
            with open(pid_file, 'r') as f:
                old_pid = int(f.read().strip())
            
            if psutil.pid_exists(old_pid):
                raise RuntimeError(
                    f"Application is already running (PID: {old_pid}). "
                    f"Stop it first or remove {pid_file}"
                )
        except (ValueError, IOError):
            pass
    
    # Write current PID
    Path(pid_file).parent.mkdir(parents=True, exist_ok=True)
    with open(pid_file, 'w') as f:
        f.write(str(os.getpid()))


def remove_pid_file(config: Dict[str, Any]):
    """Remove PID file on shutdown"""
    pid_file = config['system']['pid_file']
    if Path(pid_file).exists():
        Path(pid_file).unlink()


def backup_database(config: Dict[str, Any]) -> str:
    """Create database backup"""
    import shutil
    from datetime import datetime
    
    db_path = Path(config['database']['path'])
    if not db_path.exists():
        return None
    
    # Create backup directory
    backup_dir = db_path.parent / 'backups'
    backup_dir.mkdir(exist_ok=True)
    
    # Create backup filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_path = backup_dir / f'bhoomi_data_{timestamp}.db'
    
    # Copy database
    shutil.copy2(db_path, backup_path)
    
    # Clean old backups
    retention_days = config['database'].get('backup_retention', 30)
    cutoff_date = datetime.now() - timedelta(days=retention_days)
    
    for backup_file in backup_dir.glob('bhoomi_data_*.db'):
        file_time = datetime.fromtimestamp(backup_file.stat().st_mtime)
        if file_time < cutoff_date:
            backup_file.unlink()
    
    return str(backup_path)


# Global instances
_health_monitor = None
_metrics_collector = None

def get_health_monitor(config: Dict[str, Any] = None) -> HealthMonitor:
    """Get or create health monitor instance"""
    global _health_monitor
    if _health_monitor is None and config:
        _health_monitor = HealthMonitor(config)
    return _health_monitor

def get_metrics_collector() -> MetricsCollector:
    """Get or create metrics collector instance"""
    global _metrics_collector
    if _metrics_collector is None:
        _metrics_collector = MetricsCollector()
    return _metrics_collector


if __name__ == '__main__':
    # Test utilities
    print("Testing enterprise utilities...")
    print("\n System Requirements:")
    print(json.dumps(check_system_requirements(), indent=2))

