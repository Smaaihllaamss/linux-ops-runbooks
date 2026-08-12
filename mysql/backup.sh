#!/bin/bash
# ===========================================
# Helpdesk MySQL Backup Script
# Creates a dated dump and removes backups older than 7 days.
# Run manually: bash backup.sh
# Cron (daily at 2:00 AM): 0 2 * * * /path/to/backup.sh
# ===========================================

# Prerequisites:
# sudo mkdir -p /var/backups/mysql
# sudo chown <user>:<group> /var/backups/mysql

DB_NAME="helpdesk"
DB_USER="backup_user"
DB_PASS="PasswdBackup!3"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$DATE.sql.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Run mysqldump and compress output
mysqldump -u "$DB_USER" -p"$DB_PASS" --single-transaction "$DB_NAME" | gzip > "$BACKUP_FILE"

# Check if backup succeeded
if [ $? -eq 0 ]; then
    echo "[$DATE] Backup successful: $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "[$DATE] Backup FAILED" >> "$LOG_FILE"
    exit 1
fi

# Remove backups older than 7 days
find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

echo "[$DATE] Rotation complete: backups older than 7 days removed" >> "$LOG_FILE"