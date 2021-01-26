# Principles

In dit hoofdstuk zijn de verschillende principes die zijn toegepast tijdens ons project beschreven. De meeste principes komen van het ontwikkelteam die deze over de jaren heen eigen heeft gemaakt met programmeerlessen en praktijkervaring.

Deze principes zijn uitgewerkt zodat de principes voor iedereen duidelijk zijn en toegepast kunnen worden tijdens het realiseren van de applicatie.

## Code Principles

- Gebruik zo min mogelijk logica in controllers.
- Plaats zoveel mogelijk logica in het "domain" project.
- Geen database communicatie vanuit het "web" project.
- Vraag alleen via contexts in het "domain" project data op uit de database.
- Kies externe dependencies boven complexe code.
- Premature code niet optimaliseren.
- Schrijf Unit tests voor complexe code.
- Kies voor functies met namen en variabelen boven code comments.
- Schrijf code, commentaar en code docs in het Engels.
- Maak gebruik van snake_case voor functie en variabele namen.
- Migrations die in de development branch zijn gemerged, zijn immutable.

### Client

- Schrijf alleen code in de client wanneer dit logisch is of niet anders kan, bijvoorbeeld om te voorkomen dat een bestand de applicatieserver raakt.
- Houdt je voor styling zoveel mogelijk aan de [BEM principes](http://getbem.com/introduction/).
- Combineer vaak gebruikte combinaties van styling classes in components.
- Voorkom het blokkeren van de main thread, gebruik [web workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) of [web assembly](https://developer.mozilla.org/en-US/docs/WebAssembly) voor hele trage operaties (bijvoorbeeld bestanden parsen).
- Gebruik [async/await](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Async_await) of [promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) voor operaties met latency (bijvoorbeeld network requests).
- Gebruik de scss ampersand syntax om BEM te realiseren
```scss
// Good
.button {
  @apply bg-black;
  
  &--primary {
    @apply text-white;  
  }
  
  &__text {
    @apply italic;
  }
}

// Bad
.button {
  @apply bg-black
}

.button--primary {
  @apply text-white;
}

.button__text {
  @apply italic;
}
```

### Elixir

Hieronder zijn een aantal elixir specifieke principes uitgewerkt.

- Kies pipelines boven function nesting
```elixir
# Bad
broadcast(add_score(get_from_db(id), 2))

# Good
get_from_db(id)
|> add_score(2)
|> broadcast()
```

- Wanneer je on-pure logica wilt gebruiken, zorg dat het ook als pure functie te benaderen is
```elixir
# Bad
def future_datetime() do
  DateTime.add(DateTime.utc_now(), 10, :seconds)
end 

# Good
def future_datetime(datetime \\ DateTime.utc_now()) do
  DateTime.add(datetime, 10, :seconds)
end 

# Good
def future_datetime() do
  add_seconds(DateTime.utc_now())
end 

def add_seconds(datetime) do
  DateTime.add(datetime, 10, :seconds)
end
```

## Documentatie Principles

- Schrijf documentatie in het Nederlands.


## GitHub Principles

- Maak voor nieuwe features een feature branch aan beginnend met `feature/`, gevolgd door een naam in kebab-case.
- Maak voor bugfixes een branch aan beginnend met `bugfix/`, gevolgd door een naam in kebab-case.
- Maak voor documentatie een branch aan beginnend met `software-guidebook/`, gevolgd door een naam in kebab-case.
- Maak geen directe wijzigingen op de `main` en `development` branches.
- Maak voor elke branch een pull request aan om te mergen met de `development` branch.
- Een pull request moet door minstens 1 reviewer approved zijn voor deze gemerged mag worden.