# Documentation lab 7.4.3.5 - Configuring Basic EIGRP for IPv6

### Stap 1: 

Open Packet Tracer en maak de volgende opstelling: 

![](https://i.gyazo.com/46e1f4a942a9c49427c250d155ba2881.png)

### Stap 2 

Configureer de PC hosts met volgende ip-adressen: 

![](https://i.gyazo.com/9c23c49ad1563815c6c2cca11b457a63.png)


### Stap 3: Configureer de routers en pc's

Disable DNS lookup

	no ip domain-lookup


Configureer de routers hun poorten met volgende ip-adressen: 

![](https://i.gyazo.com/17b63d149e57f8c5e9a70b10affe1d9d.png)

Router R1:

	int g0/0
	ipv6 address 2001:DB8:ACAD:A::1/64
	ipv6 address FE80::1 link-local
	no shut

	int s0/0/0
	ipv6 add 2001:DB8:ACAD:12::1/64
	ipv6 address FE80::1 link-local
	clock rate 128000
	no shut
	
	int s0/0/1
	ipv6 add 2001:DB8:ACAD:13::1/64
	ipv6 address FE80::1 link-local
	no shut


Doe hetzelfde voor routers R2 en R3.

Configureer de device name:

	hostname R1

Instellen van console en vty paswoorden (cisco)

	line con 0
	password cisco
	login
	
	line vty 0 4
	password cisco
	login
	
Stel class in als privileged EXEC password

	enable secret class

Configureer logging synchronous

	line con 0
	no logging synchronous

	line vty 0 4
	no logging synchronous

Message of the day

	 banner motd #Welcome!#

Copy running config to startup config 

	copy running-config startup-config

Om te verifieren of alle connecties werken gebruiken we ping om naar de andere adressen te pingen.

### Stap 4: Configureer EIGRP Routing

Op R1 enable EIGRP number 1

	ipv6 router eigrp 1

Configureer de router-id 

R1:

	ipv6 router eigrp 1
	eigrp router-id 1.1.1.1
	no shutdown

R2:

	ipv6 router eigrp 1
	eigrp router-id 2.2.2.2
	no shutdown

R3:

	ipv6 router eigrp 1
	eigrp router-id 3.3.3.3
	no shutdown


Configure EIGRP for IPv6 using AS 1 on the Serial and Gigabit Ethernet interfaces on
the routers.

R1:

	interface g0/0
	ipv6 eigrp 1
	interface s0/0/0
	ipv6 eigrp 1
	interface s0/0/1
	ipv6 eigrp 1

Doe dit ook voor R2 en R3

**Vraag**

What address is used to indicate the neighbor in the adjacency messages?

The link-local address (FE80::x) of
the neighbor’s interface.

### Stap 5: Verify EIGRP voor IPv6

neighbor adjacencies

	show ipv6 eigrp neighbors

routing table

	show ipv6 route 

topology

	show ipv6 eigrp topology

**Vraag**

Compare the highlighted entries to the routing table. What can you conclude from the comparison?

The topology table lists all the available routes to a destination. The routing table lists the best path to a destination.

parameters en current state 
	
	show ipv6 protocols

### Stap 6: Configureer en verifieer passive interfaces

G0/0 als passive interface op R1 en R2

	ipv6 router eigrp 1
	passive-interface g0/0

Verifieer: 

	show ipv6 protocols

Configureer G0/0 als passive interface op R3 

Alle interfaces als passive op R3: 

	ipv6 router eigrp 1
	passive-interface default

**Vraag**

After you have issued the passive-interface default  command, R3 no longer participates in the routing process. What command can you use to verify it?

	show ipv6 route eigrp

What command can you use to display the passive interface on R3?

	show ipv6 protocols

Configureer de serial interfaces 

	ipv6 router eigrp 1
	no passive-interface s0/0/0
	no passive-interface s0/0/1

**Vraag**

The neighbor relationships have been established again with R1 and R2. Verify that only G0/0 has been configured as passive. What command do you use to verify the passive interface?

	show ipv6 protocols

**Reflection**

Where would you configure passive interfaces? Why?

Passive interfaces are usually configured on router interfaces that are not connected to other routers. Passive interfaces limit the amount of unnecessary protocol traffic in the network because no router devices are receiving the messages on the other side of the link.

What are some advantages with using EIGRP as the routing protocol in your network?

EIGRP routing protocol can be used with almost any size network using IPv4 or IPv6. It also uses less CPU than other dynamic routing protocols, such as OSPF. It requires little bandwidth for routing updates