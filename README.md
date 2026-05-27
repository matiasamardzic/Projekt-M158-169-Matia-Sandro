# Moodle Migration & Parallel Deployment Guide (Side-by-Side)

Dieses Repository enthält das vollständig automatisierte Deployment für die Migration des Moodle-Systems der Schule auf **Moodle Version 4.1.1 LTS** mit einer **MySQL 8.4** Datenbank. 

## Voraussetzungen vor dem Start
1. **Frische Lehrmittel-VM:** Komplett frisch.
2. **USB-Stick (Kundendaten):** Angesteckt. Er muss aus Datenschutzgründen zwingend diese **2 Dateien** enthalten, welche über die `.gitignore` vom Repository ausgeschlossen wurden:
   * `.env` (Die Konfigurationsdatei mit den Passwörtern)
   * `moodledump.sql` (Der originale Datenbank-Dump)

*(Hinweis: Alle weiteren Kursdaten wie der Ordner `moodledata` sind bereits im Repository integriert und werden beim Klonen automatisch mitgeladen).*

---

## Ausführung (Copy & Paste Skript)

### SCHRITT 1: Altes System verschieben & Code holen
Kopieren Sie diesen gesamten Block, fügen Sie ihn in ein Terminal der VM ein und drücken Sie Enter. Dies verschiebt das alte System auf Port 8080, behebt die Design-Pfade, räumt die Docker-Umgebung auf und klont den neuen Code.

```bash
# 1. Apache-Ports auf 8080 umstellen & neu starten
sudo sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-enabled/*.conf
sudo systemctl restart apache2

# 2. Internen Moodle-Pfad (Design-Fix) anpassen
if [ -f /var/www/html/config.php ]; then sudo sed -i "s|'http://localhost'|'http://localhost:8080'|g" /var/www/html/config.php; fi
if [ -f /var/www/html/moodle/config.php ]; then sudo sed -i "s|'http://localhost'|'http://localhost:8080'|g" /var/www/html/moodle/config.php; fi

# 3. Docker aufräumen, Repo klonen & in den Ordner wechseln
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
git clone https://github.com/matiasamardzic/Projekt-M158-169-Matia-Sandro.git
cd Projekt-M158-169-Matia-Sandro
```

---

### MANUELLER SCHRITT: Kundendaten einfügen 
Bevor das neue System gestartet wird, müssen die sensiblen Kundendaten bereitgestellt werden (Secret Provisioning).
Kopieren Sie jetzt manuell die **2 Dateien** (`.env` und `moodledump.sql`) von Ihrem USB-Stick direkt in den neu erstellten Ordner `Projekt-M158-169-Matia-Sandro`.

---

### SCHRITT 2: Neues System (Port 80) starten
Wenn die 2 Dateien im Ordner liegen, kopieren Sie diesen Block komplett ins Terminal und drücken Sie Enter. Docker baut nun die Container und importiert die Datenbank automatisch.

```bash
# 1. Neues Moodle bauen und starten
sudo docker compose up -d --build

# 2. Schreibrechte für Moodle-Daten setzen (gegen Dataroot-Fehler)
sudo chmod -R 777 moodledata
```
*(Warten Sie nach Ausführung ca. 1–2 Minuten, bis Moodle im Hintergrund das interne Datenbank-Upgrade vollzogen hat).*

---

## Erreichbarkeit der Systeme

Sie können nun parallel auf beide Systeme zugreifen, um die erfolgreiche Side-by-Side-Migration zu überprüfen:

* **Neues System (Ziel-Zustand):** `http://localhost`
  
* **Altes System (Backup-Zustand):** `http://localhost:8080`

---

## Automatisiertes Backup testen

Um ein vollständiges Backup der laufenden Moodle-Datenbank und der Kursdatenbank zu erstellen, führen Sie dieses mitgelieferte Skript aus:

```bash
sudo chmod +x backup.sh
sudo ./backup.sh
```
Das Backup wird anschliessend sicher mit einem Zeitstempel im Ordner `/backup` abgelegt.
