# Documentation: Troubleshooting Multiarea OSPFv2 and OSPFv3
----------

## Part 1: Build the Network and Load Device Configurations
### Step 1: Cable the network as shown in the topology.

### Step 2: Load router configuration files.
Zet de volgende gegeven configuratie in elke geschikte router.

**Router 1**

	enable
	conf t
	hostname R1
	enable secret class
	ipv6 unicast-routing
	no ip domain lookup
	interface Loopback0
	ip address 209.165.200.225 255.255.255.252
	interface Loopback1
	ip address 192.168.1.1 255.255.255.0
	ipv6 address 2001:DB80:ACAD:1::1/64
	ipv6 ospf network point-to-point
	interface Loopback2
	ip address 192.168.2.1 255.255.255.0
	ipv6 address 2001:DB8:ACAD:2::1/64
	ipv6 ospf 1 area 1
	ipv6 ospf network point-to-point
	interface Serial0/0/0
	ip address 192.168.21.1 255.255.255.252
	ipv6 address FE80::1 link-local
	ipv6 address 2001:DB8:ACAD:12::1/64
	ipv6 ospf 1 area 0
	clock rate 128000
	shutdown
	router ospf 1
	router-id 1.1.1.1
	passive-interface Loopback1
	passive-interface Loopback2
	network 192.168.2.0 0.0.0.255 area 1
	network 192.168.12.0 0.0.0.3 area 0
	default-information originate
	ipv6 router ospf 1
	area 1 range 2001:DB8:ACAD::/61
	ip route 0.0.0.0 0.0.0.0 Loopback0
	banner motd @
 		Unauthorized Access is Prohibited! @
	line con 0
	password cisco
	logging synchronous
	login
	line vty 0 4
	password cisco
	logging synchronous
	login
	transport input all
	end

**Router 2**

	enable
	conf t
	hostname R2
	ipv6 unicast-routing
	no ip domain lookup
	enable secret class
	interface Loopback6
	ip address 192.168.6.1 255.255.255.0
	ipv6 address 2001:DB8:CAD:6::1/64
	interface Serial0/0/0
	ip address 192.168.12.2 255.255.255.252
	ipv6 address FE80::2 link-local
	ipv6 address 2001:DB8:ACAD:12::2/64
	ipv6 ospf 1 area 0
	no shutdown
	interface Serial0/0/1
	ip address 192.168.23.2 255.255.255.252
	ipv6 address FE80::2 link-local
	ipv6 address 2001:DB8:ACAD:23::2/64
	ipv6 ospf 1 area 3
	clock rate 128000
	no shutdown
	router ospf 1
	router-id 2.2.2.2
	passive-interface Loopback6
	network 192.168.6.0 0.0.0.255 area 3
	network 192.168.12.0 0.0.0.3 area 0
	network 192.168.23.0 0.0.0.3 area 3
	ipv6 router ospf 1
	router-id 2.2.2.2
	banner motd @
	 Unauthorized Access is Prohibited! @
	line con 0
	password cisco
	logging synchronous
	login
	line vty 0 4
	password cisco
	logging synchronous
	login
	transport input all
	end

**Router 3**

	enable
	conf t
	hostname R3
	no ip domain lookup
	ipv6 unicast-routing
	enable secret class
	interface Loopback4
	ip address 192.168.4.1 255.255.255.0
	ipv6 address 2001:DB8:ACAD:4::1/64
	ipv6 ospf 1 area 3
	interface Loopback5
	ip address 192.168.5.1 255.255.255.0
	ipv6 address 2001:DB8:ACAD:5::1/64
	ipv6 ospf 1 area 3
	interface Serial0/0/1
	ip address 192.168.23.1 255.255.255.252
	ipv6 address FE80::3 link-local
	ipv6 address 2001:DB8:ACAD:23::1/64
	ipv6 ospf 1 area 3
	no shutdown
	router ospf 1
	router-id 3.3.3.3
	passive-interface Loopback4
	passive-interface Loopback5
	network 192.168.4.0 0.0.0.255 area 3
	network 192.168.5.0 0.0.0.255 area 3
	ipv6 router ospf 1
	router-id 3.3.3.3
	banner motd @
	 Unauthorized Access is Prohibited! @
	line con 0
	password cisco
	logging synchronous
	login
	line vty 0 4
	password cisco
	logging synchronous
	login
	transport input all
	end

### Step 3: Save your configuration

	copy running-config startup-config

## Part 2: Troubleshoot Layer 3 Connectivity
### Step 1: Verify the interfaces listed in the Addressing Table are active and configured with correct IP address information.
a) Issue the show ip interface brief command on all three routers to verify that the interfaces are in an up/up state.

	show ip interface brief

> We merken op dat er de serial 0/0/0 op R1 zich niet in up state bevindt.

b) Issue the show run | section interface command to view all the commands related to interfaces.

	show run | section interface

> Na enig zoeken merken we op dat de ip adressen bij interface Loopback1 en Serial0/0/0 fout zijn.

Run het commando opnieuw op R2 en R3.

> Bij R2 merken we ook op dat bij interface Loopback6 het ip adres verkeerd is. R3 lijkt in orde te zijn.

c) Resolve all problems found. Record the commands used to correct the configuration.

** Router 1:** (poort activeren + foute ip's)

Interface s0/0/0 fixen.

	interface s0/0/0
	ip address 192.168.12.1 255.255.255.252
	no shutdown

Interface lo1 fixen.

	interface lo1
	no ipv6 address 2001:DB80:ACAD:1::1/64
	ipv6 address 2001:DB8:ACAD:1::1/64
	end

**Router 2:** (1 fout adres)

Interface lo6 fixen.

	interface lo6
	no ipv6 address 2001:DB8:CAD:6::1/64
	ipv6 address 2001:DB8:ACAD:6::1/64
	end

**Router 3: In orde!**

## Part 3: Troubleshoot OSPFv2
### Step 1: Test IPv4 end-to-end connectivity.

> Note: LAN (loopback) interfaces should not advertise OSPF routing information, but routes to these networks should be contained in the routing tables.

From each router, ping all interfaces on the other routers. Record your results below as IPv4 OSPFv2 connectivity problems do exist.

We zien de volgende resultaten:

	R1 to R2: Alles succesvol.
	R1 to R3: Alles gefaald.
	R2 to R1: Alles succesvol.
	R2 to R3: lo4 en lo5 gefaald.
	R3 to R1: Alles gefaald.
	R3 to R2: lo6 en s0/0/0 gefaald.

### Step 2: Verify that all interfaces are assigned to the proper OSPFv2 areas on R1.
a) Issue the `show ip protocols` command to verify that OSPF is running and that all networks are being advertised in the correct areas. Verify that the router ID is set correctly, as well for OSPF.

	show ip protocols

>Merk op dat het ip-adres bij area 1 fout is!

b) If required, make the necessary changes needed to the configuration on R1 based on the output from the `show ip protocols` command. Record the commands used to correct the configuration.

	router ospf 1
	network 192.168.1.0 0.0.0.255 area 1
	end

c-d) Issue the `show ip ospf interface brief` command to verify that the serial interface and loopback interfaces 1 and 2 are listed as OSPF networks assigned to their respective areas.

	show ip ospf interface brief

>Alles lijkt in orde te zijn.

### Step 3: Verify that all interfaces are assigned to the proper OSPFv2 areas on R2.

a) Issue the `show ip protocols` command to verify that OSPF is running and that all networks are being advertised in the correct areas. Verify that the router ID is set correctly, as well for OSPF.

	show ip protocols
	show ip ospf interface brief

> Alles lijkt in orde te zijn.

### Step 4: Verify that all interfaces are assigned to the proper OSPFv2 areas on R3.
a) Issue the `show ip protocols` command to verify that OSPF is running and that all networks are being advertised in the correct areas. Verify that the router ID is set correctly, as well for OSPF.

	show ip protocols

>Er lijkt een IP adres te missen.

b) If required, make the necessary changes to the configuration on R3 based on the output from the show ip protocols command. Record the commands used to correct the configuration.

	router ospf 1
	network 192.168.23.0 0.0.0.3 area 3
	end

Controleer met:
	show ip ospf interface brief

### Step 5: Verify OSPFv2 neighbour information.
a) Issue the show ip ospf neighbor command to verify that each router has all OSPFv2 neighbors listed.

	show ip ospf neighbor

### Step 6: Verify OSPFv2 routing information.
a) Issue the show ip route ospf command to verify that each router has all OSPFv2 routes in their respective routing tables

	show ip route ospf

> Alles lijkt in orde en de pings uit volgende stap zouden zonder problemen moeten verlopen.

### Step 7: Verify IPv4 end-to-end connectivity
From each router, ping all interfaces on other routers. If IPv4 end-to-end connectivity does not exist, then continue troubleshooting to resolve any remaining issues.

## Part 4: Troubleshoot OSPFv3

### Step 1: Test IPv6 end-to-end connectivity.
From each router, ping all interfaces on the other routers. Record your results as IPv6 connectivity problems do exist.

	R1 to R2: Pings naar lo6 falen.
	R1 to R3: Alles succesvol.
	R2 to R1: Pings naar lo1 en lo2 falen.
	R2 to R3: Alles succesvol.
	R3 to R1: Alles succesvol.
	R3 to R2: Alles succesvol

### Step 2: Verify that IPv6 unicast routing has been enabled on all routers.

	show run | section ipv6 unicast

>Ipv6 routing staat overal actief.

### Step 3: Verify that all interfaces are assigned to the proper OSPFv3 areas on R1.

a) Step 3: Verify that all interfaces are assigned to the proper OSPFv3 areas on R1.

	show ipv6 protocols

> Merk op dat router ID fout lijkt, ook ontbreekt lo1 in de interface lijst.

Aanpassen configuratie op R1:

	interface lo1
	ipv6 ospf 1 area 1
	ipv6 router ospf 1
	router-id 1.1.1.1

d) Enter the show ipv6 route ospf command on R1 to verify that the interarea route summarization is configured correctly.

	show ipv6 route ospf

e) Which IPv6 networks are included in the interarea route summarization shown in the routing table?

	2001:DB8:ACAD::/64 tot 2001:DB8:ACAD:7::/64

f) If required, make the necessary configuration changes on R1. Record the commands used to correct the configuration.

> Merk op dat de subnetmask van de range fout is bij area 1. Daarom passen we deze dus enkel daar aan.

	ipv6 router ospf 1
	no area 1 range 2001:DB8:ACAD::/61
	area 1 range 2001:DB8:ACAD::/62

### Step 4: Verify that all interfaces are assigned to the proper OSPFv3 areas on R2.

Issue the show ipv6 protocols command and verify that the router ID is correct and that the expected interfaces are showing up under their proper areas.

	show ipv6 protocols

>We zien dat lo6 ontbreekt binnen area 3.

	interface lo6
	ipv6 ospf 1 area 3

### Step 5: Verify that all interfaces are assigned to the proper OSPFv3 areas on R3.
a) Issue the show ipv6 protocols command to verify that the router ID is correct and the expected interfaces display under their respective areas.

	show ipv6 protocols

> Alles lijkt in orde te zijn.

### Step 6: Verify that all routers have correct neighbor adjacency information.

Controleren of alle buren elkaar vinden.

	show ipv6 ospf neighbor

### Step 7: Verify OSPFv3 routing information.
a) Issue the show ipv6 route ospf command, and verify that OSPFv3 routes exist to all networks.

> Alles lijkt in orde te zijn, de ping bij de volgende stap zou moeten lukken.

### Step 8: Verify IPv6 end-to-end connectivity.
From each router, ping all of the IPv6 interfaces on the other routers. If IPv6 end-to-end issues still exist, continue troubleshooting to resolve any remaining issues.

>De pings werken, het netwerk is getroubleshoot en volledig operationeel!
