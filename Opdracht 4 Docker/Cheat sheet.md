
# Cheat sheet: docker
----

Voor onze proof of concept zouden wij als webapplicatie Joomla gebruiken, aangezien dit eens iets anders is dan de Wordpress configuratie.

### Installeren docker op linux-arch 

	sudo pacman -S docker

### Service starten + controleren of het runt

	sudo systemctl start docker
	sudo docker

### Image installeren verkrijgen

	sudo docker search joomla
	sudo docker pull joomla

Momenteel nog geen containers: `sudo docker ps -l`

Om containers te maken: `sudo docker run [my_img] [command to run]`

Joomla heeft mysql nodig: 

	sudo docker pull mysql

### Containers aanmaken

	sudo docker run --name some-mysql -e MYSQL_ROOT_PASSWORD = robby -d mysql

	sudo docker run --name some-joomla --link some-mysql:mysql -d joomla

om ip adres te verkrijgen van container: 

	docker inspect --format '{{ .NetworkSettings.IPAddress }}' some-joomla

Als we dan naar dit ip-adres gaan zien we joomla verschijnen.

Nu nog automatisch

Installeren van docker is al reeds gedaan

Installeren docker-compose (niet op windows of mac)

	

> Note: If you get a “Permission denied” error, your /usr/local/bin directory probably isn’t writable and you’ll need to install Compose as the superuser. Run sudo -i, then the two commands below, then exit.

	curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

Runpermissies geven: 

	chmod +x /usr/local/bin/docker-compose


Verifieren van installatie: 

	docker-compose --version


Aanmaken van de docker-compose.yml, inhoud komt uit de officiele dockerhubpagina van joomla.

docker-compose.yml:

	joomla:
	  image: joomla
	  links:
	    - joomladb:mysql
	  ports:
	    - 8080:80
	
	joomladb:
	  image: mysql:5.6
	  environment:
	    MYSQL_ROOT_PASSWORD: robby

Run nu dit bestand met: 

	docker-compose up 

Docker gaat dit nu allemaal configureren volgens het bestand. Om te controleren of joomla werkt: 

	http://localhost:8080

Gegevens van de database: 

* Host Name: mysql
* Database Name: joomla
* Database Username: root
* Database Password: robby

> Staat ook in de commando prompt na commando van up


## Toevoegen van de uitbreidingen: 


#### Monitoring
Voor monitoring gebruiken we [Datadog](https://www.datadoghq.com/), hiervoor hebben we een gratis licentie via de [GitHub Student Developer Pack](https://education.github.com/pack). 

Om datadog toe tevoegen hebben we volgende toegevoegd in docker-compose.yml: 

	datadog:
	  image: datadog/docker-dd-agent
	  environment:
	    - API_KEY=__Key_van_datadog__
	  volumes:
	    - /var/run/docker.sock:/var/run/docker.sock
	    - /proc/mounts:/host/proc/mounts:ro
	    - /sys/fs/cgroup:/host/sys/fs/cgroup:ro

Als we nu opnieuw opstarten en naar [Datadog Panel](app.datadoghq/screen/integration/docker) en log hierop in.

#### Orchestration

Hiervoor maken we gebruik van Docker Compose


#### Beveiliging
Beveiliging: [Security](https://github.com/HoGentTIN/p3ops-top-kek/blob/master/Opdracht%204%20Docker/Topics.md#security)

Gebruik van -u flag en de verwijdering van SUID flag om ongeoorloofde access tegen te gaan.

Ook de Monitoring via DataDog is hierbij van toepassing. Er kunnen Monitors toegepast worden op de verkregen data die ons kan verwittigen wanneer iets ongewoons aan het gebeuren is.

####  Klein houden van de images
Check de uitleg over [Microcontainers en de stappen die je kan nemen om de size van containers in te perken.](https://github.com/HoGentTIN/p3ops-top-kek/blob/master/Opdracht%204%20Docker/Topics.md#keep-it-small) 

We zorgen ervoor dat alles op zo weinig mogelijk lijnen geschreven worden en dat update commando's samen met een clean statement worden geschreven.





