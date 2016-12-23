# Documentatie - Introductie Docker
---
 **Inleiding:**
Docker is een open-source platform dat streeft naar gemakkelijke en probleemloze automatisering van linux applicaties binnen software containers. Om docker volledig te begrijpen zal ik de termen "image", "docker daemon" en "container" uitleggen en vervolgens samen gebruiken om het goed uit te leggen.

* Docker daemon

>Als u thuis bent in het Linux systeem weet u dat Daemons services zijn. Deze kunnen een bepaalde service runnen, bijvoorbeeld "wifi_supplicant", die staat je toe om een wifi connectie te maken. Linux geeft je de vrijheid om elke service te disablen of runnen. De Docker service handelt alles af op host-niveau. Deze zal ervoor zorgen dat je containers kan aanmaken, runnen, stoppen en verwijderen. Ook zal deze daemon images kunnen binnenhalen, en vervolgens van deze images containers maken. De daemon verzorgt dus alle communicatie tussen het host systeem en de containers en images. Alle commando's gaan langs de daemon.

* Images

> Een docker image is een read-only file die je kan downloaden van verschillende bronnen, de meest bekende is Dockerhub. In een image zitten alle componenten die je nodig hebt om een specifieke applicatie te runnen. Verder is deze image opgebouwd in lagen, als er een update nodig is voor een image wordt er gewoon een laag toegevoegd. Als er iets moet gewijzigd worden, moet je enkel maar 1 laag aanpassen. Dit maakt het dataverkeer voor updates en aanpassingen aanzienlijk kleiner. Docker images zijn tevens heel klein tegenover volledige virtual machines van een virtualbox bijvoorbeeld, Docker images hebben enkel wat dependencies nodig, ze runnen de basis van de Linux kernel recht van het systeem zelf. Elke Linux PC die docker draait heeft immers dezelfde soort kernel en dit moet dus niet inbegrepen worden in de image.

* Containers

> Nu u weet wat images zijn en wat de docker daemon juist doet rest alleen nog de vraag, wat is een container? Een container kan je zien als een soort mini-virtual machine. Als je een image hebt kan je deze gebruiken om een container van te maken, je maakt gewoon de standaard container van een image zonder extra toevoegingen, of je geeft een configuratie bestand mee en maakt de container kant en klaar voor je noden. Ook is het mogelijk om containers te linken, om bijvoorbeeld een wordpress of joomla te runnen heb je een database nodig. Dus kan je een container maken voor wordpress of joomla en dan een container met een mysql database op. Vervolgens link je deze zodat deze met elkaar kunnen communiceren. Deze containers zijn klein en performant tegenover de traditionele virtual machines, ze runnen bovenop het host-os wat performanter en veel kleiner is dan een heel OS virtualiseren om daarin dan je applicatie te runnen.

Als deze 3 samenwerken krijg je het programma docker dat ervoor zorgt dat je steeds betrouwbaar je applicaties kunt verspreiden zonder problemen te hebben met dependencies. De daemon werkt op host niveau en heeft alle basis benodigdheden. Je kan images downloaden vanaf dockerhub die zeer klein zijn omdat ze enkel noodzakelijke dingen zoals dependencies bevatten. En met die images kan je containers maken, deze zijn afgezonderde kleine virtual machines die configureerbaar zijn met configuratiefiles en automatisatie of provision software. Er zijn verschillende gebieden waarop men de werking van docker nog kan verbeteren of aandacht moet besteden. Over deze aandachtspunten gaan de volgende secties.


# Orchestration

## Howto use docker-compose to Start, Stop, Remove Docker Containers

* Start Docker Containers op de achtergrond

Al de services zijn in de docker-compose.yml file gedefinieerd. Hierin zitten ook applicatie service dependencies. 

Als je `docker-compuse up` doet gaat hij de image downloaden en builden als deze nog niet op je server staat, dan met je application node de image builden en tenslotte de docker applicatie starten met alle dependencies. 


`docker-compuse up -d`, de -d optie laat de applicatie lopen in de achtergrond als een daemon. Deze loopt tot je hem zelf stopt. 

* Start Docker Containers op de voorgrond

Zonder de -d optie starten de services op de voorgrond. In dit geval zie je alle logs en berichten. Dit is handig als je moet debuggen. Als je hier Ctrl+C doet stopt het voorgrond proces maar dit is hetzelfde als `docker-compose stop` uit te voeren en dus stoppen ook alle containers.

* Additional docker-compose Startup Options

Met de optie --no-recreate worden de containers niet opnieuw gemaakt als deze reeds bestaan. 

Hete omgekeerde kan ook. Ookal is er niks veranderd in de .yml file, de containers worden opnieuw gemaakt. 

Je kan ook een timeout value instellen. Standaard staat deze op 10 seconden, in volgend commando op 30 seconden 

	# docker-compose up -d -t 30

Volgende opties kunnen ook met docker-compose up gebruikt worden. 

>–no-deps This will not start any linked depended services.

>–no-build This will not build the image, even when the image is missing

>–abort-on-container-exit This will stop all the containers if any container was stopped. You cannot use this option with -d, you have to use this option by itself.

>–no-color In the output, this will not show any color. This will display the monochrome output on screen.

* Stop alle docker containers

Als de containers op de voorgrond lopen dan kunnen we ze stoppen met Ctrl+C. 

Lopen ze in de achtergrond gebruik dan `docker-compose stop` 

Je kan ze ook stoppen en verwijderen met `docker-compose rm -f`

* Stop een specifieke Docker container

Met het commando `docker-compose stop [naamContainer]` kan je specifiek een container stoppen

Je kan ook de shutdown time-out instellen met `docker-compose stop -t 30` of `docker-compose stop [naamContainer] -t 30`

* Remove Container Volumes

Tijdens het verwijderen van een gestopte container worden niet alle volumes mee verwijderd die aan de container gelinkt zijn. 

Wil je deze wel verwijderen dan kan dat met

	docker-compose rm -v

Je kan ook een specifieke container verwijderen

	docker-compose rm -f data

* Status van Docker Containers

Om de status van de verschillende containers te zien gebruik

	docker-compose ps

Het volgende geeft het ID van bv een data container weer

	docker-compose ps -q db

* Restart multiple Docker Containers

Gebruik volgende commando's in deze volgorde: 

>Deze zullen eerst worden gestopt, dan verwijderd, en dan volgende yml file terug in de background opgestart worden. Hiervoor moeten we ook in de folder zitten waar we de yml file vinden. 

	docker-compose stop && docker-compose rm -f 
	docker-compose up -d

## Docker tools compared: Kubernetes vs Docker Swarm

Kubernetes en Docker Swarm zijn 2 veel gebruikte tools om containers in een cluster te deployen. 

### Kubernetes

Dit is van Google. Als je dit begon te gebruiken rond de versie van Docker 1.0 was dit een zeer goede tool want deze verbeterde de meeste fouten die docker zelf hadden. Het gebruikte flannel om een netwerk te creeren tussen containers. Ook heeft het load balancing en maaktgebruik van etcd voor service discovery. Het gebruikt een andere CLI, andere API en ook YAML definitions. Dus je kan je Docker CLI niet gebruiken nog je Docker Compose om containers te definieren. Alles moet van scratch gedaan worden exclusief voor Kubernetes.  

### Docker Swarm

Maakt gebruik van de Docker API. Dit betekend dat elke tool dat gebruikt om te communiceren met Docker kan gebruikt worden met Docker Swarm. Dit is een voordeel maar ook een nadeel. Het voordeel is dat ze samenwerken maar het nadeel is dat we enkel gebonden zijn aan de Docker API. 

### Setting up

Swarm is ook een container. Dus deze settup is gemakkelijk, straigthforward en flexibel. Je moet enkel één van de service discovery tools te installeren en container van swarm te laten lopen alle nodes. 

Kubernetes setup is iets moeilijker. Deze verschilt van OS tot OS en van provider tot provider. Bv als je vagrant probeert dan moet je Fedora gebruiken. Je kan ook met andere maar dan moet je verder gaan kijken dan de Getting Started pagina. De installatie vertrouwd op een bash script. Dit is een probleem want we willen Kubernetes een deel maken van bv ansible definities. Maar hier is een oplossing voor. Je kan Ansible playbooks vinden die Kubernetes gebruiken of ze zelf schrijven. 

Bij de setup is bij Kubernetes moeilijker dan bij Swarm maar eens ze draaien doen ze allebij hetzelfde. 

### Running containers

In Swarm is er geen verschil zoals je ze voor Swarm definieerde. En je gebruik je Docker compose dan laat je ze lopen in de Swarm cluster. 

Bij Kubernetes moet je de CLI leren en ken je docker-compose.yml niet gebruiken. Je moet Kubernetes equivalenten maken.  

### Choise

Het zijn beide goede tools. Maar de voorkeur gaat toch naar Docker Swarm omdat Kubernetes moeilijker is in setup en te verschillend is van de Docker API. Het heeft ook geen echte voordelen ten opzichte van Swarm sinds update 1.9. 

### Om Docker Swarm te installeren en gebruiksklaar te maken

Op deze [link](https://docs.docker.com/swarm/install-w-machine/) vind je hoe je Docker Swarm installeert en gebruikt. 

#<a name="monitoring"></a>Monitoring

## Datadog

Voor de monitoring van de containers via Docker zijn er al enige tools aanwezig. Wij opteren voor Datadog aangezien we via de GitHub Student Developer Pack hiervoor een gratis licentie krijgen.

Deze tool voorziet vele integraties met o.a. Docker, Kubernetes, Chef, GO en Ansible.

Voor deze opdracht zijn wij natuurlijk geïnteresseerd in de Docker integratie.

![](https://i.gyazo.com/91f6e1ce6a7f8a90953b38f789fb7e26.png)

Dankzij onze licentie is er plenty of support voorzien en de documentatie over de configuratie is zeer straigth forward. Hieronder een beknopte samenvatting van wat te doen.


### One Step install voor Docker Agent.

    docker run -d --name dd-agent -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=69bb137993738dd8796a071d9633267d datadog/docker-dd-agent:latest

> Er zijn ook nog andere Datadog one step installs voor andere OS's en services.

De Docker Agent valt te installeren voor elke container, een enkele container of voor de host zelf.  Afhankelijk van de monitoring needs valt dit dus aan te passen. In [de guide van DataDog](http://docs.datadoghq.com/integrations/docker/) staat de configuratie bondig en duidelijk beschreven.

De containers met de Agent zullen verschijnen in de Dashboards die hieronder zijn beschreven.


### Dashboards

Er zijn 2 soorten Dashboards.

![](https://i.gyazo.com/cd9643fd701be7188c9d8ccc5438ab01.png)

Zoals u kunt zien is de TimeBoard handig voor Troubleshooting en correlaties. ScreenBoard is handig voor de status te bekijken. Je kan custom Dashboards blijven maken naarmate je ze nodig acht.

Voor de monitoring van de Docker Containers zullen we vooral ScreenBoard gebruiken.

Hieronder nog een voorbeeld van hoe een opgezette Docker Integration eruit ziet met DataDog

![](http://docs.datadoghq.com/static/images/docker.png)


# Security

## Waarom is speciale aandacht nodig voor security binnen Docker?
Docker is dagelijks aan het groeien en de community wordt steeds groter. Dit brengt ook security risks mee aangezien niet elke Docker image die je online vindt noodzakelijk goed geconfigureerd is. Ook de gedeelde Kernel over de containers en host zelf vragen extra safety measures.

## Check your distribution
In eerste instantie is het belangrijk om bewust te zijn van het feit dat niet iedereen goede bedoelingen heeft. Zorg ervoor dat je steeds controleert van wie de Docker image afkomstig is en of deze uitgever betrouwbaar is.

De hoofdrepositories van Docker zelf zijn hierbij de veiligste opties. Indien je toch een public repository wilt gebruiken, check dan zeker feedback of Google het.

## Be aware of the shared Kernel
Een groot verschil tussen Docker en Vagrant is dat de Kernel bij Docker geshared wordt over alle containers en het host systeem. Bij Vagrant is alles afgescheiden in verschillende virtuele machines, wat op zich ook een nadeel is tegenover Docker.

Voor security is de shared Kernel het grootste pijnpunt. Van zodra je root access hebt tot 1 container, heb je in principe ook root access tot de host en de andere containers.

## Steps to stay secure
1. Zorg ervoor dat je de Docker Images steeds start met de flag `-u`. Dit forced dat ze gerunned worden als een ordinary user. Dit is de basic first step naar security.
2. Verwijder SUID flags uit de container images. Hierdoor worden privileged access attacks nog moeilijker.
3. Configureer de cgroups (Docker Control Groups), hier kan je een limiet zetten op de resources die elke container kan gebruiken. Hiermee zet je al een groot aantal container-based Denial-Of-Service attacks schaakmat.
4. Gebruik namespaces in Docker om containers van elkaar te isoleren. Zo kan de ene container andere containers niet beinvloeden.
5. Gebruik geen images van repositories die je niet vertrouwd. Doe steeds je research en gebruik bij voorkeur official repositories.
6. Overweeg om [Clair](https://github.com/coreos/clair) te gebruiken. Dit scant containers lokaal of uit een public registry om security te verzekeren.

Ook de [Monitoring](#monitoring) kan gebruikt worden om eventuele problemen te voorkomen of te spotten. DataDog kan zo geconfigureerd worden dat je warnings krijgt bij bepaalde parameters.



# Keep it small

## Size matters
Docker Images bestaan meestal uit vele containers. Dit kan al snel oplopen tot een hoog volume indien je vanalle addons begint toe te voegen via meer containers. Om dit probleem op te lossen, kan je aantal measures nemen of het roer helemaal omgooien en microcontainers gebruiken.

## Microcontainers
Microcontainers bevatten enkel de OS-libraries en language dependencies die nodig zijn om een applicatie te runnen. Niets anders.

Je begint met een bare minimum en voegt dependencies toe zodra ze nodig zijn.

![](http://3itzft3unmzv2ijg8v2vc718.wpengine.netdna-cdn.com//wp-content/uploads/2016/01/pasted_image_at_2016_01_22_11_20_am.png)

In de afbeelding hierboven zie je links een originele container en rechts de microcontainer. Het verschil in volume is enorm.

### Voordelen van microcontainers

* Vanzelfsprekend is de grootte van de microcontainers een groot voordeel
* Door dit klein volume is de downloadsnelheid van verspreiding van deze microcontainers veel sneller en beter.
* Minder code en programmas betekent ook minder om aan te vallen. Dit is een voordeel voor de security.

### De werkwijze
1. Begin met een base Scratch image. Hier zit letterlijk niets in.
2. Gebruik een lightweight distributie zoals [Alpine Linux](https://www.alpinelinux.org/). Alpine is slechts 5mb groot en op security gebaseerd.
3. Voeg de package toe van de dependency die je nodig hebt
4. Voeg de dependencies vanuit de package toe
5. Voeg een base image toe van de [language](https://github.com/iron-io/dockers) die je nodig hebt
6. Build de dependencies
7. Run

Deze werwijze is gebaseerd op het voorbeeld van [Dzone](https://dzone.com/articles/microcontainers-tiny-portable-docker-containers). Ze hebben ook voorbeelden van andere talen op https://github.com/iron-io/dockerworker.

## General steps to reduce Docker image size

### Copy-on-Write

Het docker container-file systeem gebruikt de **Copy-on-Write** techniek. Deze zorgt ervoor dat de startup time zeer snel is in vergelijking met VMs, maar zorgt ook voor extra stress op het disk gebruik. Hierom moeten docker image authors rekening houden met bepaalde zaken.

Elke RUN instructie in de Dockerfile schrijft een nieuwe laag uit in de image. Elke laag vraagt om extra plaats op de disk. Dus wanneer je bijvoorbeeld een update doet, dan maak je ook een nieuwe laag. Om dit te vermijden moet je zo veel mogelijk gedaan krijgen binnen 1 RUN instructie.

```
"cd /tmp && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz && tar xf wildfly-$WILDFLY_VERSION.tar.gz  && mv /tmp/wildfly-$WILDFLY_VERSION /opt/jboss/wildfly && rm /tmp/wildfly-$WILDFLY_VERSION.tar.gz"
```
> Dit voorbeeld download, extracteert, verplaatst en cleaned de installatie van Wildfly 10.0.0.0 in 1 commando. Hierdoor wordt maar 1 laag toegevoegd. Het verschil is zo'n 300 megabytes ingeval je elk commando apart uitvoert.

### Update the right way
Een simpele yum update kan je Docker Image meteen veel groter maken dan goed is.

Zo is het belangrijk om de laatste versies te gebruiken van wat je in je containers steekt. Indien je bij een image van fedora 22 een update statement steekt gaat die veel meer vragen en groter worden aangezien deze update naar fedora 23. Als je vanuit fedora 23 begint zijn de updates veel kleiner. Dit scheelt in het voorbeeld zo'n 200MB.

Een simpele tweak om het update commando efficienter te doen werken is om er op dezelfde lijn ook een clean commando aan te voegen.

	RUN dnf -y update && dnf clean all

> Hierdoor gaan we van 358MB naar 216MB. Clean dus telkens na een update.

Het blijft belangrijk om updates uit te voeren voor zowel security als features, maar er moet rekening gehouden worden met de manier waarop. Door commando's samen te brengen in 1 lijn besparen we al zeer veel in volume, wat ten voordele komt van de downloadsnelheid en distributie.

## Best practises

### 10 zaken die moet vermijden in containers

Wat moet je **niet** doen om de het beste uit containers te halen: 

* Sla geen data op in containers
> Een container kan gestopt, vernietigd of verplaatst worden. Om deze reden moet de data in een volume geplaatst worden. Zorg er ook voor je applicaties naar een shared data store schrijven.

* Plaats je applicatie niet in 2 stukken

>Sommigen plaatsen hun applicaties in running containers. Dit kan in de development case of om te debuggen maar bij continious delivery moet je applicatie in een image staan. Remember: Containers are immutable.

* Don't create large images
> Grote images zijn harder om uit te voeren. Installeer geen onnodige packages. 

* Gebruik geen single layer image
> Om effectief gebruik te maken van het layered filesystem, create een base image layer, een andere voor username definition, één voor runtime installation, één voor configuration en tenlaatste één voor je applicatie. Dit maakt het makkelijker om je images te recreaten, managen en uit te voeren.

* Maak geen images van lopende containers

> gebruik dus geen docker commit om een image te maken. Gebruik altijd een Dockerfle of een ander source-to-image dat is reproduceerbaar. 

* Gebruik niet alleen de "latest" tag

* Laat niet meer dan één proces lopen in één container

* Sla geen credentials op in een image. Gebruik environment variables. 

> Sla geen username/password in je image op. Gebruik environment variables om dat van buitenaf te krijgen. Zie eventueel postgres image.

* Laat geen processen lopen als een root user. 

* Vertrouw geen ip-adressen

> Elke container heeft zijn eigen intern IP-adres en dit kan veranderen als je de container start en stopt. Gebruik environment variables voor eventueel te communiceren met andere containers. 

### Refactoring a Dockerfile for image size

We gaan dit aan de hand van een voorbeeld proberen duidelijk te maken. 

	FROM ubuntu:14.04
	RUN apt-get update
	RUN apt-get install -y curl python-pip
	
	RUN pip install requests
	
	ADD ./my_service.py /my_service.py
	ENTRYPOINT ["python", "/my_service.py"]

my_service.py is een python script dat bevat: 

	#!/usr/bin/python
	print 'Hello, world!'

Builden en kijken naar de grote van de image: 

	$ sudo docker build -t size .
	$ sudo docker images
	REPOSITORY      TAG           IMAGE ID            CREATED           VIRTUAL SIZE
	size            latest        da8a9be731ac        4 seconds ago     360.5 MB
	ubuntu          14.04         6cc0fc2a5ee3        2 weeks ago       187.9 MB

We zien dat daar het script te laten lopen de size verdubbeld is. Dit is het toaal van de visible layer en alle layers dat zijn gebruikt voor het createn van deze top layer. 

Toevoegen van cleanup layer. 

Clean up after: 

	FROM ubuntu:14.04
	RUN apt-get update
	RUN apt-get install -y curl python-pip
	
	RUN pip install requests
	
	## Clean up
	RUN apt-get remove -y python-pip curl
	RUN rm -rf /var/lib/apt/lists/*
	
	ADD ./my_service.py /my_service.py
	ENTRYPOINT ["python", "/my_service.py"]

Controle:

	$ sudo docker build -t size .
	$ sudo docker images
	REPOSITORY      TAG           IMAGE ID            CREATED           VIRTUAL SIZE
	size            latest        c6dacdd00660        2 seconds ago     361.3 MB
	ubuntu          14.04         6cc0fc2a5ee3        2 weeks ago       187.9 MB


We zien dat het nog groter geworden is. 

Cleanup in the same layer

	FROM ubuntu:14.04
	RUN apt-get update && \
	    apt-get install -y curl python-pip && \
	    pip install requests && \
	    apt-get remove -y python-pip curl && \
	    rm -rf /var/lib/apt/lists/*
	
	ADD ./my_service.py /my_service.py
	ENTRYPOINT ["python", "/my_service.py"]

Controle: 
	
	$ sudo docker build -t size .
	$ sudo docker images
	REPOSITORY      TAG           IMAGE ID            CREATED           VIRTUAL SIZE
	size            latest        e531f8674f33        9 seconds ago     338 MB
	ubuntu          14.04         6cc0fc2a5ee3        2 weeks ago       187.9 MB

We zien dat het verminderd is maar toch blijft het redelijk groot. 

Meer apt-optimizations

We zien dat `apt-get install` nog meer recommended packages meebrengt. Deze zijn niet altijd required. Het verwijderen van deze recommended packages brengt geen neven effecten met zich mee. 

Proberen het opnieuw met `--no-install-recommends` in apt-get

	FROM ubuntu:14.04
	RUN apt-get update && \
	    apt-get install -y --no-install-recommends curl python-pip && \
	    pip install requests && \
	    apt-get remove -y python-pip curl && \
	    rm -rf /var/lib/apt/lists/*
	
	ADD ./my_service.py /my_service.py
	ENTRYPOINT ["python", "/my_service.py"]

Controle:

	REPOSITORY      TAG           IMAGE ID            CREATED           VIRTUAL SIZE
	size            latest        fddc30aee4dc        6 seconds ago     229.2 MB
	ubuntu          14.04         6cc0fc2a5ee3        2 weeks ago       187.9 MB


We zien dat de size veel gedaald is! 

### Containers zijn geen VM's 

Dit zijn 2 verschillende onderdelen die mensen veel zien als 1. 

We gaan het  proberen vergelijken met een voorbeeld om het beter te begrijpen. 

VM's zijn zoals alleenstaande huizen en containers zijn appartement gebouwen. 

Huizen (VM's) zijn volledig op zichzelf en beschermen u van onverwachte gasten. Ze bezitten elk hun eigen infrastructuur (elektriciteit, verwarming, water,...) en in de meeste gevallen hebben ze op z'n minst een slaapkamer, keuken, badkamer, ... Zelf het kleinste huis heeft meer dan dat je soms nodig hebt.

Appartementen (containers) ze bieden ook bescherming tegen onverwachte gasten maar in tegenstelling tot huizen hebben ze een gemeenschappelijke infrastructuur. We hebben het appartement gebouw (docker-host) verdeelt de elektriciteit, water en verwerming en de appartementen zijn er in alle soorten (van kleine studio's tot grote penthouses) en elk appartement heeft een duur voor indringers.

Met containers share je de onderliggende resources van de Docker host en maak je images dat precies zo zijn wat je nodig hebt voor je applicatie. Je start me de basis en voegt toe wat je nodig hebt. VM's werken omgekeerd: je begint met een volledig OS en verwijderd wat je niet nodig hebt. 

Docker is geen virtualisatie technologie maar een applicatie delivery technology. VM's slaan niet alleen applicatie code op maar ook zijn stateful data. Met containers is het anders. Hier is het meer een service dat helpt de applicatie te maken en runnen. 

Met containers, dus meerdere services voorgesteld door verschillende containers omvatten een applicatie. Zo kunnen applicaties uitgevouwd worden tot kleinere componenten. 

Je maakt geen back-up van containers. Je containers maken gebruik van een shared volume en hiervan maak je een back-up.

Bekijk volgende resources om te starten met meer te leren over Docker en containers: 

* [Watch an Intro to Docker webinar](https://docker.wistia.com/medias/fqwm0x9tgz)
* [Sign up for a free 30 day trial](https://store.docker.com/bundles/docker-datacenter/purchase?plan=free-trial)
* [Read the Containers as a Service white paper](http://www.docker.com/sites/default/files/caaSwhitepaper_V6_0.pdf)

### 9 Common Dockerfile mistakes

1. Running apt-get (hierboven al besproken)
2. Using ADD inplaats van COPY (best altijd COPY gebruiken, ADD heeft ook nog andere functies) 
3. Adding your entire application directory in one line (beter in meerdere lijnen)
4. Using :latest (gebruik een specifieke node zoals node:6.2.1)
5. Using external services during the build
6. Adding EXPOSE and ENV at the top of your Dockerfile (beter om ze zo laat mogelijk te declareren) 
7. Multiple FROM statements (zal enkel de laatste FROM gebruiken)
8. Multiple services running in the same container
9. Using VOLUME in your build process

## Sources

[https://dzone.com/articles/microcontainers-tiny-portable-docker-containers](https://dzone.com/articles/microcontainers-tiny-portable-docker-containers)

[https://github.com/iron-io/dockers](https://github.com/iron-io/dockers)

[https://github.com/iron-io/dockerworker](https://github.com/iron-io/dockerworker)

[http://developers.redhat.com/blog/2016/03/09/more-about-docker-images-size/](http://developers.redhat.com/blog/2016/03/09/more-about-docker-images-size/)

[http://elliot.land/docker-explained-simply](http://elliot.land/docker-explained-simply)

[https://developerblog.redhat.com/2016/02/24/10-things-to-avoid-in-docker-containers/](https://developerblog.redhat.com/2016/02/24/10-things-to-avoid-in-docker-containers/)

[https://blog.replicated.com/2016/02/05/refactoring-a-dockerfile-for-image-size/](https://blog.replicated.com/2016/02/05/refactoring-a-dockerfile-for-image-size/)

[https://blog.docker.com/2016/03/containers-are-not-vms/](https://blog.docker.com/2016/03/containers-are-not-vms/)

[http://blog.runnable.com/post/145895165446/9-common-dockerfile-mistakes](http://blog.runnable.com/post/145895165446/9-common-dockerfile-mistakes)

[http://www.thegeekstuff.com/2016/04/docker-compose-up-stop-rm/](http://www.thegeekstuff.com/2016/04/docker-compose-up-stop-rm/)

https://www.datadoghq.com/

http://docs.datadoghq.com/integrations/docker/

https://www.sumologic.com/blog-security/securing-docker-containers/

https://github.com/coreos/clair
