# linux-ops-runbooks

A collection of operational runbooks and diagnostic references for Linux systems.

These documents were created during hands-on lab practice: diagnosing systems in unknown state, including scenarios with deliberately introduced faults. The environment uses Oracle Linux 9.8 virtual machines in VirtualBox.

---

## Contents

| File | Description | Status |
|------|-------------|--------|
| [investigate-unknown-system.md](investigate-unknown-system.md) | First-response checklist: identity, trust, system state, network | ✅ Ready |
| [network-diagnostic-cheatsheet.md](network-diagnostic-cheatsheet.md) | Quick reference for network triage commands | ✅ Ready |
| [runbook-01-hostname-resolution-failure.md](runbook-01-hostname-resolution-failure.md) | Host cannot resolve hostnames | ✅ Ready |
| [runbook-02-mismatched-subnet-mask.md](runbook-02-mismatched-subnet-mask.md) | Host cannot reach neighbors due to subnet mask mismatch | ✅ Ready |
| runbook-03-service-management.md | systemd service diagnostics | 🔄 In progress |
| runbook-04-cpu-ram-diagnostics.md | CPU and memory diagnostics | 🔄 In progress |
| runbook-05-disk-diagnostics.md | Disk usage and health diagnostics | 🔄 In progress |
| runbook-06-mysql-backup-restore.md | MySQL backup and restore procedures | 🔄 In progress |
| runbook-07-mysql-replication-health.md | MySQL replication health check | 🔄 In progress |
| runbook-08-mysql-replication-io-errors.md | MySQL replication I/O thread errors | 🔄 In progress |
| runbook-09-mysql-replication-sql-errors.md | MySQL replication SQL thread errors | 🔄 In progress |

---

## Lab Environment

- OS: Oracle Linux 9.8
- Platform: VirtualBox
- Topology: two VMs (Master + Replica), NAT and Bridge network adapters

---

## Skills Covered

- Linux system diagnostics
- Network troubleshooting (DNS, routing, iptables, subnetting)
- systemd service management
- MySQL replication monitoring and recovery
