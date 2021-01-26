# Plan van aanpak
## Casus DwaOutdoor
DwaOutdoor is gebaseerd op het [iScout concept](https://iscoutgame.com/). iScout is een concept in de scouting wereld dat is begonnen in Nederland, inmiddels doen er jaarlijks 300 tot 600 teams mee, met elk 8-50 deelnemers. Daarnaast zijn er juryleden, ook wel reisleiding genoemd. Sinds enkele jaren wordt iScout ook in het buitenland gespeeld. 


Bij iScout zijn teams op te delen in twee delen. Een deel van het team is bezig met “doe-opdrachten”, dit zijn uitdagingen die de groep kan uitvoeren. Je kan denken aan het opzetten van een bowling baan in een winkel of het maken van een voertuig die door bladblazers wordt verplaatst. Het is de bedoeling dat het team van zoveel mogelijk opdrachten uitvoert en bewijs in de vorm van een foto of filmpje inlevert.


Na het inleveren van een doe-opdracht zal de reisleiding dit zo snel mogelijk beoordelen, wanneer de ingediende foto/video aan de opdrachtomschrijving voldoet krijgt het team twee reiscredits, als het fout is mag het team het opnieuw proberen. Daarnaast krijgt elk team elk half uur een gratis reiscredit.


Van deze reiscredits kan het team reisvragen kopen, deze worden beantwoord door het andere deel van het team. Een reisvraag bestaat uit een omschrijving van een bepaalde locatie in de wereld, dit kan een kerk zijn met een bepaalde bijnaam of een klok met een bijzondere eigenschap. Het team moet dan zien uit te vogelen welke locatie wordt bedoeld, het antwoord is de google maps locatie van het omschreven object.

Na een juist antwoord krijgt het team een reispunt en kan het de volgende vraag in de track kopen. Is het antwoord fout, dan mag het team het na 5 minuten opnieuw proberen.  Er lopen drie tracks van vragen parallel aan elkaar, een team heeft op elk moment dus toegang tot maximaal drie vragen. Wanneer een team een vraag niet kan beantwoorden kunnen zij een bezembever inzetten, dan krijgen ze geen punten voor die vraag en kunnen ze de volgende vraag in de track kopen. Een team moet steeds 15 minuten wachten voordat het een nieuwe bezembever kan gebruiken.

Als laatste kan een team 2 reispunten inleveren om een werkstuk te maken, een grote opdracht waar 1, 2, 4 of 6 punten mee verdiend kunnen worden. Het uiteindelijke doel van het spel is om zoveel mogelijk reispunten te verzamelen door de verschillende opdrachten uit te voeren.

Wij hebben als groep ervoor gekozen om dit concept uit te werken omdat er veel verschillende realtime aspecten inzitten en er veel technische uitdagingen zijn. Het is namelijk zo dat dit al meerdere jaren wordt uitgevoerd maar dat elke keer de servers overbelast raken en niet beschikbaar zijn.

In dit project gaan we bezig met het ontwikkelen van een platform die niet alleen deze hoofd functionaliteiten en activiteiten ondersteund maar ook schaalbaar is en de enorme piek-belasting aan kan. Dit gaan we doen door met Elixir en Phoenix een cloud native applicatie te realiseren.

## Uitdagingen
| Onderwerp          | Uitdaging                                                                                                                                                                                        |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Realtime           | Realtime inzicht in feedback op opdrachten, gescoorde punten, resterende tijd voor verschillende spel-onderdelen.                                                                                 |
| Bestanden uploaden | Oplossingen voor opdrachten worden vaak tegelijk geupload, hierdoor kan het zo zijn dat 30 teams tegelijk een 150mb video indienen. Dit proces moet ook correct verlopen onder zware belasting.                                                             |
| Background processing | Er zijn verschillende aspecten zoals punten toewijzen die met een vaste interval uitgevoerd moeten worden. Dit moet altijd op hetzelfde moment gebeuren en gesynchroniseerd worden over clients. Hiervoor kan naar Cron Jobs gekeken worden. |
| Schaalbaarheid     | Er is veel piek belasting, vaak leveren alle teams het rond het zelfde moment een antwoord aan. De belasting kan hierdoor sterk varieëren tussen een paar kleine aanvragen tot vele grote aanvragen.       |
| Availability       | De beschikbaarheid is het belangrijkste onderdeel van dit platform, we hebben veel liever dat een upload langer duurt dan dat de hele omgeving omvalt. Teams moeten door kunnen blijven werken.  |

## Groepsafspraken
* Elk teamlid streeft naar 40 uur per week.
* Wanneer een teamlid niet aanwezig kan zijn bij een meeting licht hij het team een dag van te voren of dezelfde dag voor 9:00 in.
* Bij sprake van ziekte of andere omstandigheden waardoor werken niet mogelijk is voor 9:00 teamleden inlichten.
* Afwezigheid in verband met bijvoorbeeld een stagecontract tekenen een dag van te voren melden of dezelfde dag voor 9:00.
* Elke ochtend om 9:00 is er een standup, indien behoefte om 14:00 ook.
* De tooling van GitHub wordt gebruikt.
* Documentatie wordt in markdown geschreven.

## Rollen
| Rol                                     | Wie          |
|-----------------------------------------|--------------|
| Maarten                                 | Scrum master |
| Product owner                           | Erik         |
| Ontwikkelaar                            | Iedereen     |
| Tester                                  | Iedereen     |
| Verantwoordelijke testen(load/end-tend) | Dennis       |

## Risico’s
### Actuele Risico's
| Risico                                                                                                                            | Aanpak om risico te minimaliseren                                                                                                                                                                                                                         | Status risico                                                                                                                                                                                                                                                                                                                                           |
|-----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Het schaalbaar maken met load-balancing tussen nodes is erg complex en krijgen we niet consistent werkend.                         | Verdiepen in de tooling die kubernetes biedt voor het verdelen van traffic over verschillende instanties van de app.                                                                                                                                      | We gaan een experiment opgezetten met een kubernetes ingress control van nginx: [kubernetes-ingress](https://kubernetes.github.io/ingress-nginx/deploy/). Deze service draait in het kubernetes cluster en kan aanvragen verdelen over verschillende containers.                                                                                                                  |

### Afgevangen risico's
| Risico                                                                                                                            | Aanpak om risico te minimaliseren                                                                                                                                                                                                                         | Status risico                                                                                                                                                                                                                                                                                                                                           |
|-----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Het schaalbaar uploaden van bestanden vereist veel kennis van data transfer protocollen en dus lastiger te realiseren.            | Onderzoek naar libraries die gedistribueerd bestanden uploaden mogelijk maken.                                                                                                                                                                            | Er is onderzoek gedaan naar mogelijke opties, [Minio](https://github.com/minio/minio) is een van deze opties en maakt het gedistributeerd uploaden mogelijk. Dit risico is daarom nu grotendeels afgevangen.                                                                                                                                            |
| De ICA omgeving voor het deployen van docker/kubernetes is niet beschikbaar.                                                      | Een eigen AWS/azure account hebben om daar een kubernetes cluster te draaien. Een andere optie is lokaal draaien van kubernetes of docker-swarm.                                                                                                          | Er is een [POC](https://github.com/erikknaake/PhoenixReactVsLiveView/blob/master/liveViewTest_umbrella/docker-compose.yml) gemaakt met het lokaal draaien van een phoenix applicatie aan de hand van docker-compose. Hierdoor is het risico afgevangen omdat we het sowieso lokaal kunnen draaien.                                                      |
| De omgeving heeft niet genoeg resources om grote aantallen aanvragen te verwerken.                                                | Er wordt met stress-testing tools(zoals [tsung](http://tsung.erlang-projects.org/user_manual/introduction.html)) gekeken hoeveel aanvragen er mogelijk zijn en in wat hierin de verhoudingen zijn. Dit kan dan doorgerekend worden tot het doel scenario. | Er zijn verschillende load testing tools opgezocht([tsung](http://tsung.erlang-projects.org/user_manual/introduction.html) en [JMeter](https://jmeter.apache.org/)) waarmee de applicatie lokaal op performance getoetst kan worden. Hierdoor is het risico grotendeels afgevangen omdat we bij missende resources wel een inschatting kunnen maken.  |
| Bestanden uploaden met meerdere nodes blijkt niet mogelijk te zijn zonder eigen protocollen te schrijven.                         | Een library gebruiken die gedistribueerde file uploads mogelijk maakt.                                                                                                                                                                                    | Afgevangen met Minio, zie eerste risico.                                                                                                                                                                                                                                                                                                                |
| Het kost veel tijd om OpenStack te leren kennen, hierdoor krijgen we de applicatie niet op tijd draaiend                          | De applicatie lokaal draaien in kubernetes([minikube](https://github.com/kubernetes/minikube)) of [docker-swarm](https://docs.docker.com/engine/swarm/).                                                                                                  | Minikube is door teamleden al lokaal geïnstalleerd en dat kan worden gebruikt om een productie omgeving te simuleren. Daarnaast is er al ervaring met managed kubernetes op AWS, dat ook ingezet kan worden. Dit risico is daarom redelijk afgevangen.                                                                                                  |
| De kubernetes concepten leren kost veel tijd waardoor we applicatie niet gedeployed krijgen.                                      | Inplaats van kubernetes [docker-compose](https://docs.docker.com/compose/) inzetten om meerdere containers tegelijk te beheren.                                                                                                                           | Met een [POC](https://github.com/erikknaake/PhoenixReactVsLiveView/blob/master/liveViewTest_umbrella/docker-compose.yml) hebben we het voor elkaar gekregen om een phoenix applicatie al in docker-compose in te richten. Hierdoor hebben we dit als stabiele backup optie als kubernetes niet werkt.                                                   |
| Version conflicts, een dependency vereist een versie van een peer dependency die conflicteert met een andere peer dependency eis. | Proberen zoveel mogelijke stabiele releases of release candinates te gebruiken zodat de compatibiliteit al door de ontwikkelaars is getest.                                                                                                               | Er waren een aantal dependencies die nog niet officieel waren uitgeleverd(waaronder [phoenix file uploads](https://phoenixframework.readme.io/v0.15.0/docs/file-uploads)), nu zijn deze packages wel als RC uitgeleverd. Dit is wel nog een risico om goed op te letten omdat er veel experimentele technieken worden gebruikt.                              |
## Ontwikkelmethode
### Methode
Binnen dit project is ervoor gekozen om gebruik te maken van SCRUP™. Dit is een light-weight ontwikkelmethode die aspecten van RUP en SCRUM gebruikt. Binnen dit project zullen wij als projectgroep gebruik maken van de inception- en elaboration-fase van RUP. 


De inceptionfase wordt gebruikt om de haalbaarheid van de opdracht uit te werken, een product vision en minimalistische scope vast te stellen, risico’s te identificeren. Verder wordt er ook een (zeer kleinschalig) prototype gebouwd.


De elaboratiefase wordt gebruikt om gedetailleerde requirements in kaart te brengen, en om de risk assessment aan te scherpen (prototypes voor mogelijke risico’s). Verder wordt de architectuur kleinschalig uitgewerkt.


Gedurende de construction fase wordt er aan de hand van SCRUM gewerkt. Hier worden de requirements uitgewerkt, en wordt er op een incrementeel iteratieve manier aan de implementatie gewerkt. Hier wordt aan de hand van user-stories aan gewerkt. Het resultaat van deze fase is de source-code en een overzicht van punten waarop de software is getest. 


Binnen het SCRUM-gedeelte van deze fase zullen we werken met sprints van twee weken. Uiteindelijk worden er dus drie sprints doorlopen in de constructionfase.


* Phase 1: Inception & Elaboration (week 1 - 2)
* Phase 2: Construction (week 3 - 8)
Toelichting
Er is gekozen voor SCRUP™ binnen dit project omdat er met een onbekende technology-stack gewerkt gaat worden. Er is binnen het ontwikkelteam nog geen ervaring met de stack, en er was aan het begin ook nog geen duidelijk beeld van een opdracht. 


Dit zijn punten die goed bij RUP aansluiten. Bij RUP ligt er in de eerste twee fases veel nadruk op het uitzoeken van risico’s en het verduidelijken van de opdracht. Verder wordt er ook gekeken hoe de effecten van de risico’s geminimaliseerd kunnen worden, of hoe er omheen gewerkt kan worden. 


In de constructie fase binnen RUP is het de bedoeling dat er iteratief gewerkt wordt. Binnen het team is er ervaring met SCRUM. De iteratief-incrementele werkwijze van SCRUM sluit goed aan bij dit project. Op deze manier is er veel inzicht in de voortgang van de applicatie, en kunnen er gemakkelijk aanpassingen binnen de applicatie gemaakt worden indien een bepaalde functionaliteit toch niet naar behoren bevalt. Het incrementele karakter sluit ook goed aan op de opdracht, omdat hier veel uitbreidingen bij bedacht kunnen worden.


Om het kort samen te vatten; SCRUP™ wordt gebruikt om belangrijke details aan het begin in kaart te brengen, en om bewust te worden van de risico’s. Vervolgens wordt er met SCRUM gewerkt, vanwege de flexibiliteit, en transparantie.


## Mogelijke schermen
De onderstaande schermen bevatten verschillende uitdagende aspecten zoals het realtime bijwerken van informatie en het schaalbaar laten indienen van antwoorden.

* Home
* Inschrijven
* Doe opdrachten
   * Dit kan als een scrumboard zodat een team zijn voortgang kan bijhouden
   * Real time gesynct, als een inlevering goed is, naar done, is het fout, terug naar todo
* Doe opdracht inleveren
   * Vraag selecteren
   * File upload
* Beoordelen doe opdrachten
   * Automatisch updaten wanneer nieuwe inleveringen binnenkomen
   * Voorkomen dat meerdere juryleden dezelfde inlevering gaan beoordelen
* Puntenoverzicht
   * Aantal reiscredits
   * Aantal reispunten
   * Aantal bezembevers gebruikt
   * Tijd tot volgende bezembever
   * Nummer van de vraag in elke track
   * Voor elke track tijd tot nieuwe poging
   * Allemaal realtime
   * Rivalen bekijken
* Track
   * Vraag
   * Tijd tot nieuwe poging (realtime syncen met team)
   * Kaart voor antwoord
   * Automatisch naar volgende Reisvraag kopen wanneer ander teamlid juist antwoord
* Reisvraag kopen
   * Aantal reiscredits (realtime)
* Rivalen instellen
   * Kiezen uit een lijst met deelnemers (doorzoekbaar)
* Rivalen bekijken
   * Overzicht alle rivalen
   * Aantal reiscredits
   * Aantal reispunten
* “Helpdesk” chat
    * Chat tussen team & organisatoren


## Concepten
* Editie
   * Datum
   * DoeOpdrachten
   * Tracks
      * Reisvragen
         * Antwoord
         * Longitude
         * Latitude
         * Foutmarge
* Inschrijvingen
* Team
   * Reiscredits
   * Reispunten
   * Antwoorden
      * Vraag
      * Longitude
      * Latitude
      * DateTime
   * Werkstuk
   * DoeOpdrachtInlevering
        * Status
