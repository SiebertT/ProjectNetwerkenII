# Documentation: Configuring MultiArea OSPFv2

----------

## Part 1: Build the Network and Configure Basic Device Settings

In Part 1, you will set up the network topology and configure basic settings on the routers.

###Step 1: Cable the network as shown in the topology.

![](https://i.gyazo.com/aaf9a40ee286d077d9ea40a8d0b176eb.png)

###Step 2: Initialize and reload the routers as necessary.

If there are issues, troubleshoot and reload the routers.

###Step 3: Configure basic settings for each router.

**enter privileged EXEC mode by typing `en` `conf t`**

a. Disable DNS lookup.

	no ip domain-lookup

b. Configure device name, as shown in the topology.

	hostname R1
	hostname R2
	hostname R3

c. Assign class as the privileged EXEC password.

	enable secret class

d. Assign cisco as the console and vty passwords.

	service password-encryption
	line con 0
	password cisco
	login

	line vty 0 15
	password cisco
	login

e. Configure logging synchronous for the console line.

	line con 0
	logging synchronous

f. Configure an MOTD banner to warn users that unauthorized access is prohibited.

	banner motd # Unauthorized access is prohibited! #

g. Configure the IP addresses listed in the Addressing Table for all interfaces. DCE interfaces should be
configured with a clock rate of 128000. Bandwidth should be set to 128 Kb/s on all serial interfaces.

![](https://i.gyazo.com/873f5ea68d7d7f1753d96d5cc7db204b.png)

For example:

    int lo0
    ip address 209.165.200.225 255.255.255.252

For Serials:

    int s0/0/0
    clock rate 128000
    bandwidth 128

h. Copy the running configuration to the startup configuration.

	copy running-config startup-config

### Step 4: Verify Layer 3 connectivity.
Use the `show ip interface brief` command to verify that the IP addressing is correct and that the interfaces
are active. Verify that each router can ping their neighbor’s serial interface.

## Part 2: Configure a Multiarea OSPFv2 Network

In Part 2, you will configure a multiarea OSPFv2 network with process ID of 1. All LAN loopback interfaces should be passive, and all serial interfaces should be configured with MD5 authentication using Cisco123 as the key.

###Step 1: Identify the OSPF router types in the topology.
- Identify the Backbone router(s):R1 and R2 
- Identify the Autonomous System Boundary Router(s) (ASBR): R1 
- Identify the Area Border Router(s) (ABR): R1 and R2 
- Identify the Internal router(s): R3

###Step 2: Configure OSPF on R1.
a. Configure a router ID of 1.1.1.1 with OSPF process ID of 1.

    R1(config)#router ospf 1
    R1(config-router)#router-id 1.1.1.1
 
b. Add the networks for R1 to OSPF.

    R1(config-router)#network 192.168.1.0 0.0.0.255 area 1
    R1(config-router)#network 192.168.2.0 0.0.0.255 area 1
    R1(config-router)#network 192.168.12.0 0.0.0.3 area 0
 
c. Set all LAN loopback interfaces, Lo1 and Lo2, as passive.

    R1(config-router)#passive-interface lo1
    R1(config-router)#passive-interface lo2
    R1(config-router)#exit
 
d. Create a default route to the Internet using exit interface Lo0.

    R1(config)#ip route 0.0.0.0 0.0.0.0 lo0


>You may see the notification:"
Default route without gateway, if not a point-to-point interface, may impact performance". This is normal behavior if using a Loopback interface to simulate a default route.
 
e. Configure OSPF to propagate the routes throughout the OSPF areas.

    R1(config)#router ospf 1
    R1(config-router)#default-information originate

###Step 3: Configure OSPF on R2.

a. Configure a router ID of 2.2.2.2 with OSPF process ID of 1.

    R2(config)# router ospf 1
    R2(config-router)# router-id 2.2.2.2

b. Add the networks for R2 to OSPF. Add the networks to the correct area. Write the commands used in the space below.  

    R2(config-router)# network 192.168.12.0 0.0.0.3 area 0
	R2(config-router)# network 192.168.23.0 0.0.0.3 area 3
	R2(config-router)# network 192.168.6.0 0.0.0.255 area 3
 
c. Set all LAN loopback interfaces as passive.

	R2(config-router)# passive-interface lo6

###Step 4: Configure OSPF on R3.
a. Configure a router ID of 3.3.3.3 with OSPF process ID of 1.

    R3(config)#router ospf 1
    R3(config-router)# router-id 3.3.3.3
 
b. Add the networks for R3 to OSPF. 
    
    R3(config-router)#network 192.168.23.0 0.0.0.3 area 3
    R3(config-router)#network 192.168.4.0 0.0.0.255 area 3
    R3(config-router)#network 192.168.5.0 0.0.0.255 area 3
 
c. Set all LAN loopback interfaces as passive.

    R3(config-router)#passive-interface lo4
    R3(config-router)#passive-interface l05
 
###Step 5: Verify that OSPF settings are correct and adjacencies have been established between routers.
a. Issue the `show ip protocols`
command to verify OSPF settings on each router. Use this command to identify the OSPF router types and to determine the networks assigned to each area.

R1 - ABR and ASBR

R2 - ABR 

R3 - No special OSPF router type

b. Issue the `show ip ospf neighbor` command to verify that OSPF adjacencies have been established between routers.


c. Issue the `show ip ospf interface brief` 
 command to display a summary of interface route costs
 
###Step 6: Configure MD5 authentication on all serial interfaces.
Configure OSPF MD5 authentication at the interface level with an authentication key of
Cisco123

    R1(config)#interface s0/0/0
    R1(config-if)#ip ospf message-digest-key 1 md5 Cisco123
    R1(config-if)#ip ospf authentication message-digest

    R2(config)#int s0/0/0
    R2(config-if)#ip ospf message-digest-key 1 md5 Cisco123
    R2(config-if)#ip ospf authentication message-digest
    R2(config-if)#interface s0/0/1
    R2(config-if)#ip ospf message-digest-key 1 md5 Cisco123
    R2(config-if)#ip ospf authentication message-digest

    R3(config)#interface s0/0/1
    R3(config-if)#ip ospf message-digest-key 1 md5 Cisco123
    R3(config-if)#ip ospf authentication message-digest

####Why is it a good idea to verify that OSPF is functioning correctly before configuring OSPF authentication?  

 Troubleshooting OSPF problems is much easier if OSPF adjacencies have been established and verified before implementing authentication. You then know that your authentication implementation is flawed, as adjacencies do not re-establish.

###Step 7: Verify OSPF adjacencies have been re-established.
Issue the `show ip ospf neighbor `
 command again to verify that adjacencies have been re-established after MD5 authentication was implemented. Troubleshoot any issues found before moving on to Part 3.

##Part 3: Configure Interarea Summary Routes
OSPF does not perform automatic summarization. Interarea summarization must be manually configured on  ABRs. In Part 3, you will apply interarea summary routes on the ABRs. Using
show
 commands, you will be able to observe how summarization affects the routing table and LSDBs.


###Step 1: Display the OSPF routing tables on all routers.
a. Issue the `show ip route ospf` command on R1. OSPF routes that originate from a different area have a descriptor (O IA) indicating that these are interarea routes.

b. Repeat the `show ip route ospf`
command for R2 and R3. Record the OSPF interarea routes for each router.

###Step 2: Display the LSDB on all routers.
a. Issue the `show ip ospf database`
 command on R1. A router maintains a separate LSDB for every area that it is a member.

b. Repeat the `show ip ospf database`
 command for R2 and R3. Record the Link IDs for the Summary Net Link States for each area.

###Step 3: Configure the interarea summary routes.
a. Calculate the summary route for the networks in area 1.
 
Networks 192.168.1.0 and 192.168.2.0 can be summarized as 192.168.0.0/22.

b. Configure the summary route for area 1 on R1.

    R1(config)#router ospf 1
    R1(config-router)#area 1 range 192.168.0.0 255.255.252.0

c. Calculate the summary route for the networks in area 3. Record your results.

Networks 192.168.4.0, 192.168.5.0, and 192.168.6.0 can be summarized as 192.168.4.0/22. 

d. Configure the summary route for area 3 on R2.

    R2(config)#router ospf 1
    R2(config-router)#area 3 range 192.168.4.0 255.255.252.0 

###Step 4: Re-display the OSPF routing tables on all routers.
Issue the `show ip route ospf `
 command on each router. Record the results for the summary and interarea routes

###Step 5: Display the LSDB on all routers.
Issue the `show ip ospf database`
 command again on each router. Record the Link IDs for the Summary Net Link States for each area.

####What type of LSA is injected into the backbone by the ABR when interarea summarization is enabled? 

A type-3 LSA or an interarea summary route

## Reflection
What are three advantages for designing a network with multiarea OSPF?  

1. Smaller routing tables. 
2. Reduced link-state update overhead. 
3. Reduced frequency of SPF calculations.