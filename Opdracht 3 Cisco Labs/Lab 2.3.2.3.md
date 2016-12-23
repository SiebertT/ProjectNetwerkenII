# Documentation: Configuring Rapid PVST+, PortFast and BPDU Guard

----------

## Part 1: Build the Network and Configure Basic Device Settings

In Part 1, you will set up the network topology and configure basic settings, such as the interface IP
addresses, device access, and passwords.

### Step 1: Cable the network as shown in the topology.

Connect the devices as shown below in the Topology.

### Step 2: Configure PC hosts.

Fill in the IP Adresses and Subnet Masks for PC-A and PC-C with the information from the Addressing Table.

![](https://i.gyazo.com/3392b6c9c8d9c141063b8877828bc9cc.png)

### Step 3: Initialize and reload the switches as necessary.

Normally this shouldn't be necessary. Otherwise initialize as required, write to memory with `copy running-config startup-config` and type `reload` in priviliged exec mode.

### Step 4: Configure basic settings for each switch.

**Enter privileged exec mode by typing**

	en
	conf t

a. Disable DNS lookup.

    no ip domain-lookup

b. Configure the device name as shown in the Topology.

	hostname S1
	banner motd # Unauthorized Access is prohibited! #

c. Assign cisco as the console and vty passwords and enable login.

	service password-encryption		
	line vty 0 15
	password cisco
	login
	exit
	line con 0
	password cisco
	login
	exit

d. Assign class as the encrypted privileged EXEC mode password.

	enable secret class

e. Configure logging synchronous to prevent console messages from interrupting command entry.

	line con 0
	logging synchronous
	exit

f. Shut down all switch ports.

	int range f0/1-24
	shutdown
	int ra g0/1-2
	shutdown

g. Copy the running configuration to startup configuration.
	
	copy running-config startup-config

## Part 2: Configure VLANs, Native VLAN, and Trunks

In Part 2, you will create VLANs, assign switch ports to VLANs, configure trunk ports, and change the native VLAN for all switches.

### Step 1: Create VLANs.

Use the appropriate commands to create VLANs 10 and 99 on all of the switches. Name VLAN 10 as User
and VLAN 99 as Management.

    S1(config)# vlan 10
    S1(config-vlan)# name User
    S1(config-vlan)# vlan 99
    S1(config-vlan)# name Management
    S2(config)# vlan 10
    S2(config-vlan)# name User
    S2(config-vlan)# vlan 99
    S2(config-vlan)# name Management
    S3(config)# vlan 10
    S3(config-vlan)# name User
    S3(config-vlan)# vlan 99
    S3(config-vlan)# name Management

### Step 2: Enable user ports in access mode and assign VLANs.

For S1 F0/6 and S3 F0/18, enable the ports, configure them as access ports, and assign them to VLAN 10.

### Step 3: Configure trunk ports and assign native vlan to 99

For ports F0/1 and F0/3 on all switches, enable the ports, configure them as trunk ports, and assign them to
native VLAN 99.

### Step 4: Configure the management interface on all switches

Using the Addressing Table, configure the management interface on all switches with the appropriate IP
address.

> Step 2, 3 and 4 are summarized in the commands for each Switch below.

#### S1

    S1(config)# interface f0/6
    S1(config-if)# no shutdown
    S1(config-if)# switchport mode access
    S1(config-if)# switchport access vlan 10
    S1(config-if)# interface f0/1
    S1(config-if)# no shutdown
    S1(config-if)# switchport mode trunk
    S1(config-if)# switchport trunk native vlan 99
    S1(config-if)# interface f0/3
    S1(config-if)# no shutdown
    S1(config-if)# switchport mode trunk
    S1(config-if)# switchport trunk native vlan 99
    S1(config-if)# interface vlan 99
    S1(config-if)# ip address 192.168.1.11 255.255.255.0
    S1(config-if)# exit

#### S2

    S2(config)# interface f0/1
    S2(config-if)# no shutdown
    S2(config-if)# switchport mode trunk
    S2(config-if)# switchport trunk native vlan 99
    S2(config-if)# interface f0/3
    S2(config-if)# no shutdown
    S2(config-if)# switchport mode trunk
    S2(config-if)# switchport trunk native vlan 99
    S2(config-if)# interface vlan 99
    S2(config-if)# ip address 192.168.1.12 255.255.255.0
    S2(config-if)# exit

#### S3

    S3(config)# interface f0/18
    S3(config-if)# no shutdown
    S3(config-if)# switchport mode access
    S3(config-if)# switchport access vlan 10
    S3(config-if)# interface f0/1
    S3(config-if)# no shutdown
    S3(config-if)# switchport mode trunk
    S3(config-if)# switchport trunk native vlan 99
    S3(config-if)# interface f0/3
    S3(config-if)# no shutdown
    S3(config-if)# switchport mode trunk
    S3(config-if)# switchport trunk native vlan 99
    S3(config-if)# interface vlan 99
    S3(config-if)# ip address 192.168.1.13 255.255.255.0
    S3(config-if)# exit

### Step 5: Verify Configurations and Connectivity

Use the `show interfaces trunk` command on all switches to verify trunk interfaces.

Use the `show running-config` command on all switches to verify all other configurations.

The default spanning-tree mode on Cisco Switches is PVST+.

Verify connectivity between PC-A and PC-C by pinging at eachother.

> Disabling the firewall may be required to get succesful pings

## Part 3: Configure the Root Bridge and Examine PVST+ Convergence

In Part 3, you will determine the default root in the network, assign the primary and secondary root, and use
the debug command to examine convergence of PVST+.

### Step 1: Determine the current root bridge

To see Spanning-Tree status of all VLANs on a switch, type 

	show spanning-tree

Write down the bridge priorities of each switch of VLAN 1

Write down which switch is the root bridge

> The root bridge was selected because it has the lowest bridge ID or BID.

### Step 2: Configure a primary and secondary root bridge for all existing VLANs

Having a root bridge (switch) elected by MAC address may lead to a suboptimal configuration. In this lab, you
will configure switch S2 as the root bridge and S1 as the secondary root bridge.

a. Configure switch S2 to be the primary root bridge for all existing VLANs. 

	S2(config)# spanning-tree vlan 1,10,99 root primary

b. Configure switch S1 to be the secondary root bridge for all existing VLANs. 

    S1(config)# spanning-tree vlan 1,10,99 root secondary

Write down the Bridge Priority of S1 for VLAN 1

Write down the Bridge Priority of S2 for VLAN 1

Write down which interface is in the blocking state

### Step 3: Change the Layer 2 topology and examine convergence.

To examine PVST+ convergence, you will create a Layer 2 topology change while using the debug command
to monitor spanning-tree events.

a. Enter the `debug spanning-tree events` command in privileged EXEC mode on switch S3.

    S3# debug spanning-tree events
    Spanning Tree event debugging is on

b. Create a topology change by disabling interface F0/1 on S3.

    S3(config)# interface f0/1
    S3(config-if)# shutdown

> Note: Before proceeding, use the debug output to verify that all VLANs on F0/3 have reached a
forwarding state then use the command no debug spanning-tree events to stop the debug output.

Each VLAN on F0/3 goes through the listening, learning and forwarding state respectively.

It took about 30 seconds to reach convergence, the timeformat of the timestamps is hh.mm.ss:msec

## Part 4: Configure Rapid PVST+, PortFast, BPDU Guard, and Examine Convergence

In Part 4, you will configure Rapid PVST+ on all switches. You will configure PortFast and BPDU guard on all
access ports, and then use the debug command to examine Rapid PVST+ convergence.

### Step 1: Configure Rapid PVST+.

a. Configure S1 for Rapid PVST+. 

	S1(config)# spanning-tree mode rapid-pvst

b. Configure S2 and S3 for Rapid PVST+.

	S2(config)# spanning-tree mode rapid-pvst

	S3(config)# spanning-tree mode rapid-pvst

c. Verify configurations with the `show running-config | include spanning-tree mode` command.

    S1# show running-config | include spanning-tree mode
    spanning-tree mode rapid-pvst

    S2# show running-config | include spanning-tree mode
    spanning-tree mode rapid-pvst

    S3# show running-config | include spanning-tree mode
    spanning-tree mode rapid-pvst

### Step 2: Configure PortFast and BPDU Guard on access ports.

PortFast is a feature of spanning tree that transitions a port immediately to a forwarding state as soon as it is
turned on. This is useful in connecting hosts so that they can start communicating on the VLAN instantly,
rather than waiting on spanning tree. To prevent ports that are configured with PortFast from forwarding
BPDUs, which could change the spanning tree topology, BPDU guard can be enabled. At the receipt of a
BPDU, BPDU guard disables a port configured with PortFast.

a. Configure interface F0/6 on S1 with PortFast. 

	S1(config)# interface f0/6
	S1(config-if)# spanning-tree portfast

b. Configure interface F0/6 on S1 with BPDU guard. 

	S1(config-if)# spanning-tree bpduguard enable

c. Globally configure all non-trunking ports on switch S3 with PortFast. Write 

    S3(config)# interface f0/18
    S3(config-if)# spanning-tree portfast


d. Globally configure all non-trunking PortFast ports on switch S3 with BPDU guard. 

	S3(config)# interface f0/18
    S3(config-if)# spanning-tree bpduguard enable

### Step 3: Examine Rapid PVST+ convergence

a. Enter debugging mode like before

b. Enable interface f0/1 on switch S3 to create a topology change

Check the time it took to reach convergence by checking the timestamps.

## Reflection

### What is the main benefit of using Rapid PVST+?

Rapid PVST+ decreases the time of Layer 2 convergence significantly over PVST+

### How does configuring a port with PortFast allow for faster convergence?

PortFast allows for an access port to immediately transition into a forwarding state which decreases Layer 2 convergence time.

### What protection does BPDU guard provide?

BPDU guard protects the STP domain by disabling access ports that receive a BPDU. BPDUs can be used in a denial of service attack that
changes a domain’s root bridge and forces an STP recalculation.

11/7/2016 1:39:10 PM By SiebertT