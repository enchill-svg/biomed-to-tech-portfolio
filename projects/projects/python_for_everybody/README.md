# Python for Everybody Scripts

These scripts helped me build foundational Python skills for real-world data automation and API integration.

---

## 🧭 Purpose
Small Python projects completed as part of the **"Python for Everybody"** course.  
Topics include loops, functions, data structures, file I/O, and working with external APIs.

This folder demonstrates geocoding (finding coordinates from place names) and reverse-geocoding (finding addresses from coordinates) using two approaches:

1. **geocode_nominatim.py** — Uses OpenStreetMap’s Nominatim via `geopy`. No API key required (great for learning).  
2. **geocode_google.py** — Uses Google Maps Geocoding API (requires a Google API key).

---

## ⚙️ Quickstart

To run the scripts, you’ll need:

- **Python 3.8+**
- Required packages: `geopy`, `requests`, `pandas`
- (Optional) **Google Maps API Key** with Geocoding enabled if using `geocode_google.py`

### 1️⃣ Install Dependencies
```bash
py -m pip install geopy requests pandas

2️⃣ Run the Nominatim (Free) Script
python geocode_nominatim.py


This will:

Look up sample locations (Accra, Kumasi, etc.)

Display their coordinates and addresses

Save batch results to geocoded_output.csv if run with csv argument:

python geocode_nominatim.py csv

3️⃣ Run the Google Maps Script

Requires your API key to be stored as an environment variable:

export GOOGLE_API_KEY="your_google_api_key"
python geocode_google.py


This version provides more accurate results and global coverage.
