# Runbook: MySQL Service Failure — Address Already in Use (Error 98)

## Symptom

```
$ sudo systemctl start mysqld

Job for mysqld.service failed because the control process exited with error code.
See "systemctl status mysqld.service" and "journalctl -xeu mysqld.service" for details.
```

## Investigation

### Step 1 (Optional): Check the general error journal

Use this step if the failing service is unknown.

```
$ sudo journalctl -p err -n 50 --no-pager

Aug 17 16:04:16 master systemd[1]: Failed to start MySQL Server.
```

### Step 2: Check service status

```
$ sudo systemctl status mysqld

× mysqld.service - MySQL Server
Active: failed (Result: exit-code) since ...
Error: 98 (Address already in use)

Aug 17 16:04:13 master systemd[1]: Starting MySQL Server...
Aug 17 16:04:16 master systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Aug 17 16:04:16 master systemd[1]: mysqld.service: Failed with result 'exit-code'.
Aug 17 16:04:16 master systemd[1]: Failed to start MySQL Server.
```

`Error: 98 (Address already in use)` is a Linux system error code (EADDRINUSE).
The exact resource — TCP port 3306 or unix socket — will be identified in Step 4.

### Step 3: Read the service journal

```
$ sudo journalctl -u mysqld -n 50 --no-pager

Aug 17 16:04:13 master systemd[1]: Starting MySQL Server...
Aug 17 16:04:16 master systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Aug 17 16:04:16 master systemd[1]: mysqld.service: Failed with result 'exit-code'.
Aug 17 16:04:16 master systemd[1]: Failed to start MySQL Server.
```

The journal confirms the failure but does not show the root cause. Proceed to Step 4.

### Step 4: Read the MySQL error log

Look for the first `[ERROR]` entry — it contains the root cause. Subsequent `[ERROR]` entries indicate that the server is aborting, not the reason why.

```
$ sudo tail -n 30 /var/log/mysqld.log

...
2026-08-17T13:04:14.702827Z 0 [ERROR] [MY-010262] [Server] Can't start server: Bind on TCP/IP port: Address already in use
2026-08-17T13:04:14.702838Z 0 [ERROR] [MY-010257] [Server] Do you already have another mysqld server running on port: 3306 ?
2026-08-17T13:04:14.703145Z 0 [ERROR] [MY-010119] [Server] Aborting
...
```

If the log shows a unix socket conflict instead of a TCP port:

```
2026-08-17T13:59:30.284874Z 0 [ERROR] [MY-010270] [Server] Can't start server : Bind on unix socket: Address already in use
2026-08-17T13:59:30.284982Z 0 [ERROR] [MY-010258] [Server] Do you already have another mysqld server running on socket: /var/lib/mysql/mysql.sock ?
```

Proceed to [Resolution: Unix socket conflict](#resolution-unix-socket-conflict).

### Step 5: Identify the process on port 3306 (TCP conflict only)

```
$ ss -tulnp | grep 3306

tcp LISTEN 0 10 192.168.0.41:3306 0.0.0.0:* users:(("nc",pid=2563,fd=3))
```

Check which process is using port 3306 and get its full command:

```
$ ps aux | grep 2563

sysadmin 2563 0.0 0.0 12288 3352 pts/2 S+ 16:02 0:00 nc -kl 192.168.0.41 3306
```

The port is occupied by `nc` (netcat), PID 2563. This is not a legitimate service.

## Resolution

### Resolution: TCP port conflict

```
$ sudo kill 2563
$ sudo systemctl start mysqld
$ sudo systemctl status mysqld

● mysqld.service - MySQL Server
Active: active (running) since Mon 2026-08-17 16:14:39 EEST; 6s ago
Main PID: 5700 (mysqld)

Aug 17 16:14:37 master systemd[1]: Starting MySQL Server...
Aug 17 16:14:39 master systemd[1]: Started MySQL Server.
```

`Active: active (running)` confirms the service is running.

## Resolution: Unix socket conflict

```
$ sudo rm -rf /var/lib/mysql/mysql.sock
$ sudo systemctl start mysqld

● mysqld.service - MySQL Server
...
     Active: active (running) since Mon 2026-08-17 17:01:44 EEST; 5s ago
...
   Main PID: 15607 (mysqld)
     Status: "Server is operational"
...
Aug 17 17:01:43 master systemd[1]: Starting MySQL Server...
Aug 17 17:01:44 master systemd[1]: Started MySQL Server.
```

## Prevention

Check TCP port:
```
$ ss -tulnp | grep 3306
```
No output means port 3306 is free.

Check unix socket:
```
$ ls -la /var/lib/mysql/mysql.sock
```