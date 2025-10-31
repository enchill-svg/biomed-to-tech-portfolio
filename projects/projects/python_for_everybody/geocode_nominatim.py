"""
geocode_nominatim.py
Simple geocoding and reverse-geocoding using geopy + OpenStreetMap Nominatim.

Install:
    pip install geopy pandas

Usage examples:
    python geocode_nominatim.py            # runs small demo
    python geocode_nominatim.py csv       # runs batch geocode from example_locations.csv
"""

from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import time
import csv
import sys
import pandas as pd

geolocator = Nominatim(user_agent="muazu_python_geocoder")
# RateLimiter: at most 1 call per second (Nominatim policy)
geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)
reverse = RateLimiter(geolocator.reverse, min_delay_seconds=1)

def find_location(place_name):
    """Return (latitude, longitude, display_name) or None."""
    try:
        location = geocode(place_name)
        if location:
            return (location.latitude, location.longitude, location.address)
        return None
    except Exception as e:
        print(f"Error geocoding '{place_name}': {e}")
        return None

def reverse_lookup(lat, lon):
    """Return address string or None."""
    try:
        loc = reverse((lat, lon), exactly_one=True)
        return loc.address if loc else None
    except Exception as e:
        print(f"Error reverse-geocoding {lat},{lon}: {e}")
        return None

def batch_geocode_csv(input_csv='example_locations.csv', output_csv='geocoded_output.csv'):
    """
    Input CSV expected to have a column 'place' (case-insensitive).
    Output CSV will contain: place, latitude, longitude, address
    """
    df = pd.read_csv(input_csv)
    if 'place' not in map(str.lower, df.columns):
        # Try find column name ignoring case
        cols = {c.lower(): c for c in df.columns}
        if 'place' in cols:
            df.rename(columns={cols['place']: 'place'}, inplace=True)
        else:
            raise ValueError("Input CSV must have a 'place' column")

    results = []
    for _, row in df.iterrows():
        place = row['place']
        print(f"Geocoding: {place}")
        res = find_location(place)
        if res:
            lat, lon, addr = res
        else:
            lat = lon = addr = None
        results.append({'place': place, 'latitude': lat, 'longitude': lon, 'address': addr})
        # be polite to the service (RateLimiter also enforces delay)
    out_df = pd.DataFrame(results)
    out_df.to_csv(output_csv, index=False)
    print(f"Wrote results to {output_csv}")

def demo():
    samples = [
        "Accra, Ghana",
        "Kumasi, Ghana",
        "Korle Bu Teaching Hospital, Accra",
        "37.7749,-122.4194"  # This will be interpreted as string; reverse lookup example below
    ]
    print("Single lookups:")
    for s in samples[:3]:
        r = find_location(s)
        print(s, "->", r)

    print("\nReverse lookup example (lat,lon):")
    lat, lon = 37.7749, -122.4194
    print(f"{lat},{lon} ->", reverse_lookup(lat, lon))

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].lower() == 'csv':
        # run batch example
        batch_geocode_csv()
    else:
        demo()
