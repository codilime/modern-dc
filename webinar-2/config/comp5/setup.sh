#!/bin/bash

ip -4 rule add pref 32765 table local
ip -4 rule del pref 0

#VTEP_IP="c0d1::5"
VTEP_IP="10.0.0.5"


set_vrf () {

ip link add $VRF_NAME type vrf table $VRF_L3_ID
ip l set $VRF_NAME up

ip link add name veth-l$VRF_L3_ID address 00:00:00:00:00:11 arp off type veth peer name veth-$VRF_NAME  
ip l set veth-$VRF_NAME address 00:00:00:00:00:11 arp off
ip l set up veth-l$VRF_L3_ID
ip l set up veth-$VRF_NAME
ip l set veth-$VRF_NAME master $VRF_NAME

ip l add $VRF_NAME-l2 type bridge
ip l set $VRF_NAME-l2 master $VRF_NAME
ip l add vxlan$VRF_L2_ID addrgenmode none type vxlan local $VTEP_IP dstport 4789 vni $VRF_L2_ID nolearning l2miss l3miss 
ip l set up $VRF_NAME-l2
ip link set vxlan$VRF_L2_ID master $VRF_NAME-l2
ip l set vxlan$VRF_L2_ID up

ip l add $VRF_NAME-l3 type bridge
ip l set $VRF_NAME-l3 master $VRF_NAME
ip l add vxlan$VRF_L3_ID addrgenmode none type vxlan local $VTEP_IP dstport 4789 vni $VRF_L3_ID nolearning l2miss l3miss 
ip l set up $VRF_NAME-l3
ip link set vxlan$VRF_L3_ID master $VRF_NAME-l3
ip l set vxlan$VRF_L3_ID up

bridge link set dev vxlan$VRF_L3_ID hairpin on
#bridge link set dev vxlan$VRF_L2_ID hairpin on
}

#RED
VRF_L3_ID="10"
VRF_L2_ID="23"
VRF_NAME="red"

set_vrf

#GREEN
VRF_L3_ID="30"
VRF_L2_ID="43"
VRF_NAME="green"

set_vrf

#Loopback

ip l add k8s-api type dummy
ip l set k8s-api up
ip addr add 5.5.5.5/32 dev k8s-api


#local links
ip link set up ens4
ip link set up ens5


#disable rp_filter
for link in `ip -br link | awk '{print $1}'`; do sysctl -w net.ipv4.conf.${link}.rp_filter=0; done;

#change FORWARD policy
iptables -P FORWARD ACCEPT
