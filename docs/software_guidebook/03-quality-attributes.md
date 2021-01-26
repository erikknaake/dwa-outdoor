# Quality Attributes

In dit hoofdstuk wordt er een overzicht van de belangrijke Quality Attributes gegeven. Deze QA's zijn gedocumenteerd, omdat ze vaak een groot deel van de architectuur beïnvloeden. Het is daarom essentieel dat er in het begin van het project een inventarisatie wordt gedaan van de belangrijkste Quality Attributes.

Per attribuut is beschreven waarom deze belangrijk is voor het project en hoe we deze willen waarborgen. Aan de hand hiervan kunnen we beter onderbouwde architecturele beslissingen maken.

## Reliability

### Availability

#### Toelichting

De beschikbaarheid is het belangrijkste onderdeel van het DwaOutdoor platform, we hebben veel liever dat een upload langer duurt dan dat de hele omgeving omvalt. Teams moeten door kunnen blijven werken.

We gaan availability bereiken door al van te voren de mogelijke performance [risico's](../PLAN_VAN_AANPAK.md#risicos) in kaart te brengen. Per risico hebben we gekeken welke aanpakken/technieken we kunnen gebruiken om deze te minimaliseren.

Zo hebben we onderzoek gedaan naar [Minio](https://min.io/) waarmee clients direct naar een gedistribueerde opslag kunnen schrijven zonder tussenkomst van een eigen server. Minio heeft ook een interface waarmee gecommuniceerd kan worden met de gedistribueerde opslag alsof het een centrale opslag is. Daarnaast zorgt Minio ook voor [recoverability](https://docs.d2iq.com/mesosphere/dcos/services/minio/0.1.0/operations/recover/) van bestanden in het geval van disk-failure of als een node tijdelijk niet beschikbaar was.

#### Aanpak

Tijdens het ontwikkelen van het platform gebruiken we verschillende technieken zoals [LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) die het Phoenix platform standaard meelevert. Hiervan weten we dat deze uitgebreid zijn getest en [battle-tested](https://haughtcodeworks.com/blog/software-development/elixir-phoenix-liveview/) zijn.
Naast het gebruiken van de standaard tools wordt er ook gekeken hoe markt-leiders zoals [AWS](https://aws.amazon.com/) bepaalde beschikbaarheids uitdagingen aanpakken. Zo gaan we de [best-practices](https://docs.aws.amazon.com/AmazonS3/latest/dev/optimizing-performance.html) toepassen die zijn opgesteld voor het enorm schaalbare [S3](https://aws.amazon.com/s3/) platform.

#### Wanneer hebben we dit behaald?

Het availability quality attribute is bereikt als afbeeldingen en video's geupload kunnen worden zonder dat een centrale server hier een kritieke rol in speelt. Ook moeten deze afbeeldingen en video's binnen 15m(bij bestandsgrootte van maximaal **100mb** met 20,28 Mbps upload) inzichtelijk zijn voor de jury en deelnemende groepen.

#### Eindbeoordeling

Het eerste beoordelingsaspect van dit quality attribute is behaald. Door het gebruik van MinIO is het mogelijk om de bestanden gedecentraliseerd op te slaan. Binnen de opgestelde applicatie worden de uploads en downloads van bestanden over verschillende servers verdeeld. Een punt wat de availability mogelijk negatief beïnvloed is de loadbalancer. Hierover staat meer geschreven in het hoofdstuk [Infrastructure Architecture - Beperkingen](./10-infrastructure-architecture.md#beperkingen).

Het tweede beoordelingsaspect van dit quality attribute is aan de hand van de [MinIO Docs](https://min.io/resources/docs/MinIO-Throughput-Benchmarks-on-HDD-24-Node.pdf) ook behaald. Op deze bron is te zien dat de throughput van een MinIO Object Storage server zat toereikend is. Het ontwikkelteam is er niet aan toegekomen dit binnen de applicatie te testen.

### Recoverability

#### Toelichting

Door de vele groepen en het data volume is de kans dat de applicatie overbelast raakt een realistisch scenario waar rekening mee gehouden moet worden. Het mag niet zo zijn dat door een lang durende upload van een van de teams de andere teams niet meer kunnen uploaden.

Daarnaast moeten de verschillende onderdelen van het systeem geen harde afhankelijkheden van elkaar hebben. Zo zou de web-applicatie voor het bekijken van opdrachten beschikbaar moeten blijven als een van de upload-services niet meer beschikbaar is.

#### Aanpak

Bij het opzetten van het DwaOutdoor platform worden de verschillende componenten waar mogelijk opgesplist. Hiervoor gebruiken we de [umbrella projects](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html#umbrella-projects) structuur van het [Phoenix](https://www.phoenixframework.org/) framework. Hiermee kunnen we een algemeen project hebben met de business logica en deze code direct gebruiken in de verschillende applicaties zoals de web-applicatie met opdrachten en de upload service.

Door het al in het begin op te delen kunnen de applicaties los van elkaar draaien en kunnen deze onafhankelijk worden gestart/gestopt/herstart. Ook maakt dit horizontaal schalen toegankelijker.

#### Wanneer hebben we dit behaald?

Dit quality attribute is behaald als containers zonder consequenties van de bruikbaarheid van de applicatie gestopt kunnen worden door bijvoorbeeld [chaosmonkey](https://netflix.github.io/chaosmonkey/).

Zo moet bijvoorbeeld een van de bestand-upload services gestopt kunnen worden zonder dat dit impact heeft op eindgebruikers. De teams moeten nog steeds bestanden kunnen uploaden maar dan via een andere docker instantie.

#### Eindbeoordeling

Het ontwikkelteam is er nog niet aan toegekomen om dit Quality Attribute Scenario te testen met chaosmonkey. Theoretisch gezien is de applicatie wel zo opgesteld dat het kan, het is enkel nog niet in de praktijk getest.

### Fault tolerance

#### Toelichting

In de DwaOutdoor applicatie worden er verschillende doe-opdrachten uitgevoerd waarvan het resultaat wordt vastgelegd met afbeeldingen en videos. Deze afbeeldingen en videos worden door veel teams gelijktijdig geüpload om door de reisleiders beoordeeld te worden. Dit uploaden wordt vaak gedaan over langzame en instabiele netwerken waardoor onderbrekingen vaak voorkomen.

#### Aanpak

Vanuit praktijkervaring als deelnemer van [iScout](https://iscoutgame.com/), is bekend dat het vele bestanden uploaden vaak de oorzaak is van een niet beschikbare omgeving. Om dit af te vangen gaan we het uploaden van bestanden gedistribueerd op zetten en over meerdere servers verdelen.

Door het gedistribueerd uploaden van bestanden is het platform een stuk schaalbaarder, echter introduceert het ook extra uitdagingen. Zo is het een stuk lastiger om [ACID](https://mariadb.com/resources/blog/acid-compliance-what-it-means-and-why-you-should-care/) toe te passen.

Het mag niet zo zijn dat een deel van de data verloren is als een node of hard-disk uitvalt. Het platform moet zodanig worden ingericht dat bestanden van offline nodes gerecoverd kunnen worden en deze ook beschikbaar zijn voor de reisleiders en deelnemende teams.

Om de beste aanpak te bepalen is er gekeken naar hoe bijvoorbeeld AWS zelf diensten fault-tolerant heeft opgesteld([whitepaper AWS](https://docs.aws.amazon.com/whitepapers/latest/fault-tolerant-components/fault-tolerant-components.pdf)) en wat vergelijkbare platformen bieden(zoals het highly-available storage system van [minio](https://docs.min.io/docs/distributed-minio-quickstart-guide.html)) om met fouten om te gaan.

#### Wanneer hebben we dit behaald?

Het Fault tolerance quality attribute is behaald als bestanden die geüpload zijn door teams nog steeds te benaderen zijn als een van de bestand-upload services niet meer bereikbaar is. Het moet dus zo zijn dat de bestanden niet allemaal op een enkele plek zijn opgeslagen, maar verdeeld opgeslagen zijn en te recoveren zijn.

#### Eindbeoordeling

Het beoordelingsaspect van het Quality Attribute "Fault Tolerance" is behaald. Door gebruik te maken van MinIO als Object Storage server, is het mogelijk om meerdere MinIO containers te draaien. MinIO maakt het mogelijk om gedecentraliseerd bestanden te uploaden, en ze centraal te downloaden. Waneer één van de MinIO containers stopt met werken, is het nogsteeds mogelijk om de bestanden via een andere MinIO container te benaderen. Een mogelijk gevaar voor dit quality attribute is de load balancer. Hierover staat meer beschreven in het hoofdstuk [Infrastructure Architecture](./10-infrastructure-architecture.md) (Beperkingen).

## Performance efficiency

### Capacity

#### Toelichting

Het bewijs voor uitgevoerde doe-opdrachten wordt door teams geleverd in de vorm van afbeeldingen en video's. Er doen rond de 200-300 teams mee die voor elk van de ~20 doe-opdrachten een video van gemiddeld 15mb indienen.

Dit loopt al snel op tot vele gigabytes, het is daarom belangrijk om te kijken of de gekozen architectuur bijvoorbeeld [horizontal schaling](https://www.ibm.com/blogs/cloud-computing/2014/04/09/explain-vertical-horizontal-scaling-cloud/) ondersteund om mee te schalen.

#### Aanpak

De opslag voor de afbeeldingen en video's willen we zo gedecentraliseerd mogelijk gaan opzetten. Door het gedecentraliseerd regelen van de opslag is er geen centraal punt waar alle data langs moet, dit wordt gedaan om vanaf het begin al met meerdere instanties rekening te houden.

Door de capaciteit en workload te verdelen over meerdere instanties is het upload proces minder foutgevoelig. Ook is hiermee de oplossing horizontaal schaalbaar wat inhoud dat er meer instanties toegevoegd kunnen worden voor meer capaciteit en niet een enkele mega server steeds uitgebreid hoeft te worden.

#### Wanneer hebben we dit behaald?

Het capacity quality attribute is behaald als de opslagruimte voor het uploaden van afbeeldingen en video's uitgebreid kan worden zonder dat gebruikers van het platform hier hinder van ondervinden.

#### Eindbeoordeling

Het team is nog niet in staat geweest om dit Quality Attribute Scenario te testen. Theoretisch gezien zou het mogelijk moeten zijn doordat MinIO los van de front- en backend staat. Het zou mogelijk moeten zijn om een nieuwe MinIO instance te starten en deze instance gebruik te laten maken van de nieuwe opslagruimte, zonder dat gebruikers hier hinder van ondervinden. Verder is het ook mogelijk om Phoenix op te schalen indien nodig. Dit heeft een positief effect op het Quality Attribute "Capacity".

## Maintainability

### Testability

#### Toelichting

Tijdens het ontwikkelen zal er voornamelijk worden getest met één tot maximaal 3 teams, terwijl we hiermee functioneel kunnen testen of het naar behoren werkt, geeft dit geen realistisch beeld van de productie gebruikerspatronen.

Het is daarom belangrijk dat productie scenario's met een focus op gelijktijdige gebruikers getest kan worden. Hierdoor kan er met grotere zekerheid aangegeven worden of het platform de piekbelasting aan kan.

#### Aanpak

Voor de schaalbaarheid en recoverability hebben we umbrella projects ingezet, deze lenen zich ook erg goed voor het draaien in [Docker](https://www.docker.com/) containers. De projecten kunnen namelijk geïsoleerd draaien en individueel worden opgeschaald.

Doordat de Docker containers voor een geïsoleerde omgeving zorgen met [precieze controle](https://docs.docker.com/config/containers/resource_constraints/) over de beschikbare resources kunnen veel scenario's worden getest.
Zo is het mogelijk om load testing te doen via [tsung](http://tsung.erlang-projects.org/user_manual/introduction.html) of [JMeter](https://jmeter.apache.org/). Tijdens het load-testen is precies te zien hoeveel resources worden gebruikt en hoe de containers meeschalen.

Ook kan er worden gegeken hoe bijvoorbeeld [autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) van kubernetes ervoor kan zorgen dat resources worden toegevoegd bij hoge belastig op de applicatie.

#### Wanneer hebben we dit behaald?

Dit quality attribute is behaald als we met een load-testing tool als [tsung](http://tsung.erlang-projects.org/user_manual/introduction.html) kunnen meten hoe veel gebruikers onze applicatie aan kan. Het eindresultaat kan een testrapport zijn met daarin het maximaal aantal concurrent gebruikers en de pagina's die het langzaamste presteren bij veel gebruikers.

#### Eindbeoordeling

Er zijn voor dit Quality Attribute Scenario een aantal load-tests uitgevoerd met Tsung, echter is hier nog geen testrapport van uitgebracht. Het team is tevreden met het resultaat van de uitgevoerde loadtests, maar heeft dit Quality Attribute Scenario niet behaald.
