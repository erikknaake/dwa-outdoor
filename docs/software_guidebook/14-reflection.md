Dit hoofdstuk bespreekt hoe het team de gemaakte keuzes beschouwt met de kennis die aan het einde van het project beschikbaar is.
Daarnaast worden in dit hoofdstuk ervaringen over het gebruik van Phoenix beschreven.
Deze punten werden niet belangrijk genoeg gevonden om binnen dit project opgelost te worden, omdat het niet zo vertragend werkte en wel functioneerde, 
de punten oplossen zou waarschijnlijk meer tijd kosten dan dat ze in dit project nog zouden opleveren.

## Code generatie / Indeling domain project

In het begin van het project zijn de contexts door commands gegenereerd.
Dit had het voordeel dat het database schema snel in code kon worden omgezet.
Deze commands genereerde echter per context een mapje waarin alleen het schema staat.
Dit zorgt ervoor dat je langer op zoek bent naar de code die je nodig hebt. Achteraf was het beter geweest om dit in te delen in concepten die sterk bij elkaar horen,
bijvoorbeeld de `practical_task_team` bij de `practical_task`. 

## Gebruik contexten

Het gebruik van contexts die elk verantwoordelijk zijn voor een klein stukje domain is erg goed bevallen.
Dit vooral doordat de context dan eventuele PubSub interactie kan doen, wat integratie voor live updates enorm vereenvoudigde.
Wij geloven dat in combinatie met het feit dat PubSub over meerdere instanties heen werkt de grote kracht van Phoenix is.

Hier en daar staat er nog wat veel code in de Live View controllers, dit had gedeeltelijk nog naar contexts kunnen worden verplaatst of naar losse modules in het domain project.
De contexts zijn nu verantwoordelijk voor de database interactie en (een deel van) de domeinlogica, 
het is voor projecten met meer domein logica zeker het overwegen waard om deze verantwoordelijkheden in losse modules te plaatsen.

## Componenten / Phoenix documentatie

Het gebruik van componenten is het team een beetje tegen gevallen, zeker met de betere ervaring van React hierin. 
Binnen Phoenix gelden er een aantal regels binnen componenten die niet altijd even duidelijk waren gedocumenteerd.
Zoals het feit dat een `live_upload` niet in een component kan worden gebruikt en dat bepaalde helper functies alleen beschikbaar worden als er een `use Phoenix.Html` aanwezig is, terwijl dit in een live view wel standaard beschikbaar is.
Dit zorgt ervoor dat er soms veel tijd verloren gaat aan iets dat in components gewoon niet goed werkt.
Dit in combinatie met de soms niet werkende code voorbeelden in de officiële documentatie van libraries als Phoenix en Ecto, zoals het uploaden van bestanden en het leggen van relaties.
De niet werkende code voorbeelden doen het framework minder volwassen aanvoelen en zal de grootste reden zijn die ervoor zorgt dat Phoenix niet door veel meer developers wordt gebruikt.

Een ander gat in de documentatie betrekt het maken van releases met runtime configuratie, er zijn hier twee tools voor (mix en distillery) die in een aantal aspecten te veel op elkaar lijken, 
waardoor guides die zeggen over de ene te gaan toch over de andere gaan en dus niet functioneren. Het feit dat deze guides de tools door elkaar halen laat blijken dat de informatie hierover van meerdere plaatsen moet worden verzameld.
Bovendien is de zoekterm "mix release" niet de eerste waar je aan denkt als je een phoenix applicatie wilt deployen. Runtime configuratie is onmisbaar voor het gebruik met kubernetes, maar is zwaar onderbelicht in de documentatie.
Waardoor hier veel uren in zijn gestoken, terwijl er wel een degelijke oplossing bestaat binnen mix releases.

Uiteindelijk komt het probleem in deze documentatie neer op het feit dat functies goed zijn beschreven, maar dat de samenhang niet altijd goed is beschreven en dat de documentatie hierdoor niet altijd voor beginners geschikt is.


## Code hergebruik

Er zijn nu een aantal stukken code die vaak in de applicatie voorkomen, bijvoorbeeld de definitie voor een broadcast en subscribe, waarvan we eigenlijk maar 3 varianten kennen in de applicatie.

```elixir
@topic "practical_tasks"
  def subscribe do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @topic)
  end

  def subscribe(practical_task_team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{practical_task_team_id}")
  end

  def broadcast({:ok, practical_task_team}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{practical_task_team.team_id}",
      {event, practical_task_team}
    )

    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @topic,
      {event, practical_task_team}
    )

    {:ok, practical_task_team}
  end

  def broadcast({:error, _reason} = error, _event), do: error
```

Het vermoeden is dat deze code herhaling door gebruik te maken van macros op te lossen was geweest.

## Foutmeldingen

De ervaring is dat functionele programmeer talen niet altijd hele heldere foutmeldingen geven, Elixir is hier helaas geen uitzondering op.
Vergeleken met Erlang zijn de foutmeldingen beter, maar er is nog zeer veel winst te behalen.
Een voorbeeld van een foutmelding die prettiger zou kunnen is het aanroepen van een functie met te veel of te weinig argumenten, 
hier zou bijvoorbeeld de bestaande arities genoemd moeten worden.

Bovendien is de formatting van de errors messages niet optimaal, waardoor het vaak lastig te zien is waar de stack trace begint.

## CI pipeline

De CI pipeline die uiteindelijk is opgezet build, end to end test en format de code. Ondanks dat de end to end tests niet volledig dekkend zijn
biedt de CI pipeline een flink verhoogde zekerheid in de werking van de code. Het automatische formatting zorgt ook voor 1 stijl binnen het hele project, wat prettiger leest.
Deze automatische formatting kort ook de review tijd in, doordat veel wijzigingen hiervoor formatting was, als de formatting altijd met dezelfde regels wordt gedaan, verandert er minder code.

## Docker

Ondanks dat docker niet gebruikt is voor al het dagelijkse ontwikkelwerk heeft het wel waarde toegevoegd en het project,
het zorgt er namelijk voor dat niet iedereen tools zoals Postgres en Minio op zijn systeem hoeft te installeren. Bovendien heeft docker de mogelijkheid om kubernetes te gebruiken geopend.
Hiernaast heeft docker bewezen dat phoenix op meerdere instanties is te draaien en dat PubSub dan goed werkt.

## BEM / Tailwindcss

Het gebruik van BEM in combinatie met tailwindcss heeft ervoor gezorgd dat styling op een samenhangende en vooral leesbare manier gebeurde door het project heen. 
De applicatie ziet er dan ook heel aardig uit, zonder dat hier veel tijd in is gaan zitten.

## Conclusie

Aangezien wij dit project met zo goed als nul kennis van deze stack zijn begonnen, hebben wij veel geleerd. 
Van het leren van een nieuwe taal in een voor sommigen nieuw paradigma, een nieuw concurrency model en styling tot kubernetes.
We kunnen dan ook stellen dat we meer functionaliteit hebben kunnen opleveren dan wij hadden verwacht, omdat de productiviteit in deze stack en de motivatie van de teamleden hoog was.
