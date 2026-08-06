# Incident Runbook 02: Mismatched Subnet Mask

## Symptom

On Replica (172.16.5.214/25), ping to Master (172.16.5.41/24) returns 100% packet loss:
```
[sysadmin@replica ~]$ ping -c 2 172.16.5.41
PING 172.16.5.41 (172.16.5.41) 56(84) bytes of data.

--- 172.16.5.41 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1050ms
```

## Environment

- OS: Oracle Linux 9
- Host: Replica (172.16.5.214/25)
- Target: Master (172.16.5.41/24)
- Diagnostic interface: enp0s8 (Bridge adapter)
- Note: Replica has a second adapter enp0s3 (NAT) used for remote access only.

## Background

Replica and Master are in the same physical network segment, but they use different subnet masks.

Master uses /24. Its local subnet covers the full range 172.16.5.0–172.16.5.255. Master treats every host in this range as a direct neighbor reachable without a router.

Replica uses /25. Its local subnet covers only 172.16.5.128–172.16.5.255. Master's address (172.16.5.41) falls outside this range. Replica does not treat Master as a local neighbor.

This creates asymmetric behavior. Each host decides "is this a local neighbor" based on its own mask, not the mask of the other host.

**On Master — ARP request is sent, but no reply:**

```
[sysadmin@master ~]$ ip n
...
172.16.5.214 dev enp0s8 FAILED
```

Master's connected route (172.16.5.0/24) includes Replica's address. Master sends an ARP request on enp0s8 and gets no answer.

**On Replica — no ARP request is sent at all:**

```
[sysadmin@replica ~]$ sudo ip neigh flush dev enp0s8
```

```
[sysadmin@replica ~]$ ping -c 2 172.16.5.41
PING 172.16.5.41 (172.16.5.41) 56(84) bytes of data.
--- 172.16.5.41 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1050ms
```

```
[sysadmin@replica ~]$ ip n
10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:00 REACHABLE
fe80::2 dev enp0s3 lladdr 52:54:00:12:35:00 router STALE
```

Replica's connected route (172.16.5.128/25) does not include Master's address. Replica does not send any ARP request on enp0s8. Instead, it routes the packet through its default gateway on a different interface.

Both sides show the same result (100% packet loss), but the cause is different on each side.

## Diagnosis

Check the actual mask on the interface:

```
[sysadmin@replica ~]$ ip a
...
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:d8:b2:40 brd ff:ff:ff:ff:ff:ff
    inet 172.16.5.214/25 scope global enp0s8
```

Check the connected route:

```
[sysadmin@replica ~]$ ip r
...
172.16.5.128/25 dev enp0s8 proto kernel scope link src 172.16.5.214
```

The target address 172.16.5.41 is not part of this route.

Confirm which path the kernel will choose, before sending any traffic:

```
[sysadmin@replica ~]$ ip r get 172.16.5.41
172.16.5.41 via 10.0.2.2 dev enp0s3 src 10.0.2.15 uid 1002
    cache
```

The kernel selects the default route through enp0s3 (NAT), not the Bridge interface where Master is physically located.

Confirm the path is actually used:

```
[sysadmin@replica ~]$ traceroute 172.16.5.41
traceroute to 172.16.5.41 (172.16.5.41), 30 hops max, 60 byte packets
 1  _gateway (10.0.2.2)  0.200 ms  0.171 ms  0.153 ms
 2  * * *
 3  * * *
 4  * * *
```

The first hop is the NAT gateway. The packet never reaches the Bridge segment.

## Resolution

**Step 1 — Apply a temporary fix to test the change:**

Add the correct address without removing the existing one:

```
sudo ip addr add 172.16.5.214/24 dev enp0s8
```

Verify the connected route now includes Master's address:

```
[sysadmin@replica ~]$ ip r
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
default via 192.168.0.1 dev enp0s8 proto static metric 101
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
172.16.5.0/24 dev enp0s8 proto kernel scope link src 172.16.5.214
```

Verify the kernel now selects the Bridge interface:

```
[sysadmin@replica ~]$ ip route get 172.16.5.41
172.16.5.41 dev enp0s8 src 172.16.5.214 uid 1002
    cache
```

Verify connectivity:

```
[sysadmin@replica ~]$ ping -c 2 172.16.5.41
PING 172.16.5.41 (172.16.5.41) 56(84) bytes of data.
64 bytes from 172.16.5.41: icmp_seq=1 ttl=64 time=0.761 ms
64 bytes from 172.16.5.41: icmp_seq=2 ttl=64 time=0.338 ms

--- 172.16.5.41 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1018ms
rtt min/avg/max/mdev = 0.338/0.549/0.761/0.211 ms
```

**Step 2 — Make the change permanent:**

In nmcli edit, the set command adds to the existing value. Use print after set to confirm both addresses are present.

Removing the /25 address requires a separate check to confirm no other services depend on it, and is outside the scope of this runbook.

```
sudo nmcli con edit lan0
nmcli> set ipv4.addresses 172.16.5.214/24
nmcli> print
...
ipv4.addresses:   172.16.5.214/25, 172.16.5.214/24
...
nmcli> verify
nmcli> save
nmcli> activate
nmcli> quit
```
