# Demo steps

All demos are recorded using asciinema utility: <https://asciinema.org/>

## webinar2-1-vm.cast

The purpose of this part is to show libvirt integration w/ FRR and VRFs. Machines created using libvirt utilities are placed in VRFs and have isolated connectivity:

Comp1
`virsh net-list`

Comp1
`virsh list`

Comp1
`virsh domiflist --domain alpine-red`

Comp1
`virsh domiflist --domain alpine-green`

Comp1
`virsh console alpine-red`

Comp1 - VM alpine-red
`ip addr show eth0`

Comp1 - VM alpine-red
`ping  10.1.0.1`

Comp1
`virsh console alpine-green`

Comp1 - VM alpine-green
`ip addr show eth0`

Comp1 - VM alpine-green
`ping  10.2.0.1`

Comp1 - VM alpine-green
`ping 10.1.0.60`

Comp2
`ip neigh show vrf red | grep 10.1.0.60`

Comp2
`ip neigh show vrf green | grep 10.2.0.80`


## webinar2-2-lxc.cast

The purpose of this part is to show LXC integration w/ FRR and VRFs. Containers created using LXC utilities are placed in VRFs and have isolated connectivity:

Comp2
`lxc-ls`

Comp2
`lxc-create -q -n red -t alpine -f /etc/lxc/red.conf`

Comp2
`lxc-create -q -n green -t alpine -f /etc/lxc/green.conf`

Comp2
`lxc-start -n red`

Comp2
`lxc-start -n green`

Comp2
`lxc-ls`

Comp2
`lxc-attach red`

Comp2 - LXC red
`ip addr show eth0`

Comp2 - LXC red
`ping -c 3 10.2.0.80`

Comp2 - LXC red
`ping -c 3 10.1.0.60`

Comp1
`ip route show vrf red|grep 10.0.0.2`

Comp2
`lxc-attach green`

Comp2 - LXC green
`ip addr show eth0`

Comp2 - LXC green
`ping -c 3 10.1.0.60`

Comp2 - LXC green
`ping -c 3 10.2.0.80`

Comp1
`ip route show vrf green|grep 10.0.0.2`

## webinar2-3-k8s-1.cast

The purpose of this part is to show K8s integration w/ FRR and VRFs. PODs created using `kubectl` utility are placed in RED VRF and have isolated connectivity:

Comp3
`kubectl get pods -A -o wide`

Comp3
`kubectl get namespaces`

Comp3
`cat namespace-red.json`

Comp3
`kubectl apply -n red -f run-my-nginx.yaml`

Comp3
`kubectl get pods -A -o wide`

## webinar2-3-k8s-2.cast

The purpose of this part is to show K8s integration w/ FRR and VRFs. PODs created using `kubectl` utility are placed in GREEN VRF and have isolated connectivity:

Comp3
`kubectl apply -n green -f run-my-nginx.yaml`

Comp3
`kubectl get pods -A -o wide`

## webinar2-3-k8s-3.cast

The purpose of this part is to show K8s integration w/ FRR and VRFs. Services created using `kubectl` utility are are accessible only from corresponding VRFs while keeping redundancy and load balancing:

Comp3
`kubectl expose deployment/my-nginx -n red --cluster-ip=10.96.10.100`

Comp3
`kubectl expose deployment/my-nginx -n green --cluster-ip=10.96.30.100`

Comp2
`lxc-attach green`

Comp2
`wget -q -O - 10.96.30.100`
`wget -q -O - 10.96.30.100`
`wget -q -O - 10.96.30.100`

Comp2
`wget -q -O - 172.21.1.3`

Comp3
`stern -n green my-nginx`

## webinar2-6-bms.cast

The purpose of this part is to show legacy BMS without FRR integration with the rest of the topology. VRF red is terminated on Leaf1/2 and access to comp6 is provided using bonding interface:

Comp6
`ip address show bond0`

Comp6
`ping 10.1.0.60`

Comp6
`wget -T1 -O - -q 10.96.10.100`

Comp6
`ping -c 3 10.96.30.100`

Leaf1
`show evpn mac-ip-table`

Leaf1
`show route table evpn_vni10.evpn.0`

Leaf1
`show configuration routing-instances evpn_vni10`

Leaf2
`show arp vrf vni10`

Leaf2
`show ip route vrf vni10`

Leaf2
`show running-config interfaces port-Channel 1`

Leaf2
`show running-config interfaces vlan 20`

Leaf2
`show running-config section bgp`
