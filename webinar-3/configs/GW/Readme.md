
# Cloud init data

The following code should be applied to each VM instance as `user-data` during VM deployment. The IP in first line should be reflect the IP of Gateway with ZTP and FRR on board:

```
#cloud-config
bootcmd:
 - echo 172.31.46.68 > /tmp/gw.txt
 - ip link add vmc type geneve id 20 remote `cat /tmp/gw.txt`
 - ip link set up dev vmc address `cloud-init query --format "02:{{ instance_id[-10:-8] }}:{{ instance_id[-8:-6] }}:{{ instance_id[-6:-4] }}:{{ instance_id[-4:-2] }}:{{ instance_id[-2:] }}"`

runcmd:
 - curl -s http://`cat /tmp/gw.txt`:1701/cgi-bin/ztp.sh|bash
 ```
