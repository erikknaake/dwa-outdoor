In dit hoofdstuk worden de externe interfaces beschreven. Dit is een riskant onderdeel van het project, omdat we geen invloed hebben op de externe interfaces. Hieronder worden de externe interfaces beschreven en welke problemen er mogelijk kunnen ontstaan.

### De belangrijkste externe interfaces

#### MapBox

MapBox is een kaart service die gebruikt wordt om gebruikers antwoord te laten geven op location tasks. Daarbij kunnen deelnemers een punt markeren op de kaart. MapBox moet een longitude en latitude kunnen geven van het punt waarop wordt geklikt.

Er is voor MapBox gekozen, omdat er ervaring mee is binnen het team. Daarnaast voldoet het aan onze functionele en technische eisen.

##### Technische eisen

Het request limiet van MapBox moet toereikend zijn om een user base van 35.000 gebruikers te ondersteunen. Niet alle 35.000 gebruikers zullen bezig zijn met de reisvragen. Hierdoor is MapBox met een gratis limiet van 25.000 toereikend om het prototype te realiseren.

MapBox is een JavaScript plugin en dat sluit aan op ons webproject. Binnen MapBox maken we gebruik van de [Map api](https://docs.mapbox.com/mapbox-gl-js/api/map/) en de [Markers api](https://docs.mapbox.com/mapbox-gl-js/api/markers/).

Bij MapBox moet er rekening mee gehouden worden dat de applicatie afhankelijk is van de CDN van MapBox.

#### MinIO

MinIO is een tool die gebruikt wordt binnen onze applicatie om bestanden gedecentraliseerd op te kunnen slaan maar wel centraal te kunnen benaderen. Een voordeel hiervan is dat de applicatie beter schaalbaar is omdat de uploads over verschillende servers verdeeld kunnen worden. Andere voordelen zijn dat MinIO voor betere data integriteit zorgt en dat clients direct met MinIO kunnen communiceren waardoor de applicatie minder wordt belast.

De applicatie is gebonden aan de protocollen die door MinIO zijn voorgeschreven. De hosting van MinIO is wel in eigen beheer.

#### Oban

Om achtergrondtaken te verwerken zoals het periodiek toekennen van travel credits wordt de job processing tool [Oban](https://github.com/sorentwo/oban) gebruikt. Oban heeft veel features met betrekking tot achtergrond jobs zoals wachtlijsten, unieke en geplande jobs, prioriteiten stellen aan jobs, backups en meer.

Er is gekozen voor de bestaande oplossing Oban, omdat het goed aansluit op de applicatie. Oban ervoor dat dezelfde job niet meerdere keren draait, ook als de applicatie op meerdere nodes draait. Ook zorgt Oban ervoor dat gefaalde jobs opnieuw gedraaid worden. 

Oban vereist het gebruik van PostgreSQL als RDBMS. De applicatie maakt al gebruik van PostgreSQL en daarom is het niet nodig om een extra data opslag toe te voegen. Bij sommige andere job processing tools waarin job historie bijgehouden wordt is dat wel nodig.
