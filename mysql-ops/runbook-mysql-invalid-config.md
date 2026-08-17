# Runbook: MySQL Service Failure — Invalid Configuration Option

## Symptom

MySQL server does not start. The restart command returns an error immediately:

```
$ sudo systemctl restart mysqld

Job for mysqld.service failed because the control process exited with error code.
See "systemctl status mysqld.service" and "journalctl -xeu mysqld.service" for details.
```

`journalctl -xeu mysqld` is suggested by systemd but shows only generic explanations. For application-level errors, read the MySQL error log directly.

## Background

MySQL reads configuration from these files on Oracle Linux / RHEL:

- `/etc/my.cnf` — main configuration file. Do not edit directly.
- `/etc/my.cnf.d/mysql-server.cnf` — user-defined server settings. Edit this file.
- `/etc/my.cnf.d/` — directory for additional configuration files.

## Investigation

### Step 1 (Optional): Check the general error journal

Use this step if the failing service is unknown.

```
$ sudo journalctl -p err -n 50 --no-pager

Aug 17 11:14:33 server kernel: RETBleed: WARNING: Spectre v2 mitigation leaves CPU vulnerable to RETBleed attacks, data leaks possible!  
Aug 17 11:14:35 server kernel: [drm:vmw_host_printf [vmwgfx]] _ERROR_ Failed to send host log message.  
Aug 17 11:14:40 master kernel: SELinux: Runtime disable is deprecated, use selinux=0 on the kernel cmdline.  
Aug 17 12:05:44 master systemd[1]: Failed to start MySQL Server.
```

The first three lines are persistent warnings from the virtual machine environment — unrelated to MySQL. The last line identifies the failing service.

### Step 2: Check service status

```
$ sudo systemctl status mysqld

× mysqld.service - MySQL Server
...
     Active: failed (Result: exit-code) since ...
...
    Process: 1113 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
    Process: 1143 ExecStart=/usr/sbin/mysqld $MYSQLD_OPTS (code=exited, status=1/FAILURE)
   Main PID: 1143 (code=exited, status=1/FAILURE)
     Status: "Server shutdown complete"
      Error: 22 (Invalid argument)
...
Aug 17 12:05:42 master systemd[1]: Starting MySQL Server...
Aug 17 12:05:44 master systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Aug 17 12:05:44 master systemd[1]: mysqld.service: Failed with result 'exit-code'.
Aug 17 12:05:44 master systemd[1]: Failed to start MySQL Server.
Aug 17 12:05:44 master systemd[1]: mysqld.service: Consumed 1.063s CPU time, 731.0M memory peak.
```

`Error: 22 (Invalid argument)` 
`Error: 22` is a Linux system error code (EINVAL). It confirms that the process received an invalid input. The specific cause is not shown here — read the MySQL error log in Step 4.

### Step 3: Read the service journal 

```
$ sudo journalctl -u mysqld -n 50 --no-pager
...
Aug 17 12:05:42 master systemd[1]: Starting MySQL Server...
Aug 17 12:05:44 master systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Aug 17 12:05:44 master systemd[1]: mysqld.service: Failed with result 'exit-code'.
Aug 17 12:05:44 master systemd[1]: Failed to start MySQL Server.
...
```

The journal shows that the process exited with `status=1/FAILURE` but does not show the root cause. MySQL writes error details to its own log file, not to journald. Proceed to Step 4.

### Step 4: Read the MySQL error log

Look for the first [ERROR] entry — it contains the root cause:

```
$ sudo tail -n 30 /var/log/mysqld.log
...
2026-08-17T09:05:43.207709Z 0 [ERROR] [MY-000067] [Server] unknown variable 'invalid_option=yes'.
...
```

The root cause is `unknown variable 'invalid_option=yes`. MySQL does not recognise the option and aborts startup.

## Resolution

Open the configuration file where the invalid option was added:

```
sudo vi /etc/my.cnf.d/mysql-server.cnf
```

Remove the invalid line. Start the service:

```
$ sudo systemctl start mysqld
```

Verify:

```
$ sudo systemctl status mysqld

● mysqld.service - MySQL Server
...
Active: active (running) since ...
Main PID: 1287 (mysqld)
Status: "Server is operational"
...
Aug 17 12:19:33 master systemd[1]: Starting MySQL Server...
Aug 17 12:19:34 master systemd[1]: Started MySQL Server.
```

`Active: active (running)` confirms the service is running.

## Prevention

Run this command after every change to MySQL configuration files, before restarting the service.

```
$ sudo mysqld --validate-config

2026-08-17T10:34:10.542675Z 0 [Warning] [MY-010097] [Server] Insecure configuration for --secure-log-path: Current value does not restrict location of generated files. Consider setting it to a valid, non-empty path.
2026-08-17T10:34:10.546861Z 0 [ERROR] [MY-000067] [Server] unknown variable 'invalid_option=yes'.
2026-08-17T10:34:10.547090Z 0 [ERROR] [MY-010119] [Server] Aborting
```
