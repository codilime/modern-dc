#!/bin/bash


id=`echo $REMOTE_ADDR| awk -F'.' '{printf "%s-%s",$3,$4}'`
interface="gve-$id"
vni=20
bridge="red-l2"

sudo ip link del $interface &>/dev/null

sudo ip link add $interface type geneve vni $vni remote $REMOTE_ADDR
sudo ip link set $interface up
sudo ip link set $interface master $bridge

cat <<'KONIEC'
#!/bin/bash

iface=`ip -o -f inet addr show |grep "scope global"|head -n1  | awk {'print $2'}`
ip=`ip -o -f inet addr show |grep "scope global"|head -n1  | awk {'print $4'}`

. /etc/os-release

if [[ $ID_LIKE =~ "debian" ]]; then

cat > /tmp/60-vxlan-init.cfg <<CLOUD
network:
  version: 2
  ethernets:
    ${iface}:
      addresses:
        - $ip
    vmc:
      dhcp4: true
CLOUD

cloud-init devel net-convert -p /tmp/60-vxlan-init.cfg -k yaml -d / -D $ID -O netplan

netplan apply

elif [[ $ID =~ "amzn" ]]; then
ID="centos"

cat > /tmp/60-vxlan-init.cfg <<CLOUD
network:
  version: 2
  ethernets:
    ${iface}:
      addresses:
        - $ip
    vmc:
      dhcp4: true
CLOUD

cat > /etc/udev/rules.d/55-vmc-network-interfaces.rules <<'CLOUD'
#AMZN linux has no NetworkManager and bootinit phase is launched after network is brought up
ACTION=="add", SUBSYSTEM=="net", KERNEL=="vmc", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ec2net-ifup@$env{INTERFACE}"
ACTION=="remove", SUBSYSTEM=="net", KERNEL=="vmc", RUN+="/usr/sbin/ec2ifdown $env{INTERFACE}"
CLOUD

cloud-init devel net-convert -p /tmp/60-vxlan-init.cfg -k yaml -d / -D $ID -O sysconfig
sed -i s/STARTMODE=auto/STARTMODE=hotplug/ /etc/sysconfig/network-scripts/ifcfg-vmc 

ifup vmc

elif [[ $ID_LIKE =~ "suse" ]]; then

cat > /tmp/60-vxlan-init.cfg <<CLOUD
network:
  version: 2
  ethernets:
    ${iface}:
      addresses:
        - $ip
    vmc:
      dhcp4: true
CLOUD


ifup vmc


elif [[ $ID_LIKE =~ "fedora" ]]; then

cat > /tmp/60-vxlan-init.cfg <<CLOUD
network:
  version: 2
  ethernets:
    ${iface}:
      addresses:
        - $ip
CLOUD

cat >/etc/NetworkManager/conf.d/vmc.conf  <<CLOUD
[device]
match-device=interface-name:vmc
managed=1
CLOUD

cloud-init devel net-convert -p /tmp/60-vxlan-init.cfg -k yaml -d / -D $ID -O sysconfig
nmcli con del vmc
nmcli con add con-name vmc type generic ifname vmc ipv4.method auto connection.autoconnect yes
nmcli dev set vmc managed yes
nmcli con up vmc

ifdown ${iface}; ifup ${iface}

fi

KONIEC
