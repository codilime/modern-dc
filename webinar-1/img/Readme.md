# Topology description

This diagram presents the topology used during first webinar. You can see the following major elements here

## BMS1/2

Those are Bare Metal Servers with no IPv4 addresses assigned on physical interfaces. Both of them are equipped w/ FRR software allowing them to receive routes from network devices as well as advertising their own IP addresses. 

## Legacy BMS

This server is connected via primary uplink to the Leaf1 switch (192.168.101.20/24). It's purpose is to show that topology migration can be fluent and old services can access new ones without any issues

## Leaf1 & Leaf2

Juniper and Arista devices were used during the demo. Although we should be using vQFX here, unfortunately it does not support Jumbo Frames. However there are no major differences (w/ the exception of bridge) between QFX and MX. 

## Spine1

Juniper vMX was used here as well due to reasons mentioned above. We used hidden configuration knob to enable BGP add path capability over eBGP sessions so the both of the leafs are aware of full topology. 

