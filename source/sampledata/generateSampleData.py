import json
import random
from datetime import datetime, timedelta

# Vorlage für einen Eintrag, den wir vervielfältigen und anpassen
template_entry = {
    "shareId": 15768771,
    "from": 84793,
    "to": 84793,
    "patientId": 361510,
    "patientFullName": "GWS Gabi",
    "formatType": "4",
    "studyDate": "2018-01-04 00:00:00",
    "createdAt": "2021-02-27 13:15:23",
    "studyId": 1664864,
    "patientSsn": "3333030333",
    "patientDob": "1933-03-03",
    "studyDescription": "MLWS",
    "documentUrl": "https://www.bilder-befunde.at/webview/viewer/index.php?value=%3DsYXNymWcLbUvZwCPqVEGlme9cVCqLtLOTY2GT4aRykKd5sA3Hz%2B2fH05NGZEMB7TB9i2OIPFGimWDihSc0L8yuHzgG5wXZLkMxU%3D"
}

# Funktion, um die URL zu ändern, damit sie einzigartig wird
def generate_unique_url(base_url, id):
    return f"{base_url}?value={id}"

# Generiere 1000 Einträge
data = []
for i in range(1000):
    # Kopiere das Template
    entry = template_entry.copy()
    
    # Generiere einzigartige IDs
    entry["shareId"] = 15768771 + i
    entry["studyId"] = 1664864 + i
    entry["patientSsn"] = 3333030333 + i
    entry["patientId"] = 361510 + i
    
    # Ändere das Datum für Abwechslung
    study_date = datetime.strptime(entry["studyDate"], "%Y-%m-%d %H:%M:%S") + timedelta(days=i % 365)
    entry["studyDate"] = study_date.strftime("%Y-%m-%d %H:%M:%S")
    
    # Passe die URL an
    entry["documentUrl"] = generate_unique_url("https://www.bilder-befunde.at/webview/viewer/index.php", i)
    
    # Füge den Eintrag zur Liste hinzu
    data.append(entry)

# Speichere die Daten als JSON
with open("generated_data.json", "w") as f:
    json.dump(data, f, indent=4)

print("Datensatz mit 1000 Einträgen wurde erstellt und gespeichert als 'generated_data.json'.")
