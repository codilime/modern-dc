
# Modern, interoperable data center

We’re excited to announce the series of webinars on the modern, interoperable data center.

## Part 1 - Solving last mile problems with BGP

This webinar will guide you through a solution for DC connectivity based on a combination of FRR, Unnumbered BGP (IPv4 with IPv6 link-local NH) and eBPF. This mix produces an automated discovery of bare metal and XaaS environments and can be run on any COTS as it uses only open-source and standardized features.

In this webinar, we will will explain:

1. The evolution of the data center and its impact on the last mile for operations
2. How to handle 1the growing number of devices and configurations needed
3. How to create a proper automated discovery in a data center using:

    - Unnumbered BGP (IPv4 with IPv6 link-local NH)
    - Free Range Routing
    - eBPF

4. The type of issues will you encounter and how to overcome them

All resources are placed in `webinar-1` directory.

## Part 2 - EVPN as a universal solution for VM, container and BMS networking

In this webinar we continue to enhance our DC with additional features made possible by open standards.

We will show how to leverage a BGP router running on servers to provide layer 2 connectivity between heterogeneous resources, such as virtual machines, containers, K8s services and bare-metal servers.

You will also learn about how k8s CNI (Container Network Interface) can be integrated with FRR in order to automatically advertise information about IPs and MACs of newly created PODs and ClusterIPs.

In this webinar, we will will explain:

1. What VXLAN tunnels are and how they carry layer 2 traffic
2. What an Ethernet VPN is and how it can be useful in DC
3. How to provide multi-tenancy through the use of VRFs and tunnelling protocols
4. How to interconnect VMs, containers, BMS and other resources through an IP fabric

Presentation also contains a demo showing how the solution works in practice.

All resources are placed in `webinar-2` directory.

## Part 3 - Seamless and secure connectivity for edge computing and hybrid clouds

In the third part we focus on connectivity with resources located beyond the local data center.

We will look at how we can connect on-prem services with those running in a public cloud, allowing for more flexibility and simplifying a number of migration scenarios. We will also show how it’s possible to securely extend Layer 2 and Layer 3 connectivity to IoT devices and Edge Computing servers located somewhere online. A similar concept can also be applied in communications with branch offices. We also show that inexpensive consumer routers can be successfully used for such scenarios.

In this webinar the speakers will explain:

1. How to connect resources in overlay with those in underlay and Internet
2. How to extend Layer 2 connectivity to public clouds
3. How to securely connect IoT devices and an Edge Computing server with a DC
4. What EVPN can do for your branch offices

Presentation also contains a demo showing how the solution works in practice.

All resources are placed in `webinar-3` directory.
