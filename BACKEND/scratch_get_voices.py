import os
import requests

api_key = "sk_f72f59133f8f35416c2a72f20d93b3a2cec2245507513397"
url = "https://api.elevenlabs.io/v1/voices"
headers = {"xi-api-key": api_key}

response = requests.get(url, headers=headers)
if response.status_code == 200:
    data = response.json()
    print("Voces Pre-hechas femeninas:")
    for v in data.get("voices", []):
        if v.get("category") == "premade" and "female" in v.get("labels", {}).get("gender", "").lower():
            print(f"Nombre: {v.get('name')}, ID: {v.get('voice_id')}")
else:
    print("Error:", response.text)
