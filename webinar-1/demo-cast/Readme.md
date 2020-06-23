# Demo steps
## SETUP

The purpose of this part is to emulate boot up process of BMS1 (by starting the frr server) as demonstrate how it affects whole topology.

Leaf1: 
`show bgp summary group servers`

Leaf2: 
`show ip bgp summary`

BMS1:
`ip route`

BMS1:
`grep neighbor /etc/frr/frr.conf`

BMS1:
`/etc/init.d/frr start`

Leaf1: 
`show bgp summary group servers`

Leaf1: 
`show route 10.0.1.1`

Leaf2: 
`show ip bgp summary`

Leaf2: 
`show bgp ipv4 unicast 10.0.1.1`

BMS1:
`ip route`

BMS2:
`ip route`


## COMMUNICATION

The purpose of this part is to show the HTTP communication between loopbacks of BMS1 and BMS2 (server). Traffic should be load balanced.

BMS1:
`ping 10.0.2.2`

BMS1:
`watch -n 1 curl -s http://10.0.2.2`

BMS2:
`tcpdump -ni enp2s0 port 80`

BMS2:
`tcpdump -ni enp3s0 port 80`


## LEGACY

The purpose of this part is to show the HTTP communication between the legacy BNS and BMS2 (server). Traffic will not be load balanced (to not saturate the uplinks as the legacy BMS is only connected to Leaf1).

legacy-BMS: 
`watch -n 1 curl -s http://10.0.2.2`

BMS2:
`tcpdump -ni enp2s0 port 80 and host 192.168.101.20`

BMS2:
`tcpdump -ni enp3s0 port 80 and host 192.168.101.20`

## FAILURE DETECTION:

The purpose of this part is to show fast BFD failover. Link used to communicate between BMS1 and legacy BMS will be shutdown, forcing packets to route via spine1 switch.

BMS1:
`ping -i 0.1 192.168.101.20`

BMS1:
`ip route get to 192.168.101.20`

BMS1:
`ip link set down enp2s0`

BMS1:
`ip route get to 192.168.101.20`

BMS1:
`ip link set up enp2s0`

BMS1:
`ip route get to 192.168.101.20`

## Extra LOAD BALANCE

The purpose of this part is to show Anycast load balance. Legacy BMS will be access share IP 192.168.0.250. HTTP request will be shared between BMS1 and BMS2

legacy-BMS: 
`watch -d -n 1 curl -s http://192.168.0.250`
