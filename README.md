# linux-ops-runbooks

A collection of operational runbooks and diagnostic references for Linux systems.
These documents were created during hands-on lab practice: diagnosing systems in unknown state, including scenarios with deliberately introduced faults.
The environment uses Oracle Linux 9.8 virtual machines in VirtualBox.

## Contents

| File | Description | Status |
|------|-------------|--------|
| `investigate-unknown-system.md` | First-response checklist: identity, trust, system state, network | ✅ Ready |
| `network-diagnostic-cheatsheet.md` | Quick reference for network triage commands | ✅ Ready |
| `runbook-hostname-resolution-failure.md` | Host cannot resolve hostnames | ✅ Ready |
| `runbook-mismatched-subnet-mask.md` | Host cannot reach neighbors due to subnet mask mismatch | ✅ Ready |
| `runbook-cpu-ram-diagnostics.md` | CPU and memory diagnostics | 🔄 In progress |
| `runbook-disk-diagnostics.md` | Disk usage and health diagnostics | 🔄 In progress |

## MySQL Lab

The `mysql/` directory contains a hands-on MySQL administration lab based on a helpdesk ticketing schema.
It covers database setup, user privileges, query writing, backup, and replication.

| File | Description |
|------|-------------|
| `mysql/schema.sql` | Database schema: CREATE DATABASE, CREATE TABLE |
| `mysql/seed.sql` | Sample data: 10 clients, 5 categories, 5 agents, 20 tickets |
| `mysql/users_and_privileges.sql` | User roles: readonly, agent, admin |
| `mysql/demo_queries.sql` | JOIN, GROUP BY, subquery examples with comments |
| `mysql/backup.sh` | Automated backup script with 7-day rotation |
| `mysql/replication_setup.md` | Step-by-step MySQL replication setup guide | 🔄 In progress |

See [`mysql/README.md`](mysql/README.md) for setup instructions and sample output.

## MySQL Operations

| File | Description | Status |
|------|-------------|--------|
| `mysql-ops/playbook-mysql-service-failure.md` | Triage playbook for MySQL service failures | ✅ Ready |
| `mysql-ops/runbook-mysql-invalid-config.md` | MySQL fails to start due to invalid configuration | ✅ Ready |
| `mysql-ops/runbook-mysql-wrong-ownership.md` | MySQL fails due to incorrect file ownership | ✅ Ready |
| `mysql-ops/runbook-mysql-address-in-use.md` | MySQL fails to start: TCP port or Unix socket already in use | ✅ Ready |
| `mysql-ops/runbook-db-backup-restore-mysqldump.md` | Backup and restore with mysqldump | 🔄 In progress |
| `mysql-ops/runbook-db-backup-restore-xtrabackup.md` | Backup and restore with XtraBackup | 🔄 In progress |
| `mysql-ops/runbook-mysql-replication-health.md` | Replication health check procedures | 🔄 In progress |
| `mysql-ops/runbook-mysql-replication-io-thread.md` | Diagnosing replication I/O thread errors | 🔄 In progress |
| `mysql-ops/runbook-mysql-replication-sql-thread.md` | Diagnosing replication SQL thread errors | 🔄 In progress |

See [`mysql-ops/README.md`](mysql-ops/README.md) for context and scenario descriptions.

## Lab Environment

- OS: Oracle Linux 9.8
- Platform: VirtualBox
- Topology: two VMs (Master + Replica), NAT and Bridge network adapters

## Skills Covered

- Linux system diagnostics and first-response investigation
- Network troubleshooting: DNS, routing, iptables, subnetting, packet capture
- systemd service management
- MySQL administration: schema design, user privileges, backup, replication
- MySQL replication monitoring and fault recovery
- Web application deployment: Apache, HTTPS (Let's Encrypt)

---

## Certification

This repository supports my PortaOne Linux & Network Administration certification.

[View certificate (PDF)](certificates/portaone-lna-certificate.pdf)
