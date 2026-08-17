# mysql-ops

Operational runbooks for MySQL administration: startup failures, backup, restore, and replication.

All scenarios were reproduced and diagnosed on Oracle Linux 9.8 in VirtualBox.

---

## Service Failures

| File | Scenario |
|------|----------|
| `playbook-mysql-service-failure.md` | General triage playbook: MySQL service won't start |
| `runbook-mysql-invalid-config.md` | Startup failure due to invalid `/etc/my.cnf.d/mysql-server.cnf` |
| `runbook-mysql-wrong-ownership.md` | Startup failure due to incorrect file ownership |
| `runbook-mysql-address-in-use.md` | Startup failure: TCP port or Unix socket already in use |

## Backup & Restore

| File | Scenario |
|------|----------|
| `runbook-db-backup-restore-mysqldump.md` | Logical backup and restore with `mysqldump` |
| `runbook-db-backup-restore-xtrabackup.md` | Physical backup and restore with `XtraBackup` |

## Replication

| File | Scenario |
|------|----------|
| `runbook-mysql-replication-health.md` | Routine replication health check |
| `runbook-mysql-replication-io-thread.md` | I/O thread stopped: diagnosis and recovery |
| `runbook-mysql-replication-sql-thread.md` | SQL thread stopped: diagnosis and recovery |

---

## Environment

- OS: Oracle Linux 9.8
- Platform: VirtualBox
- Topology: Master + Replica, NAT and Bridge adapters