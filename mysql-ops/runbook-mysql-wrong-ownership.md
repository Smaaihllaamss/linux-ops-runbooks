# Runbook: MySQL Service Failure — Wrong ownership on datadir

## Symptom

MySQL server does not start. The restart command returns an error immediately:

```
$ sudo systemctl restart mysqld

Job for mysqld.service failed because the control process exited with error code.  
See "systemctl status mysqld.service" and "journalctl -xeu mysqld.service" for details.
```

## Background

MySQL runs as the `mysql` system user. The data directory must be owned by `mysql:mysql`. The default path is `/var/lib/mysql`. To check if a custom path is configured:

```
$ grep datadir /etc/my.cnf /etc/my.cnf.d/*.cnf
```

Wrong ownership typically occurs after restoring a backup with a tool like Percona XtraBackup, which may restore files as `root`.

## Investigation

### Step 1 (Optional): Check the general error journal

Use this step if the failing service is unknown.

```
$ sudo journalctl -p err -n 50 --no-pager

Aug 17 14:16:42 master systemd[1]: Failed to start MySQL Server.
```

### Step 2: Check service status

```
$ sudo systemctl status mysqld

× mysqld.service - MySQL Server
     Active: failed (Result: exit-code) since Mon 2026-08-17 14:16:42 EEST; 14s ago
      Error: 13 (Permission denied)

Aug 17 14:16:42 master systemd[1]: Failed to start MySQL Server.
```

`Error: 13` is a Linux system error code (EACCES — Permission denied). Unlike Scenario 1, the error type is already visible at this step.

### Step 3: Read the service journal

```
$ sudo journalctl -u mysqld -n 50 --no-pager

Aug 17 14:16:41 master systemd[1]: Starting MySQL Server...
Aug 17 14:16:42 master systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Aug 17 14:16:42 master systemd[1]: mysqld.service: Failed with result 'exit-code'.
Aug 17 14:16:42 master systemd[1]: Failed to start MySQL Server.
```

The journal confirms the failure but does not show the root cause. Proceed to Step 4.

### Step 4: Read the MySQL error log

Look for `[ERROR]` and `Permission denied` entries.

```
$ sudo tail -n 30 /var/log/mysqld.log
...
2026-08-17T11:16:42.002747Z 0 [Warning] [MY-010091] [Server] Can't create test file /var/lib/mysql/mysqld_tmp_file_case_insensitive_test.lower-test
mysqld: File './binlog.index' not found (OS errno 13 - Permission denied)
2026-08-17T11:16:42.005180Z 0 [ERROR] [MY-010119] [Server] Aborting
...
```

MySQL cannot write to `/var/lib/mysql`. Check the ownership:

```
$ ls -ld /var/lib/mysql

drwxr-xr-x 15 root root 4096 Aug 17 14:11 /var/lib/mysql
```

The directory is owned by `root`, not `mysql`.

## Resolution

Restore the correct ownership and start the service:

```
$ sudo chown -R mysql:mysql /var/lib/mysql
$ sudo systemctl start mysqld
$ sudo systemctl status mysqld

● mysqld.service - MySQL Server
     Active: active (running) since Mon 2026-08-17 14:19:43 EEST; 3s ago
   Main PID: 1808 (mysqld)

Aug 17 14:19:42 master systemd[1]: Starting MySQL Server...
Aug 17 14:19:43 master systemd[1]: Started MySQL Server.
```

`Active: active (running)` confirms the service is running.

## Prevention

After restoring a backup, always verify ownership before starting the service:

```
$ ls -ld /var/lib/mysql

drwxr-xr-x 15 mysql mysql 4096 Aug 17 14:11 /var/lib/mysql
```

Expected: directory owned by `mysql:mysql`.