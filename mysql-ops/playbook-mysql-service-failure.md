# Playbook: MySQL Service Failure

Use this playbook when `mysqld` fails to start or stops unexpectedly.
All scenarios were reproduced on Oracle Linux 9.8.

## Quick Diagnosis

Check the error code in `sudo systemctl status mysqld`:

| Error code | Meaning | Go to |
|------------|---------|-------|
| Error: 22 (Invalid argument) | Bad option in configuration file | [runbook-mysql-invalid-config.md](runbook-mysql-invalid-config.md) |
| Error: 13 (Permission denied) | Wrong ownership or permissions | [runbook-mysql-wrong-ownership.md](runbook-mysql-wrong-ownership.md) |
| Error: 98 (Address already in use) | Port 3306 or unix socket conflict | [runbook-mysql-address-in-use.md](runbook-mysql-address-in-use.md) |
| No error code shown | Read MySQL error log | See below |

## If the error code is not visible

Read the MySQL error log directly:

```
$ sudo tail -n 30 /var/log/mysqld.log
```

Look for `[ERROR]` entries and match the symptom:

| Symptom in log | Go to |
|----------------|-------|
| `unknown variable` | [runbook-mysql-invalid-config.md](runbook-mysql-invalid-config.md) |
| `Permission denied` | [runbook-mysql-wrong-ownership.md](runbook-mysql-wrong-ownership.md) |
| `bind on TCP/IP port: Address already in use` | [runbook-mysql-address-in-use.md](runbook-mysql-address-in-use.md) |
| `Bind on unix socket: Address already in use` | [runbook-mysql-address-in-use.md](runbook-mysql-address-in-use.md) |
| `Out of memory` / `OOM killer` | [runbook-cpu-ram-diagnostics.md](../runbook-cpu-ram-diagnostics.md) |
| `No space left on device` | [runbook-disk-diagnostics.md](../runbook-disk-diagnostics.md) |

## Related Documents

- [runbook-mysql-invalid-config.md](runbook-mysql-invalid-config.md)
- [runbook-mysql-wrong-ownership.md](runbook-mysql-wrong-ownership.md)
- [runbook-mysql-address-in-use.md](runbook-mysql-address-in-use.md)
- [runbook-disk-diagnostics.md](../runbook-disk-diagnostics.md)
- [runbook-cpu-ram-diagnostics.md](../runbook-cpu-ram-diagnostics.md)