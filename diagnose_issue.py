#!/usr/bin/env python3
"""
Diagnostic script to check what district/taluk codes are available
"""

import requests
import json
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

ECHAWADI_BASE = "https://rdservices.karnataka.gov.in/echawadi/Home"

session = requests.Session()
session.headers.update({
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Content-Type': 'application/json; charset=utf-8',
})

print("Fetching districts...")
response = session.get(f"{ECHAWADI_BASE}/LoadDistrict", verify=False, timeout=30)
result = response.text

if result.startswith('"'):
    result = json.loads(result)
if isinstance(result, str):
    result = json.loads(result)

if result and 'data' in result:
    districts = result['data']
    print(f"\nFound {len(districts)} districts:")
    for d in districts[:10]:
        print(f"  Code: {d.get('district_code'):<5} Name: {d.get('district_name_kn', 'N/A')}")
    
    # Check if district code "2" exists
    dist_2 = [d for d in districts if str(d.get('district_code')) == '2']
    if dist_2:
        print(f"\n✓ District code '2' exists: {dist_2[0].get('district_name_kn')}")
    else:
        print(f"\n✗ District code '2' NOT FOUND")
        print(f"  Available codes: {[d.get('district_code') for d in districts[:10]]}")
else:
    print("Failed to fetch districts")

print("\n" + "="*60)
print("If district code '2' is not found, please:")
print("1. Open the application in browser")
print("2. Select the district from the dropdown")
print("3. Check browser console for the actual district code value")
print("="*60)

