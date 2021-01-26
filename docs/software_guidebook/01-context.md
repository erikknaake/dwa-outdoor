In dit hoofdstuk wordt ingegaan op de casus van het software product. Daarnaast wordt beschreven wat er gebouwd zal gaan worden en wie dit software product in gebruik zullen nemen.

#### Software product

Het software product dat gebouwd zal worden heet DwaOutdoor. DwaOutdoor is gebaseerd op iScout. iScout is een concept in de scouting wereld dat begonnen is in Nederland. Inmiddels doen er jaarlijks 300 tot 600 teams mee, met elk 8-50 deelnemers. Daarnaast zijn er juryleden, ook wel reisleiding genoemd. Sinds enkele jaren wordt iScout ook in het buitenland gespeeld.

In de DwaOutdoor applicatie zijn teams op te delen in twee delen. Een deel van het team is bezig met doe-opdrachten. Dit zijn uitdagingen die de groep kan uitvoeren. Hierbij kan gedacht worden aan het opzetten van een bowlingbaan in een winkel of het maken van een voertuig die door bladblazers wordt verplaatst. Het is de bedoeling dat een team zoveel mogelijk doe-opdrachten uitvoert en het bewijs hiervan in de vorm van een foto of filmpje upload in de applicatie.

Na het inleveren van een doe-opdracht zal de reisleiding (jury) de doe-opdracht beoordelen. Wanneer de ingediende foto's en/of video's aan de opdrachtomschrijving voldoen, krijgt een team een aantal reiscredits als beloning. Als de doe-opdracht niet goed is uitgevoerd, mag een team het opnieuw proberen. Daarnaast krijg elk team elk halfuur een gratis reiscredit.

Van deze reiscredits die een team verdiend, kan een team reisvragen kopen. Reisvragen worden door het andere deel van een team beantwoord. Een reisvraag bestaat uit een omschrijving van een specifieke locatie in de wereld. Dit kan bijvoorbeeld een kerk zijn met een bepaalde bijnaam of een klok met een bijzondere eigenschap. Het team moet dan zien uit te vogelen welke locatie wordt bedoeld. Het antwoord is de locatie van het object op een kaart.

Als een team de reisvraag juist beantwoord, krijgt het een aantal reispunten en kan het de volgende vraag in de track kopen. Is het antwoord fout, dan mag het team het na vijf minuten opnieuw proberen. Er lopen drie tracks van vragen parallel aan elkaar. Een team heeft op elk moment dus toegang tot maximaal drie vragen. Wanneer een team een vraag niet kan beantwoorden, kunnen zij een bezembever inzetten. Ze krijgen dan geen punten voor die vraag, maar kunnen wel de volgende vraag in de track kopen. Een team moet steeds vijftien minuten wachten voordat het een bezembever kan gebruiken.

Als laatste kan een team twee reispunten inleveren om een werkstuk te maken. Een werkstuk is een grote doe-opdracht waar 1, 2, 4 of 6 punten mee verdiend kan worden. Het is uiteindelijk het doel om zoveel mogelijk reispunten te verzamelen door de verschillende opdrachten uit te voeren.

#### Applicaties

Er zal één webapplicatie gebouwd worden. In deze applicatie zullen teams het spel kunnen spelen aan de hand van verschillende spelonderdelen waarbij bestanden geüpload kunnen worden en locaties op een kaart ingediend kunnen worden. Daarnaast zullen reisleiders in deze applicatie de ingediende bewijzen en werkstukken kunnen beoordelen.

In deze web applicatie zullen wijzigingen in het systeem (near) real-time geupdate worden. Zo zal een team real-time inzicht krijgen in feedback op doe-opdrachten, gescoorde punten en resterende tijd voor verschillende spel-onderdelen. De data in deze applicatie wordt opgeslagen in een database.

#### Actoren

De applicatie zal gebruikt worden door een aantal actoren.

| Actor | Beschrijving |
| --- | --- |
| Teamlid | <ul><li>Speelt als lid van een team mee aan DwaOutdoor.</li> <li>Voert doe-opdrachten uit en upload hiervan het bewijs, dient coördinaten in als uitkomst van reisvragen en upload werkstukken.</li></ul> |
| Teamleider | <ul><li>Speelt als leider en lid van een team mee aan DwaOutdoor.</li><li>Meld een team aan bij een editie.</li></ul>
| Reisleider | <ul><li>Keurt bewijs van doe-opdrachten die door teams zijn ingediend goed of fout.</li> <li>Kent punten toe aan werkstukken die door teams zijn ingediend.</li></ul> |
| Organisator | <ul><li>Maakt nieuwe reisvragen aan die teams tijdens een editie moeten beantwoorden.</li><li>maakt nieuwe doe-opdrachten aan die teams tijdens een editie moeten uitvoeren.</li><li>Maakt nieuwe werkstukken aan die teams tijdens een editie moeten maken</li><li>Stelt co-organisators en reisleiders aan voor een editie</li></ul> |
| Co-organisator | <ul><li>Maakt nieuwe reisvragen aan die teams tijdens een editie moeten beantwoorden.</li><li>maakt nieuwe doe-opdrachten aan die teams tijdens een editie moeten uitvoeren.</li><li>Maakt nieuwe werkstukken aan die teams tijdens een editie moeten maken</li></ul> |
| Admin | <ul><li>Maakt edities aan waar teams zich voor kunnen aanmelden</li><li>Stelt andere admins aan</li></ul> |
