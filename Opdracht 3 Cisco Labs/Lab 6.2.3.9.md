# Documentation: Configuring Multiarea OSPFv3
----------

## Part 1: Build the Network and Configure Basic Device Settings

In Part 1, you will set up the network topology and configure basic settings, such as the interface IP
addresses, device access, and passwords.

### Step 1: Cable the network as shown in the topology.

Connect the devices as shown below in the Topology.

### Step 2: Initialize and reload the routers as necessary.

Normally this shouldn't be necessary. Otherwise initialize as required, write to memory with `copy running-config startup-config` and type `reload` in priviliged exec mode.

### Step 3: Configure basic settings for each router
> Hieronder de configuratie voor de basic settings, deze is te herhalen op de 2 andere routers voor een correcte opstellen.

a) Disable DNS lookup

	no ip domain-lookup

b) Configure device name as shown in the topology

	hostname R1

c) Assign class as the privileged EXEC password.

	enable secret class

d) Assign cisco as the vty password.

	line vty 0 4
	password cisco
	login

e) Configure a MOTD banner to warn users that unauthorized access is prohibited.

	banner motd "Unauthorized Access is forbidden!"

f) Configure logging synchronous for the console line.

	line con 0
	no logging synchronous

g) Encrypt plain text passwords.

	service password-encryption

h) Configure the IPv6 unicast and link-local addresses listed in the Addressing Table for all interfaces.
>Dit is voor R1, R2 en R3 zijn identiek op de adressen na, zie hiervoor de adrestabel bovenaan de opgave.


	interface Loopback0
	no ip address
	ipv6 address 2001:DB8:ACAD::1/64

	interface Loopback1
	no ip address
	ipv6 address 2001:DB8:ACAD:1::1/64

	interface Loopback2
	no ip address
	ipv6 address 2001:DB8:ACAD:2::1/64

	interface Loopback3
	no ip address
	ipv6 address 2001:DB8:ACAD:3::1/64

	interface Embedded-Service-Engine0/0
	no ip address
	shutdown

	interface GigabitEthernet0/0
	no ip address
	shutdown
	duplex auto
	speed auto

	interface GigabitEthernet0/1
	no ip address
	shutdown
	duplex auto
	speed auto

	interface Serial0/0/0
	no ip address
	ipv6 address FE80::1 link-local
	ipv6 address 2001:DB8:ACAD:12::1/64
	clock rate 2000000

	interface Serial0/0/1
	no ip address
	shutdown


i) Enable IPv6 unicast routing on each router.

	ipv6 unicast-routing

j) Copy the running configuration to the startup configuration.

	copy running-config startup-config



### Step 4: Test connectivity
	De routers zouden naar elkaar moeten kunnen pingen na configuratie.

## Part 2: Configure Multiarea OSPFv3 Routing
### Step 1: Assign router IDs
a) Op R1 start OSPF:

	ipv6 router ospf1

b) Ken het correcte ID toe aan R1 (1.1.1.1)

	router-id 1.1.1.1

> c) Doe hetzelfde voor R2 en R3, maar dan met 2.2.2.2 en 3.3.3.3

d) Verifieer met:

	show ipv6 ospf

### Step 2: Configure multiarea OSPFv3
a) We moeten nu voor elke interface OSPFv3 instellen, dit gebeurt als volgt:

	interface lo0
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point

	interface lo1
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point

	interface lo2
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point

	interface lo3
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point

	interface s0/0/0
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point

b) Controleer met:

	show ipv6 protocols

c-e) Doe hetzelfde voor R2 en R3, gebruik voor R2 bij elke interface area 0 en gebruik bij R3 overal area 2, behalve bij de seriele poort daar gebruik je area 0.

f) Controleer:

	show ipv6 ospf

### Step 3: Verify OSPFv3 neighbours and routing information.
a) Issue the `show ipv6 ospf neighbor`command on all routers to verify that each router is listing the correct routers as neighbors.

	show ipv6 ospf neighbour

b) Issue the show ipv6 route ospf command on all routers to verify that each router has learned routes to
all networks in the Addressing Table.

	show ipv6 route ospf

c) Issue the show ipv6 ospf database command on all routers.

	show ipv6 ospf database

## Part 3: Configure Interarea Route Summarization
### Step 1: Summarize networks on R1
Follow this easy tutorial:
![](https://i.imgsafe.org/05e24b0d08.png)
![](https://i.imgsafe.org/05e256e2ff.png)

### Step 2: Configure interarea route summarization on R1
a) To manually configure interarea route summarization on R1, use the `area area-id range address mask` command.

	ipv6 router ospf 1
	area 1 range 2001:DB8:ACAD::/62

b) View the OSPFv3 routes on R3.

	show ipv6 route ospf

c) View the OSPFv3 routes on R1.

	show ipv6 route ospf

### Step 3: Summarize networks and configure interarea route summarization on R3.

a) Idem als stap 1.
Als summarized adres bekomen we hier: `2001:DB8:ACAD:4::/62`

b) Manually configure interarea route summarization on R3. Write the commands in the space provided.

	ipv6 router ospf 1
	area 2 range 2001:DB8:ACAD:4::/62

c) Verify that area 2 routes are summarized on R1. What command was used?

	show ipv6 route
	show ipv6 route ospf

d) Record the routing table entry on R1 for the summarized route advertised from R3.

	OI 2001:DB8:ACAD:4::/62 [110/129]
			via FE80::2, Serial0/0/0
