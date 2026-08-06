# Network Diagnostic Cheatsheet

Use this document during active network troubleshooting.  
For first-look commands on an unknown system, see `investigate-unknown-system.md`.

---

## Block 1 — Interface & Routing

Run these first. They show the host's network configuration.

```bash
ip a
```
Check: interface is UP, has an IP address, correct subnet mask.

```bash
ip r
```
Check: default route exists, correct gateway IP.

```bash
ip n
```
Check: gateway is present in ARP table with status `REACHABLE` or `STALE`. Expected LAN hosts are visible.  
If a host is missing from the table, ping it first — ARP entries are populated on first contact.

---

## Block 2 — Reachability

Test connectivity step by step.

```bash
ping -c4 <gateway>
```
Check: local gateway is reachable. Use gateway IP from `ip r` output. If this fails — the problem is local (routing, subnet mask, ARP).  
See `runbook-02-subnet-mask-mismatch.md` for diagnosis of hosts on the same subnet that cannot reach each other.

> Note: runbook-02 uses specific lab hosts (Master / Replica) as examples. The diagnostic steps apply to any two hosts on the same subnet.

```bash
ping -c4 8.8.8.8
```
Check: network layer reachability without DNS. If gateway responds but this fails — problem is beyond the gateway or firewall.

```bash
ping -c4 <target-host>
```
Check: reachability to specific target.

```bash
traceroute -i <interface> <target-host>
traceroute -i <interface> -T -p <port> <target-host>
```
By default, `traceroute` sends UDP probes. Use `-T` to send TCP probes instead — more reliable when firewalls block UDP.  
Check: where the path stops. `* * *` on all hops after the gateway means the ISP (Internet Service Provider) blocks ICMP — this is normal. `* * *` starting from hop 1 means a local routing or firewall problem. If the path stops before the destination — the last responding hop is likely the blocking point.

Example output — successful path to 8.8.8.8:

```
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (192.168.0.1)  0.823 ms  0.828 ms  0.865 ms
 2  10.x.x.1.isp.net (10.x.x.1)  2.653 ms  2.621 ms  2.685 ms
 3  x.x.x.x  2.571 ms  2.561 ms  2.550 ms
 4  x.x.x.x  2.560 ms  2.627 ms  2.721 ms
 5  x.x.x.x  4.301 ms  4.288 ms  4.252 ms
 6  x.x.x.x  4.313 ms  2.687 ms  3.687 ms
 7  x.x.x.x  3.359 ms  3.440 ms  3.284 ms
 8  x.x.x.x  4.217 ms  4.204 ms  4.167 ms
 9  x.x.x.x  3.837 ms  3.229 ms  3.810 ms
10  x.x.x.x  17.371 ms  x.x.x.x  3.429 ms  x.x.x.x  16.626 ms
11  x.x.x.x  16.481 ms  x.x.x.x  16.468 ms  x.x.x.x  17.744 ms
12  x.x.x.x  16.526 ms  x.x.x.x  16.526 ms  x.x.x.x  16.507 ms
13  x.x.x.x  16.695 ms  dns.google (8.8.8.8)  15.715 ms  15.336 ms
```

---

## Block 3 — Services

### On this host:

```bash
ss -tulnp
```
Check: expected service is listening, on the correct port and listening address (`0.0.0.0` = all interfaces, or a specific IP).

### From another host:

```bash
nc -zv <target-host> <port>
```
Check: port is reachable. Use when IP and port are known.

```bash
traceroute -T -p <port> <target-host>
```
Check: at which hop the path stops. If it stops before the destination — the last responding hop is the blocking point.

```bash
nmap -Pn -p <port> <target-host>
```
Use when hosts or open ports are unknown.  
Example: find which host in LAN answers on port 53 (DNS server): `nmap -Pn -p 53 192.168.0.0/24`

---

## Block 4 — Firewall

Run when the service is listening but unreachable from another host.

```bash
sudo iptables -nvL --line-numbers
```
Check: DROP or REJECT rules with non-zero packet counters (`pkts` column) during the test.  

Example — REJECT rule with active counter:

```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1     202K  260M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2        0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
3       30  1680 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
4        2    88 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:3306
6     1047  229K REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
```

Rule 6: 1047 packets rejected. If this counter increments while you test connectivity — traffic is being blocked here.

```bash
sudo iptables -nvL -t nat --line-numbers
```
Relevant only on hosts that act as a router or NAT gateway.  
Check: MASQUERADE rule exists on the outgoing interface (required for internet access from LAN). DNAT rules are correct if port forwarding is configured.

---

## Block 5 — Name Resolution

If hostname resolution fails, see `runbook-01-hostname-resolution-failure.md`.

Files involved: `/etc/nsswitch.conf`, `/etc/hosts`, `/etc/resolv.conf`.
