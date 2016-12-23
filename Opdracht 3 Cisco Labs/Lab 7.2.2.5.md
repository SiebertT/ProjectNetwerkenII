# Documentation lab 7.2.2.5 - Configuring Basic EIGRP for IPv4

### Stap 1: 

Open Packet Tracer en maak de volgende opstelling: 

![](https://i.gyazo.com/46e1f4a942a9c49427c250d155ba2881.png)

### Stap 2 

Configureer de PC hosts met volgende ip-adressen: 

![](https://i.gyazo.com/d995ffbfdde7ad6cddf79218b49e1984.png)


### Stap 3: Configureer de routers en pc's

Disable DNS lookup

	no ip domain-lookup


Configureer de routers hun poorten met volgende ip-adressen: 

![](https://i.gyazo.com/aed15d47ca80fcbe13f45fde8b9f8f2b.png)

Router R1:

	int g0/0
	ip add 192.168.1.1 255.255.255.0
	no shut

	int s0/0/0
	ip add 10.1.1.1 255.255.255.252
	clock rate 128000
	no shut
	
	int s0/0/1
	ip add 10.3.3.1 255.255.255.252
	clock rate 128000
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

Op R1 enable EIGRP number 10

	router eigrp 10

Advertise de direct geconnecteerde netwerken op R1 met wildcard mask

	network 10.1.1.0 0.0.0.3
	network 192.168.1.0 0.0.0.255
	network 10.3.3.0 0.0.0.3

Doe dit ook voor R2 en R3

**Vraag:** 
Why is it a good practice to use wildcard masks when advertising networks? Could the mask have been omitted from any of the network statements above? If so, which one(s)?

You should only advertise networks that you control. In earlier versions of EIGRP, classful boundaries were assumed meaning that the whole network space was advertised. For example, when advertising the 10.1.1.0 network, the 10.0.0.0/8 could be assumed. The wildcard mask could have been omitted from the 192.168.1.0 network statement because EIGRP would automatically assume the 0.0.0.255 classful mask.


### Stap 5: Verify EIGRP Routing

Bekijk de EIGRP neighbor table

	show ip eigrp neighbor

**Vraag**
Why does R1 have two paths to the 10.2.2.0/30 network?

EIGRP automatically does equal-cost load balancing. R1 has two ways to reach the 10.2.2.0/30 network

Bekijk de EIGRP topology table

	show ip eigrp topology

**Vraag**
Why are there no feasible successors listed in the R1 topology table?

The feasibility condition (FC) has not been met

Verifieer de EIGRP routing parameters en networks advertised

	show ip protocols

**Vraag**
What AS number is used?  10
What networks are advertised? 10.1.1.0/30, and 192.168.1.0/24
What is the administrative distance for EIGRP?  90 internal and 170 external
How many equal cost paths does EIGRP use by default?  4


### Stap 6: Configureer bandwidth en passive interfaces

Observeer de routing settings

	show interface s0/0/0

**Vraag**
What is the default bandwidth for this serial interface?

Answers will vary based on serial card in router. Based on output here, bandwidth is 1544 Kbps.

How many routes are listed in the routing table to reach the 10.2.2.0/30 network? 2

Modify de bandwidth on the routers: 

	interface s0/0/0 
	bandwidth 2000
	interface s0/0/1
	bandwidth 64

**Vraag**
Issue show ip route command on R1. Is there a difference in the routing table? If so, what is it?

After the change in bandwidth, there is only one route showing for the 10.2.2.0/30 network via 10.1.1.2 and S0/0/0. This is the preferred link because it is a faster link. Before the change in bandwidth, there were two equal cost paths to the destination; therefore, there were two entries in the routing table.

Modify the bandwidth on the R2 and R3 serial interfaces.
	
R2
	interface s0/0/0 
	bandwidth 2000
	interface s0/0/1
	bandwidth 2000

R3
	interface s0/0/0 
	bandwidth 64
	interface s0/0/1
	bandwidth 2000

Verifieer de bandwidth modificaties

	show interface s0/0/0

**Vraag**

Based on your bandwidth configuration, try and determine what the R2 and R3 routing tables will look like before you issue a show ip route command. Are their routing tables the same or different?

R2 routing table will be the same as before. It will still have 2 equal cost routes to the 10.3.3.0/30 network. R3 routing table will now only have 1 route to the 10.1.1.0/30 network via R2.

Configureer G0/0 als passive interface op R1, R2 en R3

	router eigrp 10
	passive-interface g0/0
	
Verifieer de passive interface configuration

	show ip protocols

**Reflection**

You could have used only static routing for this lab. What is an advantage of using EIGRP?

EIGRP can automatically adjust for network topology changes such as adding networks, or networks going down. EIGRP automatically picks the best path when the bandwidth of a link is modified, and it will automatically load balance across multiple equal cost paths.
	