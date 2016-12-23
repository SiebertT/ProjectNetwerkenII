# Testrapport opdracht 3: Cisco labo's


----------


## Labo 2.3.2.3: Configuring Rapid PVST+, PortFast and BPDU Guard

- Is the network cabled as shown in the topology?

 ![](https://camo.githubusercontent.com/883b973b1ebe6ef7cd4e774c1b86bfb374a786b5/68747470733a2f2f692e6779617a6f2e636f6d2f33333932623663396338643963313431303633623838373738323862633963632e706e67)

- Are the PC hosts configured?

![](https://i.gyazo.com/2a7e2a0cd31b47d29b38d4e89e515a2e.png)

> in a real setup, this is done at the ipv4 configuration. You can reach this by right clicking on the network on the taskbar and opening the Network Center.

- Are the switches initialized?

Yes

> This is usually fine. If anything is not as it is supposed to be, troubleshoot and reload.

- Are the basic switch settings configured for each switch?

![](https://i.gyazo.com/62cd61949051e3261c05ffbf0298f2fd.png)

![](https://i.gyazo.com/44e779343a99a218a66b4469d10386eb.png)

- Are the VLANs, Native Vlan and Trunks configured?

![](https://i.gyazo.com/95f23574341f1a6e28397052f799195b.png)

![](https://i.gyazo.com/879a4161feba8e6bf63cd411cb2ff584.png)

![](https://i.gyazo.com/1a40b842b3209458bad8511881d4839a.png)

- Is there connectivity between the PCs?

![](https://i.gyazo.com/f18d9823dc2a246d67425a18a26dae6d.png)

- Is the current root bridge determined?

![](https://i.gyazo.com/ca13b8164cc368767a73c4687a523a78.png)

- Is the primary and secondary root bridge configured for all switches?

![](https://i.gyazo.com/385385039171ccaa958bcdca31a60aca.png)

- Was the topology changed to examine the convergence?

![](https://i.gyazo.com/81ebd48a151439275dde1dc4eb5fb43a.png)

- Is Rapid PVST+ configured?

![](https://i.gyazo.com/1a4f4ca1a63d1050222523b6e96ea5eb.png)

- Is PortFast and BPDU Guard configured?

![](https://i.gyazo.com/1dda0ea17fb879c5aeff9c5c7116aedf.png)

Uitvoerder(s) test: Siebert

Uitgevoerd op: 11/07/2016 12:57:27

## Labo 6.2.3.8: Configuring Multiarea OSPFv2

- Is the network cabled as shown in the topology?

![](https://camo.githubusercontent.com/0065a726ec9c24bc0aa0f31eefedd2ef9c2cd7a8/68747470733a2f2f692e6779617a6f2e636f6d2f61616639613430656532383664303737643965613430613864306231373665622e706e67)

- Are the routers initialized?

> This is usually fine. If there are any irregularities, troubleshoot, write to memory and reload.

- Are the basic router settings configured?

![](https://i.gyazo.com/04d30ffd8a02dd0fa5a4631b4bbfea68.png)

![](https://i.gyazo.com/d8b84714ce6b1aa879111938daadd569.png)

![](https://i.gyazo.com/ec0ba37bfb93ef27fdfeb3ad6a0103d6.png)

- Can each router ping their neighbor's serial interface?

![](https://i.gyazo.com/92cee778cdc7c8762d4f94e7565e18d1.png)

- Did you configure multiarea OSPFv2?

![](https://i.gyazo.com/f563fbf5e647da524db7d7007429bb95.png)

![](https://i.gyazo.com/7b5fca47d8dbffead9c4803a03234a94.png)

![](https://i.gyazo.com/31a7ca6afdaab756830420b217a1c9ff.png)

- Did you configure MD5 authentication on all serial interfaces?

![](https://i.gyazo.com/6f9bfcacc8570cf984bc94386de8c57c.png)

- Are the Interarea Summary Routers configured?

![](https://i.gyazo.com/ac56b391b6969b94057f50e33ba50aeb.png)

![](https://i.gyazo.com/a6327f29c1281358bbcbca5e7c77b810.png)

Uitvoerder(s) test: Siebert

Uitgevoerd op: 11/07/2016 15:34:45

## Labo 6.2.3.9: Configuring Multiarea OSPFv3

- Are the routers configured with the basic settings?

  Run:

      show ip interface brief
      show ipv6 interface brief

- Is there connectivity between the routers?



![  ](http://puu.sh/sgMAo/59a0a7ea7e.png)

- Are the routers configured with the correct ID?


![](http://puu.sh/sgMCA/d57c658555.png)

- Is multiarea OSPF correctly configured for each interface on each router?

![](http://puu.sh/sgMLG/5d2c668277.png)

- Does the OSPFv3 protocol find all neighbours and routing information?

![](http://puu.sh/sgMJV/4168ab2c4e.png)

- Is the network correctly summarized?

![](http://puu.sh/sgMNy/1048fe9f78.png)

Uitvoerder(s) test: Bono

Uitgevoerd op: 13/11/2016 15:00


## Labo 6.2.3.10: Troubleshooting Multiarea OSPFv2 and OSPFv3

- Are the routers configured with the given configuration?

Run:

    show ip interface brief
    show ipv6 interface brief
    show run

- Are all interfaces up on each router?

![](http://puu.sh/sgPP9/dcc2218e05.png)

- Are the correct ip addresses assigned to the correct interfaces on each router?

![](http://puu.sh/sgPRI/156ffd67e2.png)


- Are the interfaces assigned to the proper OSPFv2 areas on each router?

![](http://puu.sh/sgPXt/ec84dbd0c5.png)

- Does the OSPFv2 protocol list the correct neighbours on each router?

    show ip ospf neighbor


- Does OSPFv2 fill up the routing tables with the correct entries?

    show ip route ospf



- Are the routers enabled for unicast routing?

![](http://puu.sh/sgQ96/89748d951b.png)


- Are all interfaces assigned to the correct OSPFv3 areas on all routers?

![](http://puu.sh/sgQbo/58fd4fe658.png)

- Do all the routers have the correct neighbour adjency information?

![](http://puu.sh/sgQcR/e09089ac4f.png)


Uitvoerder(s) test: Bono

Uitgevoerd op: 13/11/2016

## Labo 7.2.2.5: Configuring Basic EIGRP for IPv4

- Is the network cabled as shown in the topology?

![](https://i.gyazo.com/8e492079db5c9a1f7cd3a4d976088d47.png)

- Are the PC hosts configured?

![](https://i.gyazo.com/14f02901f4c0f64cbfa3ef5f671d444a.png)
![](https://i.gyazo.com/8c97939de6fe6b810c4dba03b3d9373c.png)
![](https://i.gyazo.com/450e755fce09d03362a3af37370b71c5.png)


- Are the basic router settings configured for each router?

![](https://i.gyazo.com/eb791b7dd5bf6271d5dfb30358208276.png)
![](https://i.gyazo.com/cf226695c24de242a0190283dc843346.png)
![](https://i.gyazo.com/50dbb7a8c7e6006b7fa5f3f685a62909.png)

- Is EIGRP configured?

![](https://i.gyazo.com/8d9db1f1c28c78faf3c139fddd335536.png)
![](https://i.gyazo.com/b77dd56207eddf1cf4cbc4eb709d643a.png)
![](https://i.gyazo.com/7b78f80ec62193727220a58dbd9e3c26.png)
![](https://i.gyazo.com/cd1cbc52f795ef9ad73ef92c57b4916a.png)

- Is there connectivity between the PCs?

![](https://i.gyazo.com/cc82894623cd09381ccbc2087c6d855c.png)

- Are the bandwidth and passive interfaces configured?

![](https://i.gyazo.com/b018d510e4ccaf9b7518a96de97e9784.png)
![](https://i.gyazo.com/2dfe8ceec2d3f39f1c93b3c7bae8d9c5.png)

Uitvoerder(s) test: Robby

Uitgevoerd op: 7/11/16

## Labo 7.4.3.5: Configuring Basic EIGRP for IPv6

- Is the network cabled as shown in the topology?

![](https://i.gyazo.com/935b37d9bfd7b874f6a69ceb8fa46823.png)

- Are the PC hosts configured?

![](https://i.gyazo.com/9fa37f7e3044207ce8446df85fd21641.png)


- Are the basic router settings configured for each router?

![](https://i.gyazo.com/2efeade58b24adf80748cf46db4d7d52.png)

![](https://i.gyazo.com/12427723de077383e2ba9c504b17667c.png)

![](https://i.gyazo.com/da8f3f6b58e83a968bc6348fb2451467.png)

- Is EIGRP for IPv6 configured?

![](https://i.gyazo.com/7c5712d69a119fba25e7a8a8d39d5dab.png)

![](https://i.gyazo.com/8922426ad44c5218eec659e6c21bbd8e.png)


- Is there connectivity between the PCs?

![](https://i.gyazo.com/a4414cec735a373028982f2696e8e969.png)

- Passive interfaces configured?

![](https://i.gyazo.com/228364eeccf87f86039c76d2a66e3dbc.png)

## Test X

Uitvoerder(s) test: Robby, Bono, Siebert

Uitgevoerd op: DATUM

Github commit:  COMMIT HASH
