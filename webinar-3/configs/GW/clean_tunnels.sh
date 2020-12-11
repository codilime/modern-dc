#!/bin/bash

IFACE="eth0"
BR_VXLAN="vxlan-c100"

CONN_DB="/root/webinar.txt"

REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`

MAC=`cat /sys/class/net/$IFACE/address`

TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 

VPC_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-id`

#current IPs at VPC
#AWS_IP_LIVE=`aws --region us-east-2 ec2 describe-instances --filters Name=instance-state-name,Values=running Name=vpc-id,Values=$VPC_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text`

#registered IPs at VPC
AWS_IP_REGISTER=`aws --region us-east-2 ec2 describe-instances --filters Name=vpc-id,Values=$VPC_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text`


#current IPs at bridge
#BR_IP=`bridge fdb show dev $BR_VXLAN|grep 00:00:00:00:00:00|awk {'print $3'}`
BR_IP=`ip -d -j link show type geneve |jq -r ".[].linkinfo.info_data.remote"`

test -f $CONN_DB && rm $CONN_DB

for IP in $BR_IP; do 
#echo $IP
    if [[ ! $AWS_IP_REGISTER =~ ${IP} ]]; then
	#bridge fdb del 00:00:00:00:00:00 dev $BR_VXLAN dst $IP self permanent
	IF_GVE=`ip -d -j link show type geneve| jq -r ".[] | select(.linkinfo.info_data.remote == \"$IP\")| .ifname"`
	ip link del $IF_GVE
    else
	echo $IP >> $CONN_DB
    fi
done
