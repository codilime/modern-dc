#!/usr/bin/python3

from jnpr.junos import Device
from jnpr.junos.utils.config import Config
from jnpr.junos.exception import ConfigLoadError, CommitError

from lxml import etree

from pprint import pprint

#Dictionary
#key: ipv6 address
#value: interface
bgp_neigh={}

#connect to QFX using SSH public key
#You can also remove password option if You have SSH key auth.
dev = Device(use_filter=True,host='192.168.1.1', user='admin', password='admin123')
dev.open()

#show ipv6 router-advertisement |display xml rpc 
rpc = dev.rpc.get_ipv6_ra_information()

#we are creating the list of interfaces w/ IPv6 RA received
ra_interfaces = rpc.findall('.//ipv6-ra-interface')


#for better understanding of thiis loop please look at the XML output of:
#show ipv6 router-advertisement |display xml 
for interface in ra_interfaces:
	int_name = interface.find('./interface-name').text
	ra_neighbors = interface.findall('./ipv6-ra-advertisement')
	for neighbor in ra_neighbors:
		neigh_ipv6=neighbor.find('./ipv6-source-address').text
		bgp_neigh[neigh_ipv6]=int_name

#we are blindly assuming that ephemeral config DB named ra-bgp-1 already exist
#for ephemeral confing in Juniper please see:
# https://www.juniper.net/documentation/en_US/junos/topics/concept/ephemeral-configuration-database-overview.html
cu = Config(dev, mode='ephemeral', ephemeral_instance='ra-bgp-1')


#for the simplicity of this script we are always removing all 
#BGP neighborrs in FRR group
cu.load("wildcard delete protocols bgp group FRR neighbor .*", format='set')

#for each discovered neighbour
for neighbor in bgp_neigh:
	#a simple failsafe - if inteface has any IPv4/v6 address configured we are skipping it
	rpc = dev.rpc.get_interface_information(terse=True,interface_name=bgp_neigh[neighbor])
	ipv6 = rpc.findall('.//interface-address')
	if len(ipv6) == 1:
		#in case of only one IP address (ipv6) we adding BGP neigh.
		cu.load("set protocols bgp group FRR neighbor "+neighbor+" local-interface "+bgp_neigh[neighbor], format='set')
		#print(neighbor, bgp_neigh[neighbor])

cu.commit()

dev.close()
