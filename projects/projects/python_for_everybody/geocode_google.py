"""
geocode_google.py
Geocoding using Google Maps Geocoding API.

Install:
    py -m pip install requests pandas

Usage:
    export GOOGLE_API_KEY="your_key_here"   # on Linux/Mac
    setx GOOGLE_API_KEY "your_key_here"     # on Windows (or set via environment)
    python geocode_google.py
"""

import os
import requests
import pandas as pd
import time

API_KEY = os.getenv('GOOGLE_API_KEY')
if not API_KEY:
    raise RuntimeError("Set the GOOGLE_API_KEY environment variable before running this script.")

GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"

def geocode_place(place):
    params = {
        "address": place,
        "key": API_KEY
    }
    resp = requests.get(GEOCODE_URL, params=params, timeout=10)
    resp.raise_for_status()
    data = resp.json()
    if data.get('status') == 'OK' and data.get('results'):
        r = data['results'][0]
        loc = r['geometry']['location']
        return loc['lat'], loc['lng'], r.get('formatted_address')
    else:
        print(f"Geocode failed for '{place}' — status: {data.get('status')}")
        return None

def batch_geocode_csv(input_csv='example_locations.csv', output_csv='geocoded_google_output.csv', delay=0.2):
    df = pd.read_csv(input_csv)
    if 'place' not in map(str.lower, df.columns):
        cols = {c.lower(): c for c in df.columns}
        if 'place' in cols:
            df.rename(columns={cols['place']: 'place'}, inplace=True)
        else:
            raise ValueError("Input CSV must have a 'place' column")
    results = []
    for _, row in df.iterrows():
        place = row['place']
        print("Geocoding:", place)
        res = geocode_place(place)
        if res:
            lat, lon, addr = res
        else:
            lat = lon = addr = None
        results.append({'place': place, 'latitude': lat, 'longitude': lon, 'address': addr})
        time.sleep(delay)  # respect rate limits
    out_df = pd.DataFrame(results)
    out_df.to_csv(output_csv, index=False)
    print("Wrote output to", output_csv)

def demo():
    places = ["Accra, Ghana", "Kumasi, Ghana", "Korle Bu Teaching Hospital"]
    for p in places:
        print(p, "->", geocode_place(p))

if __name__ == "__main__":
    demo()
