import requests
import json

api_key = "sk_f72f59133f8f35416c2a72f20d93b3a2cec2245507513397"
url = "https://api.elevenlabs.io/v1/voices"
headers = {"xi-api-key": api_key}

response = requests.get(url, headers=headers)
with open("voices_output.txt", "w") as f:
    if response.status_code == 200:
        data = response.json()
        for v in data.get("voices", []):
            category = v.get("category", "")
            if category == "premade":
                gender = v.get("labels", {}).get("gender", "unknown")
                f.write(f"Name: {v.get('name')}, ID: {v.get('voice_id')}, Gender: {gender}\n")
    else:
        f.write(f"Error: {response.text}")
