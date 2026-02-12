"""Quick test script for the /api/fetch endpoint."""
import requests
import json
import sys

url = "http://localhost:8000/api/fetch"
data = {"username": "230248", "password": "gks@1234567890"}

print(f"POST {url}")
print(f"Sending credentials for user: {data['username']}")
print("-" * 50)
print("Waiting for response (this takes ~30-60 seconds for Selenium to scrape)...")

try:
    resp = requests.post(url, json=data, timeout=180)
    print(f"\nStatus: {resp.status_code}")
    result = resp.json()
    print(f"Success: {result.get('success')}")
    print(f"Message: {result.get('message', '')}")
    print(f"Subjects found: {len(result.get('data', []))}")
    print("-" * 50)
    for subj in result.get("data", []):
        print(f"  {subj['subject_code']}: {subj['hours_attended']}/{subj['total_hours']} ({subj['percentage']}%)")
    if not result.get("data"):
        print("  (no subjects returned)")
        print("\n  Check backend/debug/ folder for HTML dumps")
        print("  Check the server terminal for detailed logs")
except requests.exceptions.ConnectionError:
    print("ERROR: Could not connect. Is the server running?")
    print("Start it with: python main.py")
except requests.exceptions.Timeout:
    print("ERROR: Request timed out after 180 seconds")
except Exception as e:
    print(f"ERROR: {e}")
