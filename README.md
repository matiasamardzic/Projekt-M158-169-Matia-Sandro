# Projekt-M158-169-Matia-Sandro
# 🚀 Moodle Migration & Parallel Deployment Guide (Side-by-Side)

Dieses Repository enthält das vollständig automatisierte Deployment für die Migration des Moodle-Systems der Schule auf **Moodle Version 4.1.1 LTS** mit einer **MySQL 8.4** Datenbank. 

Dieses Dokument dient als exakter, schrittweiser Leitfaden für das Kundengespräch mit Herrn Lux und für den Testlauf auf der frischen Lehrmittel-VM.

---

## 📋 Voraussetzungen vor dem Start

1. **Frische Lehrmittel-VM:** Komplett frisch.
2. **USB-Stick (Kundendaten):** Angesteckt. Er muss zwingend folgende **2 Dateien** enthalten:
   * `.env` (Die Konfigurationsdatei mit den Passwörtern)
   * `moodledump.sql` (Der originale Datenbank-Dump)

*(Hinweis: Alle weiteren Kursdaten wie der Ordner `moodledata` sind bereits im Repository integriert und werden beim Klonen automatisch mitgeladen).*

---

## 🛠️ Schritt-für-Schritt Live-Skript

Führt die folgenden Befehle nacheinander im Linux-Terminal der VM aus.

### SCHRITT 1: Altes Moodle auf Port 8080 verschieben & Design fixen

Wir verschieben das alte System auf Port 8080, damit unser neues System den Haupt-Port 80 übernehmen kann. Die CSS-Pfade werden automatisch korrigiert.

```bash
# 1. Apache-Ports von 80 auf 8080 umstellen
sudo sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-enabled/*.conf

# 2. Apache neu starten
sudo systemctl restart apache2

# 3. Internen Moodle-Pfad (Design-Fix) umkonfigurieren
if [ -f /var/www/html/config.php ]; then
    sudo sed -i "s|'http://localhost'|'http://localhost:8080'|g" /var/www/html/config.php
fi
if [ -f /var/www/html/moodle/config.php ]; then
    sudo sed -i "s|'http://localhost'|'http://localhost:8080'|g" /var/www/html/moodle/config.php
fi


### SCHRITT 2: Bereinigung, Klonen & USB-Transfer

Wir holen den Code von GitHub und binden die geschützten Kundendaten ein.

```bash
# 1. Alte Docker-Leichen killen
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true

# 2. Repository klonen
git clone [https://github.com/matiasamardzic/Projekt-M158-169-Matia-Sandro.git](https://github.com/matiasamardzic/Projekt-M158-169-Matia-Sandro.git)

# 3. In den Ordner wechseln
cd Projekt-M158-169-Matia-Sandro
⚠️ MANUELLER SCHRITT: Kopiere jetzt die 2 Dateien (.env und moodledump.sql) vom USB-Stick genau in diesen Ordner Projekt-M158-169-Matia-Sandro.

### SCHRITT 3: Das neues Moodle auf Port 80 starten
Wir starten die automatisierte Infrastruktur (Infrastructure-as-Code).

```bash
# 1. Container bauen und starten
sudo docker compose up -d --build

# 2. Schreibrechte für Moodle-Daten setzen (Behebt den dataroot-Fehler)
sudo chmod -R 777 moodledata


### SCHRITT 4: Migration & Zielversion beweisen


### SCHRITT 5: Das automatisierte Backup (Testfall 6)

```bash

# Backup ausführen
sudo chmod +x backup.sh
sudo ./backup.sh
