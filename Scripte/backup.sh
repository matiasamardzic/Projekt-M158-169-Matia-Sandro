#!/bin/bash
# Moodle Backup Skript für Modul 169 (Matia & Sandro)

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backup"
DB_CONTAINER="moodle_db"
DB_NAME="moodle"
DB_USER="moodleuser"

source ../.env # Holt das Passwort aus dem Hauptordner

echo "Starte Moodle Backup-Prozess..."
mkdir -p $BACKUP_DIR

echo "Erstelle Datenbank-Dump..."
docker exec $DB_CONTAINER /usr/bin/mysqldump -u $DB_USER -p$MYSQL_PASSWORD $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

echo "Sichere Moodle-Dateien..."
docker run --rm \
  -v moodledata:/data:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar -czf /backup/moodledata_$DATE.tar.gz -C /data .

echo "Backup abgeschlossen! Gespeichert in: $BACKUP_DIR"