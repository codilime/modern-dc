### Notes about spine1 EVPN configuration.


Spine1 acts as a route reflector for iBGP sessions from comp servers and leaf switches. It is not a VXLAN endpoint for any of the VNIs and does not have any routing instances configured.


Create iBGP configuration with route reflector functionality.
```
bgp {
    group ibgp {
        type internal;
        local-address c0d1:ffff::201;
        family evpn {
            signaling;
        }
        cluster 10.255.255.201;
        multipath;
        neighbor c0d1:ffff::1;
        neighbor c0d1:ffff::2;
        neighbor c0d1::1;               
        neighbor c0d1::2;
        neighbor c0d1::3;
        neighbor c0d1::4;
        neighbor c0d1::5;
    }
}

```
