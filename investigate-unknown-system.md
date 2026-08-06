# Investigate an Unknown System

## Context

Use this procedure when you log into a system for the first time. You do not
know the current state, the configuration, or the history of this system. Use
this procedure before you start any troubleshooting or fix.

I built this procedure through practice. I diagnosed systems in an unknown
state many times, including systems with problems added on purpose. The order
of the steps is important. First, check who you are and what you can do on
this system. Second, check if you can trust the command output. Only after
that, check the real state of the system. If you skip to the state checks
too early, you may act on false information.

## Step 1 — Identity and Permissions

First, find out who you are on the system and what you can do.

```bash
whoami; id
sudo -l
cat /etc/os-release
```

- `whoami; id` — shows the current user, the user ID, group ID, and group
  membership.
- `sudo -l` — shows which commands you can run with `sudo`. On a limited
  system, this shows early what actions you can actually take.
- `cat /etc/os-release` — shows the Linux distribution and version. Command
  syntax and package managers can be different between systems (for example,
  `apt` on Debian/Ubuntu vs `dnf` on Oracle Linux/RHEL).

## Step 2 — Can You Trust the Command Output

Before you trust any command output, check if the shell itself is changed.

```bash
alias
type -a <command>
```

- `alias` — shows redefined commands. For example, many systems set
  `alias rm='rm -i'` by default. This alias asks for confirmation before it
  deletes a file. If this alias is missing or changed, `rm` can delete files
  without any warning. This is a small example, but it shows why you must
  check aliases first — you cannot trust that a command behaves the way you
  expect.
- `type -a <command>` — use this when a command's output looks strange. If
  the system has an alias, a shell function, a builtin, and a program with
  the same name, the shell does not use them at random. The shell checks
  them in this order: alias first, then function, then builtin, then
  program found in `$PATH`. The `type -a` command shows all of these
  matches, in this exact order. This finds a problem that `alias` alone
  cannot find: a fake program placed earlier in `$PATH` than the real one,
  with no alias involved at all.

## Step 3 — System State

Only after Step 1 and Step 2, check the real state of the system.

```bash
sudo systemctl --failed
sudo journalctl -p err -b --no-pager | tail -30
pstree -p
df -h
free -h
```

- `sudo systemctl --failed` — shows service units that are already in a
  failed state.
- `sudo journalctl -p err -b --no-pager | tail -30` — shows the newest
  error-level log entries from the current boot. `-p err` filters by
  priority, `-b` limits the output to the current boot.
- `pstree -p` — shows the process tree with process IDs (PIDs). This makes
  it easy to see strange parent-child process relationships.
- `df -h` / `free -h` — show disk space and memory usage in a readable
  format.

## Step 4 — Network Configuration

After you check the system itself, check its network setup. This tells you
how the system connects to other machines and to the internet.

```bash
ip a
ip r
ip n
cat /etc/resolv.conf
cat /etc/hosts
cat /etc/nsswitch.conf
ping -c2 8.8.8.8
ping -c2 google.com
ss -tulnp
```

- `ip a` — shows network interfaces and their IP addresses.
- `ip r` — shows the routing table. This tells you which interface and
  gateway the system uses to reach other networks.
- `ip n` — shows the neighbor table (ARP cache — a list of IP addresses and
  their matching MAC addresses on the local network).
- `cat /etc/resolv.conf` — shows which DNS servers the system uses to
  resolve names.
- `cat /etc/hosts` — shows static name-to-IP mappings set on this machine.
  These override DNS for the names listed here.
- `cat /etc/nsswitch.conf` — shows the order the system uses to resolve
  names (for example, check `/etc/hosts` first, then DNS).
- `ping -c2 8.8.8.8` — tests connectivity to the internet using a raw IP
  address, no DNS involved.
- `ping -c2 google.com` — tests connectivity and DNS resolution together.
  If this fails but the IP ping above works, the problem is DNS, not the
  network connection itself.
- `ss -tulnp` — shows which ports are listening and which process owns
  each one (`-t` TCP, `-u` UDP, `-l` listening, `-n` numeric, `-p` process).

## Output

Below is the real command output from this procedure, run on a training VM
(Oracle Linux 9, user `sysadmin`).

### Step 1 — Identity and Permissions

```bash
$ whoami; id
sysadmin
uid=1002(sysadmin) gid=1005(sysadmin) groups=1005(sysadmin)
```

```bash
$ sudo -l
User sysadmin may run the following commands on Replica:
    (ALL) NOPASSWD: ALL
```

Note: this account has full `sudo` access without a password. I keep this
in mind for later steps, when I decide how to fix any problem I find.

```bash
$ cat /etc/os-release
NAME="Oracle Linux Server"
VERSION="9.8"
ID="ol"
ID_LIKE="fedora"
PRETTY_NAME="Oracle Linux Server 9.8"
```

### Step 2 — Can You Trust the Command Output

```bash
$ alias
alias history='history -c'
```

Note: `history` is redefined to clear itself (`history -c`). So past
commands are hidden — normal history can't be trusted here.

```bash
$ type -a mysql
mysql is /usr/local/bin/mysql
mysql is /usr/bin/mysql
```

Note: `type -a` shows two `mysql` binaries. The one in `/usr/local/bin`
runs first (it's earlier in `$PATH`). It logs every call to
`/tmp/mysql_calls.log`, then runs the real `mysql`.

```bash
$ cat /usr/local/bin/mysql
#!/bin/bash
echo "$(date): mysql called with args: $@" >> /tmp/mysql_calls.log
/usr/bin/mysql "$@"
```

```bash
$ sudo tail -f /tmp/mysql_calls.log
Mon Aug  3 11:55:28 PM EEST 2026: mysql called with args: -u root -p
```

Note: the log shows the wrapper caught the call, including the flags used
(`-u root -p`). Note it only logs command-line flags, not SQL run inside
the interactive session after login.

### Step 3 — System State

```bash
$ sudo systemctl --failed
  UNIT LOAD ACTIVE SUB DESCRIPTION
0 loaded units listed.
```

Note: no failed units — clean.

```bash
$ sudo journalctl -p err -b --no-pager | tail -30
Aug 03 23:19:40 server kernel: RETBleed: WARNING: Spectre v2 mitigation leaves CPU vulnerable to RETBleed attacks, data leaks possible!
Aug 03 23:19:42 server kernel: [drm:vmw_host_printf [vmwgfx]] *ERROR* Failed to send host log message.
```

Note: At first these entries look concerning because of the words ERROR
and WARNING. I checked each message and found that none of them are an
active problem:

- The Spectre/RETBleed warning is a known CPU-level limitation common in
  virtualized environments, not something caused by system configuration.
- The `vmwgfx` error is a virtual display driver message, not relevant on
  a headless server.

(Output omitted — process tree on this training VM is too simple to be a
useful example; this step is more valuable on systems with real workload.)

```bash
$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                1.7G     0  1.7G   0% /dev/shm
tmpfs                692M  8.6M  684M   2% /run
/dev/mapper/ol-root   17G   11G  6.5G  62% /
/dev/sda1            960M  252M  709M  27% /boot
tmpfs                346M     0  346M   0% /run/user/1002
```

Note: root (`/`) has 6.5G free (62% used) — OK, no action needed.

```bash
$ free -h
      total        used        free      shared  buff/cache   available
Mem:  3.4Gi       1.0Gi       2.3Gi       8.0Mi       207Mi       2.3Gi
Swap: 2.0Gi          0B       2.0Gi
```

Note: RAM: I check `available` (2.3Gi), not `free`, because Linux can
release disk cache (`buff/cache`) to apps when needed.

### Step 4 — Network Configuration

Note: I run this from Replica — it connects to Master for replication.

```bash
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:d8:b2:40 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.14/24 brd 192.168.0.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::37c6:63d7:6590:bc4/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

Note: Replica's IP is 192.168.0.14 on `enp0s8`. Interface is UP.

```bash
$ ip r
default via 192.168.0.1 dev enp0s8 proto static metric 100
192.168.0.0/24 dev enp0s8 proto kernel scope link src 192.168.0.14 metric 100
```

Note: default route goes through 192.168.0.1 — this is the home router.

```bash
$ ip n
192.168.0.41 dev enp0s8 lladdr 08:00:27:66:1b:2f REACHABLE
192.168.0.1 dev enp0s8 lladdr b4:b0:24:d9:e5:40 STALE
```

Note: 192.168.0.41 is Master (see `/etc/hosts` below) — state REACHABLE,
so Replica already talked to it recently. 192.168.0.1 is the router,
state STALE (not used recently, but still a known address).

```bash
$ cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 192.168.0.1
```

Note: DNS requests go to the home router.

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.41 master
```

Note: `master` is mapped to 192.168.0.41 here, not by DNS. This name
works even if the home router's DNS has no record for it.

```bash
$ cat /etc/nsswitch.conf
hosts:      files dns myhostname
```

Note: name lookup order — `/etc/hosts` first, then DNS, then the local
hostname.

```bash
$ ping -c2 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=115 time=15.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=115 time=16.4 ms
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 15.241/15.808/16.375/0.567 ms
```

```bash
$ ping -c2 google.com
PING google.com (142.250.120.101) 56(84) bytes of data.
64 bytes from zo-in-f101.1e100.net (142.250.120.101): icmp_seq=1 ttl=111 time=14.9 ms
64 bytes from zo-in-f101.1e100.net (142.250.120.101): icmp_seq=2 ttl=111 time=15.4 ms
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 14.889/15.148/15.407/0.259 ms
```

Note: both pings work — network and DNS are both fine.

```bash
$ ss -tulnp
Netid State  Recv-Q Send-Q  Local Address:Port Peer Address:Port Process
udp   UNCONN 0      0       127.0.0.1:323       0.0.0.0:*
udp   UNCONN 0      0       [::1]:323           [::]:*
tcp   LISTEN 0      128     0.0.0.0:22          0.0.0.0:*
tcp   LISTEN 0      151     *:3306              *:*
tcp   LISTEN 0      128     [::]:22             [::]:*
tcp   LISTEN 0      70      *:33060             *:*
```

Note: port 22 (SSH) and 3306 (MySQL) are listening, as expected. Port
33060 is MySQL's X Protocol port, also normal for MySQL 8.
