# Lastenboek Taask 4: Deploying a webapplication with Docker + documentation

* Verantwoordelijke uitvoering: Bono, Robby, Siebert
* Verantwoordelijke testen: Bono, Robby, Siebert

## Deliverables

- Via Docker een webapplicatie laten runnen, zodat deze via de cloud onafhankelijk van de werkplaats gebruikt kan worden.
- Alles moet geautomatiseerd zijn. De hele infrastructuur is reproduceerbaar aan de hand van wat in de Github repos staat.
- Bestudeer en documenteer de volgende discussiepunten in de Docker community, en pas wat je vindt toe in jullie proof-of-concept.
	- Is een Docker container voldoende beveiligd? Kan je vanuit een Docker container het hostsysteem overnemen? Wat zijn de best practices om de beveiliging zo goed mogelijk te maken?
	- Hoe maak je Docker images zo klein mogelijk? Waar moet je op letten bij het schrijven van Dockerfiles (het configuratiebestand dat beschrijft hoe de container moet aangemaakt worden).
	- Als je het principe van een microkernel volgt, mag er maximum één service per container draaien. Wat dan met schijnbaar essentiële zaken als sshd of journald/syslog (de logging service)? Hoe kan je dan toegang krijgen tot de container om eventuele problemen op te lossen?
	- Monitoring: hoe kan je best de processen binnen een Docker container opvolgen? Zelfde vraag voor alle containers als geheel, en hoe die het hostsysteem of -systemen belasten
	- Orchestration: het opstarten en beheren van containers moet gecoördineerd gebeuren: als een webserver opstart, moet de database bijvoorbeeld al beschikbaar zijn

## Deeltaken

* Opdracht 3: Bestudeer en documenteer discussiepunten
	* Beveiliging - Bono
	* Images - Bono
	* Containers en Services - Bono
	* Monitoring - Siebert
	* Orchestration - Robby
* Webapplicatie laten lopen via Docker
* Automatisering met GitHub repo

## Tijdbesteding

| Student  | Geschat | Gerealiseerd |
| :---     |    ---: |         ---: |
| Siebert |   12 uur     |        15:19      |
| Robby |    14 uur    |      18:03        |
| Bono |   12 uur    |       14:06       |

![](https://i.gyazo.com/81239ef322c641a32c75860fc5c81676.png)