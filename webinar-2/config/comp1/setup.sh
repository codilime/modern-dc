#!/bin/bash 

ip -4 rule add pref 32765 table local
ip -4 rule del pref 0

iptables -F
iptables -X

VTEP_IP="10.0.0.1"
#VTEP_IP="c0d1::1"

set_vrf () {


ip link add $VRF_NAME type vrf table $VRF_L3_ID
ip l set $VRF_NAME up

#libvirt should take care of those nets
#ip l add $VRF_NAME-l2 type bridge
ip l set $VRF_NAME-l2 master $VRF_NAME
ip l add vxlan$VRF_L2_ID addrgenmode none type vxlan local $VTEP_IP dstport 4789 vni $VRF_L2_ID nolearning l2miss l3miss 
ip l set up $VRF_NAME-l2
ip link set vxlan$VRF_L2_ID master $VRF_NAME-l2
ip l set vxlan$VRF_L2_ID up

ip l set add 00:00:00:11:11:$VRF_L3_ID dev $VRF_NAME-l2

ip l add $VRF_NAME-l3 type bridge
ip l set $VRF_NAME-l3 master $VRF_NAME
ip l add vxlan$VRF_L3_ID addrgenmode none type vxlan local $VTEP_IP dstport 4789 vni $VRF_L3_ID nolearning l2miss l3miss 
ip l set up $VRF_NAME-l3
ip link set vxlan$VRF_L3_ID master $VRF_NAME-l3
ip l set vxlan$VRF_L3_ID up

bridge link set dev vxlan$VRF_L3_ID hairpin on
#bridge link set dev vxlan$VRF_L2_ID hairpin on


ip l add $VRF_NAME-lo type dummy
ip l set $VRF_NAME-lo up
ip link set $VRF_NAME-lo master $VRF_NAME
}

#RED
VRF_L3_ID="10"
VRF_L2_ID="20"
VRF_NAME="red"

set_vrf
ip addr add 1.1.1.1/32 dev $VRF_NAME-lo


#RED
VRF_L3_ID="30"
VRF_L2_ID="40"
VRF_NAME="green"

set_vrf
ip addr add 1.1.1.2/32 dev $VRF_NAME-lo

#local links
ip link set up ens4
ip link set up ens5

#disable rp_filter
for link in `ip -br link | awk '{print $1}'`; do sysctl -w net.ipv4.conf.${link}.rp_filter=0; done;

#clear local iptables rules
iptables -F
iptables -X
iptables -F -t nat
iptables -X -t nat
