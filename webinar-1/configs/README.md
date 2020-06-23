Here you can find partial configuration files from networking devices leaf1, leaf2 and spine1, as well as FRR configuration from BMS1 and BMS2. The file show the statements that are relevant to topics mentioned during the webinar (some other parts were omitted so the configs are less cluttered).  
Below is a short description of a reasoning behind using some of the commands that you'll find in the configs.  

### FRR on BMS
Configuration of IPv4 and IPv6 address set on a loopback interface. These addresses will be reachable from other devices in the network as long as at least one connection from server to switches still exist. Note that these are host addresses (/32 prefix).  
The `192.168.0.250` address is an anycast address (this same address is set on both BMS1 and BMS2).
```
interface lo
 ip address 10.0.1.1/32
 ip address 192.168.0.250/32
 ipv6 address c0d1::1/128
 ```
 
 BGP configuration that allows to automatically establish a BGP session to a neighbor using link-local IPv6 addresses.  
 ```
 neighbor fabric remote-as external
 neighbor enp2s0 interface peer-group fabric
 neighbor enp3s0 interface peer-group fabric
 ```
Enable advertisements of IPv4 prefixes with IPv6 next-hops:
```
neighbor fabric capability extended-nexthop
```
Make sure ECMP can be used for paths going through different ASs and enable fast failover with help of BFD:
```
bgp bestpath as-path multipath-relax
neighbor fabric bfd
```
All servers in this architecture share the same AS number. In order for FRR to accept eBGP routes with ASPATH already containing it's AS we set the `allowas-in` option.
```
neighbor fabric allowas-in
```
Route maps are configured so the servers will automatically advertise IPv4 and IPv6 addresses configured on the `lo` interface. While FRR advertises these prefixes correctly there is a bug on Juniper devices (should be fixed in coming Junos versions) that prevents them from accepting IPv4 prefixes with IPv6 next hops when BGP session is established using link-local addresses. In order to workaround this problem we use the `set ip next-hop 0.0.0.1` command, which changes the way those IPv4 prefixes are advertised by FRR and Juniper devices are able to accept them.  
```
route-map bgp_underlay_export permit 10
 match interface lo
 match ip address prefix-len 32
 set ip next-hop 0.0.0.1
```


### Leaf1 (Juniper)

In order to periodically advertise information about configured IPv6 addresses we enable router advertisements on appropriate interfaces:
```
root@leaf1> show configuration protocols router-advertisement
interface ge-0/0/1.0 {
    max-advertisement-interval 30;
}
interface ge-0/0/2.0 {
    max-advertisement-interval 30;
}
```

Enable advertisements of IPv4 prefixes with IPv6 next-hops in BGP configuration:
```
    family inet {
        unicast {
            extended-nexthop;
        }
    }
```

To enable ECMP we use the `multipath` configuration option for BGP and also enable load balancing globally by applying appropriate routing policy to forwarding table:
```
policy-statement ft-export {
    term load-balance {
        then {
            load-balance per-packet;
        }
    }
}
[...]
forwarding-table {
    export ft-export;
    ecmp-fast-reroute;
}
```

Prefixes from servers will be received directly from them, but also through a longer path through the spine1 device. In order to put this longer path in the routing table (so it is ready to use in case of some failure) we use the `add-path` option:
```
    family inet {
        unicast {
            add-path {
                receive;
            }
            extended-nexthop;
        }
    }
```

Finally, because we are using the same AS number on each server we need to make sure the switches will accept and forward prefixes with duplicated AS numbers. We do it by using the `advertise-peer-as` option in BGP configuration and also by enabling AS loops in BGP routes:
```
autonomous-system 64512 loops 2
```

### Leaf2 (Arista)

In order to periodically advertise information about configured IPv6 addresses we enable router advertisements on appropriate interfaces:
```
interface Ethernet2
   [...]
   ipv6 enable
   ipv6 nd ra interval msec 30000
!
interface Ethernet3
   [...]
   ipv6 enable
   ipv6 nd ra interval msec 30000
```

Enable advertisments of IPv4 prefixes with IPv6 next-hops in BGP configuration:
```
    bgp default ipv4-unicast transport ipv6
[...]
   address-family ipv4
      neighbor servers next-hop address-family ipv6 originate
      neighbor spines next-hop address-family ipv6 originate
```

To enable load balancing for equal cost routes we set `maximum-paths 8` in the BGP configuration.  
  
Prefixes from servers will be received directly from them, but also through a longer path through the spine1 device. In order to put this longer path in the routing table (so it is ready to use in case of some failure) we use the `bgp additional-paths receive` option.  
  
Finally, because we are using the same AS number on each server we need to make sure the switches will accept and forward prefixes with duplicated AS numbers:
```
 neighbor servers allowas-in 3
 neighbor spines allowas-in 3
```

### Spine1 (Juniper)
Enable BGP protocol to advertise prefixes even if they are not currently active in the routing table (they are not the best path to the destination):
```
            add-path {
                receive;
                send {
                    path-selection-mode {
                        all-paths;
                    }
                    path-count 3;
                    allow-ebgp;
                }
            }
```

Generate and advertise the default route:
```
routing-options {
    rib inet6.0 {
        aggregate {
            route ::/0;
        }
    }
    aggregate {
        route 0.0.0.0/0 policy gen-default4;
    }
}
[...]
policy-statement bgp-underlay-export {
    term default4 {
        from {
            protocol aggregate;
            route-filter 0.0.0.0/0 exact;
        }
        then accept;
    }
    term default6 {
        from {
            protocol aggregate;
            route-filter ::/0 exact;
        }
        then accept;
    }
}
[...]
protocols {
    bgp {
        group leafs {
         export bgp-underlay-export;
        }
    }
}
```
