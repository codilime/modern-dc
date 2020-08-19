### Notes about leaf1 EVPN configuration.

Enable EVPN address family on iBGP session to the route reflector (spine1):
```
    group ibgp {
        type internal;
        local-address c0d1:ffff::1;
        family evpn {
            signaling;
        }
        multipath;
        neighbor c0d1:ffff::201;
    }
```

Configure interfeace ge-0/0/6 (connection to comp6) to be part of ae0 aggregated interface.  
Specify ESI and LACP configuration for ae0 (analogous settings are also configured on leaf2).

```
ge-0/0/6 {
    description comp6;
    speed 1g;
    gigether-options {
        no-auto-negotiation;
        802.3ad ae0;
    }
}
ae0 {
    flexible-vlan-tagging;
    native-vlan-id 20;
    mtu 9200;
    encapsulation flexible-ethernet-services;
    esi {
        00:00:00:00:00:00:04:00:00:00;
        all-active;
    }
    aggregated-ether-options {
        lacp {
            active;
            periodic fast;
            system-priority 128;
            system-id 00:00:00:00:00:04;
        }
    }
    unit 0 {
        encapsulation vlan-bridge;
        vlan-id 20;
    }
}
```

Configure IRB interface that will be used as default gateway for comp6. Note, that the IP and MAC address configured on IRB is the same as default gateway in VRF RED configured on leaf2 and comp servers. All of these devices can act as default gateway simultaneously.

```
irb {
    unit 10 {
        family inet {                   
            address 10.1.0.1/24;
        }
        mac 00:00:00:11:11:10;
    }
}
```

Create a routing instance for L2 communication and associate ae0 with it.

```
evpn_vni20 {
    protocols {
        evpn {
            interface ae0.0;
            encapsulation vxlan;
        }
    }
    vtep-source-interface lo0.0 inet;
    instance-type evpn;
    vlan-id none;
    routing-interface irb.10;
    vxlan {
        vni 20;
        ingress-node-replication;
    }
    interface ae0.0;
    vrf-target target:64512:20;
}
```

Create a routing instance for L3 communication and associate IRB interface with it.
```
evpn_vni10 {
    protocols {
        evpn {
            ip-prefix-routes {
                advertise direct-nexthop;
                encapsulation vxlan;
                vni 10;
            }
        }
    }
    vtep-source-interface lo0.0 inet;
    instance-type vrf;
    interface irb.10;
    vrf-target target:64512:10;
}
```

Configure composite next hops (Juniper-specific requirement):
```
forwarding-table {
    chained-composite-next-hop {
        ingress {
            evpn;
        }
    }
}
```
