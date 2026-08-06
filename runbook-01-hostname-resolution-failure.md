# Incident Runbook: Host Cannot Resolve Hostnames

## Severity / Impact
- Medium. SSH and other tools that use hostnames stop working between hosts.
- Local resolution failure blocks admin access via hostname (e.g. `ssh master`).
- Global resolution failure blocks package updates, external repos, and internet access by domain name.

## Environment
- OS: Oracle Linux 9
- Hosts: Master (192.168.0.41), Replica
- Files involved: `/etc/hosts`, `/etc/resolv.conf`, `/etc/nsswitch.conf`

## Symptoms

**Case A — Local resolution failure**
```
$ ping master
ping: master: System error

$ ssh master
ssh: Could not resolve hostname master: Device or resource busy
```
Ping by IP address still works. Ping to external domains (`google.com`) still works.

**Case B — Global (DNS) resolution failure**
```
$ ping goo.gl.com
ping: goo.gl.com: System error

$ sudo dnf update
[MIRROR] 7zip-26.02-1.el9.x86_64.rpm: Curl error (6): Couldn't resolve host name for
https://yum.oracle.com/repo/OracleLinux/OL9/developer/EPEL/x86_64/getPackage/7zip-26.02-1.el9.x86_64.rpm
[Could not resolve host: yum.oracle.com]
[FAILED] 7zip-26.02-1.el9.x86_64.rpm: No more mirrors to try - All mirrors were already tried without success
```
Note: `dnf` does not fail immediately — it retries mirrors and hangs on each unresolved host before reporting failure.

Local hostname resolution (`ping master`) still works.

## Diagnosis Flow

1. Test resolution by IP address:
   ```
   ping -c 2 192.168.0.41
   ```
   If this works, the network layer is fine. The problem is name resolution.

2. Test global resolution:
   ```
   ping -c 2 google.com
   ```
   - Works → local resolution is the issue → go to **Case A**.
   - Fails → DNS is the issue → go to **Case B**.

### Case A: Check `/etc/hosts`
```
cat /etc/hosts
```
Look for a missing or malformed entry for the target host, for example:
```
192.168.0.41 master
```
If the line is missing, this is the root cause.

### Case B: Check `/etc/resolv.conf`
```
cat /etc/resolv.conf
```

A correct entry looks like this:
```
nameserver 8.8.8.8
```

Common root causes:
- No `nameserver` line present.
- Typo in the keyword `nameserver`.
- Wrong IP address after `nameserver`.
- More than 3 `nameserver` lines (the system reads only the first 3).
- File was overwritten by NetworkManager and lost the custom entry.

## Background

`/etc/nsswitch.conf` controls the resolution order. Its `hosts:` line typically looks like:
```
hosts: files dns
```
The system checks `/etc/hosts` first (**files**). If no match is found, it queries DNS (**dns**). Local and DNS resolution fail independently — fixing one does not fix the other.

## Root Cause
- **Case A:** missing or incorrect entry in `/etc/hosts`.
- **Case B:** missing, incorrect, or overwritten `nameserver` entry in `/etc/resolv.conf`.

## Resolution

**Case A — Fix `/etc/hosts`**
```
echo "192.168.0.41 master" | sudo tee -a /etc/hosts
```
Changes apply immediately, no service restart needed.

Verify:
```
ping -c 2 master
ssh master
```

**Case B — Fix `/etc/resolv.conf`**
```
echo "nameserver 192.168.0.1" | sudo tee -a /etc/resolv.conf
```
Verify:
```
ping -c 2 google.com
sudo dnf update
```

## Prevention / Notes
- After confirming the fix in Resolution works, make it persistent:
  ```
  sudo nmcli con mod <connection-name> ipv4.dns "192.168.0.1"
  sudo nmcli device reapply <device>
  ```
- Keep `/etc/hosts` entries the same on all cluster members (Master/Replica). Manual per-host edits can drift over time.
- The system reads only the first 3 `nameserver` lines in `/etc/resolv.conf`. This limit (`MAXNS`) is built into the glibc resolver.
