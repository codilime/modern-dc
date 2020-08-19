### Notes about leaf2 EVPN configuration.


Configure interface Ethernet7 (connection to comp6) to be part of Port-Channel1 aggregated interface.  
Specify ESI and LACP configuration for Port-Channel1 (analogous settings are also configured on leaf1).

```
interface Ethernet7
   description comp6
   mtu 9214
   speed forced 1000full
   no switchport
   channel-group 1 mode active
   lacp timer fast

interface Port-Channel1
   mtu 9000
   switchport access vlan 20
   !
   evpn ethernet-segment
      identifier 0000:0000:0000:0400:0000
      route-target import 00:00:00:00:00:04
   lacp system-id 0000.0000.0004

```



Configure IRB interface that will be used as default gateway for comp6 and associate it with VRF `vni10` (which is VRF RED). Note, that the IP and MAC address configured on this interface is the same as default gateway in VRF RED configured on leaf1 and comp servers. All of these devices can act as default gateway simultaneously.

```
vrf instance vni10

interface Vlan20
   vrf vni10
   ip address 10.1.0.1/24
   mac address virtual-router

ip virtual-router mac-address 00:00:00:11:11:10

```


Associate VLAN20 and VRF RED with VNI numbers.
```
interface Vxlan1
   vxlan vlan 20 vni 20
   vxlan vrf vni10 vni 10
```


For BGP configure iBGP session with EVPN address family and enable advertisements for VLAN 20 (Layer 2 communication) and for VRF RED (Layer 3 communication).
```
   neighbor ibgp peer group
   neighbor ibgp remote-as 64512
   neighbor ibgp update-source Loopback0
   neighbor c0d1:ffff::201 peer group ibgp
   address-family evpn
      neighbor ibgp activate

   vlan 20
      rd 10.255.255.2:20
      route-target both 64512:20
      redistribute learned

   vrf vni10
      rd 10.255.255.2:10
      route-target import evpn 64512:10
      route-target export evpn 64512:10
      redistribute connected
      redistribute attached-host
```

