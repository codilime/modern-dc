# Demo steps

---

# Topology description

## SRX:

`show route`
`show ospf database external`

## Spine:

`show route table evpn_red_l3.inet.0`
`show route advertising-protocol bgp c0d1::1 table evpn_red_l3.evpn.0`

## Comp1:

`ip route list vrf red`
`virsh console alpine-red`
`ping 8.8.4.4`

## SRX:

`show security flow session destination-prefix 8.8.4.4/32`

# CLOUD service migration - VRRP

## LXC vrrp-red:

`/etc/init.d/keepalived start`
`ip addr show eth0`

## LXC red:

`watch curl http://10.1.0.20`

## AWS WEB cloud EC2:

`journalctl -fu keepalived`

## LXC vrrp-red:

`/etc/init.d/keepalived stop`

`/etc/init.d/keepalived start`

# CLOUD service migration - BGPaaS

## AWS WEB cloud EC2:

`systemctl stop gobgpd`

## LXC red:

`watch curl --connect-timeout 1 http://6.6.6.6`

## AWS WEB cloud EC2:

`systemctl start gobgpd`
`gobgp neigh`
`gobgp global rib add 6.6.6.6/32 -a ipv4`

# Access CLOUD native resources

## On local laptop:

`aws --output json rds describe-db-cluster-endpoints|jq . -r`

## LXC mysql-red:

`host database-1.cluster-cystd5ikxlps.us-east-2.rds.amazonaws.com`
`mysql -h database-1.cluster-cystd5ikxlps.us-east-2.rds.amazonaws.com -e "SELECT VERSION();"`

# Deploying Cloud EC2

## Comp1:

`tail -f /var/log/syslog|grep "dnsmasq-dhcp.*red-l2"`

## On local laptop:

`aws --output json ec2 describe-launch-templates|jq`
`aws ec2 describe-images --image-ids ami-03d64741867e7bb94`
`aws ec2 run-instances --image-id ami-03d64741867e7bb94 --launch-template LaunchTemplateId=lt-0aca9ce0081c852d4`

## LXC red:

`ssh -i webinar.key ec2-user@10.1.0.XX`
`nmcli con`
`ip route`

## On local laptop:

`aws ec2 terminate-instances --instance-ids XXXX`

# Branch office

## Openwrt:

`iw dev wlan0-1 station dump`
`cat /proc/cpuinfo`
`free`
`wg show`
`ip link`
`vtysh`
`show bgp summary`
`exit`

`ip address show br-users`
`ping -I green 8.8.4.4`
`ping -I green 8.8.8.8`

## SRX:

`show configuration security policies from-zone GREEN to-zone INTERNET`
`show security flow session destination-prefix 8.8.4.4/32`
`show security flow session destination-prefix 8.8.8.8/32`

# Branch office ONNVIF camera

## Openwrt:

`tcpdump -nni br-cameras host 239.255.255.250 or host 10.1.0.89`

## Comp6:

`onvif-device-tool`
`cvlc rtsp://admin:admin@10.1.0.89:10554/tcp/av0_1`

# Branch office - legacy

## AWS HUB EC2:

`vtysh`
`show bgp summary`
`show running-config`
`show ip route vrf red 10.22.33.1`

## Mikrotik:

`ip route vrf print`
`interface gre print`
`ip route print where routing-mark=vrf-red`
`ip address print where interface=vrf-red`

# IoT

## OrangePi:

`cat /proc/cpuinfo`
`ip route`
`wg show`
`vtysh`
`show bgp summary`
`exit`
`ip address show green-l2`
`ss -lpnnt`
`cat /etc/systemd/system/demo.service`

## Comp6:

`curl 10.2.103.1/temp`
`curl 10.2.103.1/value`

## SRX:

`show security flow session destination-prefix 10.2.103.1/32`

## Comp6:

`curl 10.2.103.1/bye`
