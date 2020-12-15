
ip link add red type vrf table 10
ip l set red up

ip l set br-cameras master red
ip l add vxlan20 addrgenmode none type vxlan local 10.102.0.1 dstport 4789 vni 20 l2miss l3miss
ip l set up br-cameras
ip link set vxlan20 master br-cameras
ip l set vxlan20 up


ip link add green type vrf table 30
ip l set green up

ip l set br-users master green
ip l add vxlan40 addrgenmode none type vxlan local 10.102.0.1 dstport 4789 vni 40 l2miss l3miss
ip l set up br-users
ip link set vxlan40 master br-users
ip l set vxlan40 up

ip r add 0.0.0.0/0 via 10.2.0.1 vrf green
ip r add 0.0.0.0/0 via 10.1.0.1 vrf red

for link in `ip -br link | awk '{print $1}'`; do sysctl -w net.ipv4.conf.${link}.rp_filter=0; done;


wg-quick up wg0
