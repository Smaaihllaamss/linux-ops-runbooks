-- ===========================================
-- Helpdesk Database Users and Privileges
-- Principle of least privilege applied.
-- ===========================================

-- -------------------------------------------
-- helpdesk_readonly
-- Read-only access to specific tables.
-- Granted per table, not per database:
-- new tables with restricted access won't be exposed automatically.
-- -------------------------------------------
CREATE USER 'helpdesk_readonly'@'192.168.0.%' IDENTIFIED BY 'PasswdReadonly!0';

GRANT SELECT
    ON helpdesk.tickets     TO 'helpdesk_readonly'@'192.168.0.%';
GRANT SELECT
    ON helpdesk.categories  TO 'helpdesk_readonly'@'192.168.0.%';
GRANT SELECT
    ON helpdesk.clients     TO 'helpdesk_readonly'@'192.168.0.%';
GRANT SELECT
    ON helpdesk.agents      TO 'helpdesk_readonly'@'192.168.0.%';

SHOW GRANTS FOR 'helpdesk_readonly'@'192.168.0.%';

-- -------------------------------------------
-- helpdesk_agent
-- Can create and update tickets, clients, categories.
-- No DELETE: ticket deletion is restricted to helpdesk_admin
-- (least privilege principle).
-- Read-only access to agents: cannot modify support staff list.
-- -------------------------------------------
CREATE USER 'helpdesk_agent'@'192.168.0.%' IDENTIFIED BY 'PasswdAgent!1';

GRANT SELECT, INSERT, UPDATE
    ON helpdesk.tickets     TO 'helpdesk_agent'@'192.168.0.%';
GRANT SELECT, INSERT, UPDATE
    ON helpdesk.categories  TO 'helpdesk_agent'@'192.168.0.%';
GRANT SELECT, INSERT, UPDATE
    ON helpdesk.clients     TO 'helpdesk_agent'@'192.168.0.%';
GRANT SELECT
    ON helpdesk.agents      TO 'helpdesk_agent'@'192.168.0.%';

SHOW GRANTS FOR 'helpdesk_agent'@'192.168.0.%';

-- -------------------------------------------
-- helpdesk_admin
-- Full administrative access to helpdesk database only.
-- Connects via localhost (SSH tunnel) — no direct network access.
-- Not a MySQL root: no access outside helpdesk database.
-- Alternative: 'helpdesk_admin'@'192.168.0.53' for fixed-IP LAN access.
-- or VPN-assigned IP for remote access. Localhost preferred for security.
-- -------------------------------------------
CREATE USER 'helpdesk_admin'@'localhost' IDENTIFIED BY 'PasswdAdmin!2';

GRANT SELECT, INSERT, UPDATE, DELETE,
      CREATE, ALTER, DROP, INDEX,
      CREATE VIEW, SHOW VIEW,
      GRANT OPTION
    ON helpdesk.* TO 'helpdesk_admin'@'localhost';

SHOW GRANTS FOR 'helpdesk_admin'@'localhost';

-- -------------------------------------------
-- backup_user
-- Minimal privileges for mysqldump backups.
-- LOCK TABLES: ensures consistent dump.
-- RELOAD: required for FLUSH operations.
-- PROCESS: allows viewing active connections during dump.
-- SHOW VIEW: required if VIEWs are added in future.
-- No DELETE, INSERT, UPDATE — read-only access to data.
-- For xtrabackup, BACKUP_ADMIN will be added separately.
-- -------------------------------------------
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'PasswdBackup!3';

GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, PROCESS
    ON *.* TO 'backup_user'@'localhost';

SHOW GRANTS FOR 'backup_user'@'localhost';
