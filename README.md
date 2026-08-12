# linux-ops-runbooks

A collection of operational runbooks and diagnostic references for Linux systems.
These documents were created during hands-on lab practice: diagnosing systems in unknown state, including scenarios with deliberately introduced faults.
The environment uses Oracle Linux 9.8 virtual machines in VirtualBox.

## Contents

| File | Description | Status |
|------|-------------|--------|
| `investigate-unknown-system.md` | First-response checklist: identity, trust, system state, network | ✅ Ready |
| `network-diagnostic-cheatsheet.md` | Quick reference for network triage commands | ✅ Ready |
| `runbook-01-hostname-resolution-failure.md` | Host cannot resolve hostnames | ✅ Ready |
| `runbook-02-mismatched-subnet-mask.md` | Host cannot reach neighbors due to subnet mask mismatch | ✅ Ready |
| `runbook-03-service-management.md` | systemd service diagnostics | 🔄 In progress |
| `runbook-04-cpu-ram-diagnostics.md` | CPU and memory diagnostics | 🔄 In progress |
| `runbook-05-disk-diagnostics.md` | Disk usage and health diagnostics | 🔄 In progress |
| `runbook-06-mysql-backup-restore.md` | MySQL backup and restore procedures | 🔄 In progress |
| `runbook-07-mysql-replication-health.md` | MySQL replication health check | 🔄 In progress |
| `runbook-08-mysql-replication-io-errors.md` | MySQL replication I/O thread errors | 🔄 In progress |
| `runbook-09-mysql-replication-sql-errors.md` | MySQL replication SQL thread errors | 🔄 In progress |

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

See [`mysql/README.md`](mysql/README.md) for setup instructions and sample output.

## Lab Environment

- OS: Oracle Linux 9.8
- Platform: VirtualBox
- Topology: two VMs (Master + Replica), NAT and Bridge network adapters

## Skills Covered

- Linux system diagnostics
- Network troubleshooting (DNS, routing, iptables, subnetting)
- systemd service management
- MySQL administration: user privileges, backup, replication
- MySQL replication monitoring and recovery

---

## Certification

This repository supports my PortaOne Linux & Network Administration certification.

[View certificate (PDF)](certificates/portaone-lna-certificate.pdf)
