#!/usr/bin/env python3
"""
Configuration Loader for POWER-BHOOMI
Loads configuration from YAML file with environment variable substitution
"""

import os
import yaml
import logging
from pathlib import Path
from typing import Dict, Any
import re

class ConfigLoader:
    """
    Enterprise configuration loader with environment variable support
    """
    
    def __init__(self, config_path: str = None):
        """Initialize configuration loader"""
        if config_path is None:
            # Try multiple locations
            config_locations = [
                './config.yaml',
                '~/.config/power-bhoomi/config.yaml',
                '/etc/power-bhoomi/config.yaml',
                os.path.join(os.path.dirname(__file__), 'config.yaml')
            ]
            
            for location in config_locations:
                expanded_path = Path(location).expanduser()
                if expanded_path.exists():
                    config_path = str(expanded_path)
                    break
            
            if config_path is None:
                raise FileNotFoundError("Configuration file not found in any of the expected locations")
        
        self.config_path = Path(config_path).expanduser()
        self.config = self._load_config()
        self._substitute_env_vars()
        self._expand_paths()
        self._validate_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load YAML configuration file"""
        try:
            with open(self.config_path, 'r') as f:
                config = yaml.safe_load(f)
            return config
        except Exception as e:
            raise RuntimeError(f"Failed to load configuration: {e}")
    
    def _substitute_env_vars(self):
        """Substitute environment variables in configuration values"""
        def substitute(obj):
            if isinstance(obj, dict):
                return {k: substitute(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [substitute(item) for item in obj]
            elif isinstance(obj, str):
                # Replace ${VAR_NAME} with environment variable
                pattern = r'\$\{(\w+)\}'
                matches = re.findall(pattern, obj)
                for match in matches:
                    env_value = os.environ.get(match, self._get_default_env_value(match))
                    obj = obj.replace(f'${{{match}}}', env_value)
                return obj
            else:
                return obj
        
        self.config = substitute(self.config)
    
    def _get_default_env_value(self, var_name: str) -> str:
        """Get default value for environment variables"""
        defaults = {
            'DATA_DIR': str(Path(self.config['paths']['data_dir']).expanduser()),
            'LOG_DIR': str(Path(self.config['paths']['log_dir']).expanduser()),
            'CACHE_DIR': str(Path(self.config['paths']['cache_dir']).expanduser()),
            'CONFIG_DIR': str(Path(self.config['paths']['config_dir']).expanduser()),
            'DOWNLOADS_DIR': str(Path(self.config['paths']['downloads_dir']).expanduser()),
            'SECRET_KEY': self._generate_secret_key(),
        }
        return defaults.get(var_name, '')
    
    def _generate_secret_key(self) -> str:
        """Generate a secret key for the application"""
        import secrets
        return secrets.token_hex(32)
    
    def _expand_paths(self):
        """Expand ~ in paths"""
        def expand(obj):
            if isinstance(obj, dict):
                return {k: expand(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [expand(item) for item in obj]
            elif isinstance(obj, str) and ('/' in obj or '~' in obj):
                return str(Path(obj).expanduser())
            else:
                return obj
        
        self.config = expand(self.config)
    
    def _validate_config(self):
        """Validate required configuration fields"""
        required_sections = ['app', 'workers', 'database', 'paths', 'logging']
        for section in required_sections:
            if section not in self.config:
                raise ValueError(f"Missing required configuration section: {section}")
        
        # Create required directories
        for key, path in self.config['paths'].items():
            Path(path).mkdir(parents=True, exist_ok=True)
    
    def get(self, key: str, default=None) -> Any:
        """Get configuration value by dot-notation key"""
        keys = key.split('.')
        value = self.config
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        return value
    
    def set(self, key: str, value: Any):
        """Set configuration value by dot-notation key"""
        keys = key.split('.')
        config = self.config
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        config[keys[-1]] = value
    
    def save(self, path: str = None):
        """Save configuration to file"""
        save_path = path or self.config_path
        with open(save_path, 'w') as f:
            yaml.dump(self.config, f, default_flow_style=False, sort_keys=False)
    
    def __getitem__(self, key):
        """Allow dict-like access"""
        return self.config[key]
    
    def __setitem__(self, key, value):
        """Allow dict-like setting"""
        self.config[key] = value
    
    def __contains__(self, key):
        """Allow 'in' operator"""
        return key in self.config


# Global config instance
_config = None

def get_config(config_path: str = None) -> ConfigLoader:
    """Get or create global configuration instance"""
    global _config
    if _config is None:
        _config = ConfigLoader(config_path)
    return _config


if __name__ == '__main__':
    # Test configuration loader
    config = get_config()
    print("Configuration loaded successfully!")
    print(f"App Name: {config.get('app.name')}")
    print(f"Workers: {config.get('workers.max_workers')}")
    print(f"Database: {config.get('database.path')}")
    print(f"Log Level: {config.get('logging.level')}")

