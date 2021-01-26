# Operation and Support

Dit hoofdstuk beschrijft hoe OutdoorDwa gemonitord kan worden en welke acties vereist zijn om OutdoorDwa te laten
blijven werken. Dit hoofdstuk gaat ervan uit dat OutdoorDwa is gedeployd met kubernetes in productie mode, zoals het
hoofdstuk Deployment beschrijft.

## Rapporteren
De applicatie wordt ontwikkeld als proof of concept, de focus ligt daarom op het ontwikkelen van functionaliteit en minder op het production ready maken. Het rapporten van foutmeldingen en mislukte operaties zal daarom ook vooral gericht zijn op ontwikkelaars.

We volgen de logging opzet van de [12 factor app](https://12factor.net/logs), dit betekent dat fouten gelogd worden met een standaard [logger](https://hexdocs.pm/logger/Logger.html) op de [stderr](https://man7.org/linux/man-pages/man3/stderr.3.html) en informative meldingen via [stdout](https://man7.org/linux/man-pages/man3/stdout.3.html). Deze zijn direct te zien in de terminals waar het start commando is gedraaid(`mix phx.server`). Ook zijn deze logs inzichtelijk voor bijvoorbeeld kubernetes([node-level logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/#cluster-level-logging-architectures))

Naast het gebruiken van standaard logging output is ook een passende verbosity gekozen. De verbosity bepaald hoeveel informatie wordt getoond als er iets misgaat. Dit varieert tussen niet gedetailleerd (in productie) en zeer gedetailleerd. Dit wordt geconfigureerd in `dev.exs` en `runtime.exs`, in onderstaande voorbeeld is te zien hoe het ingesteld kan worden:
```elixir
config :logger, level: :info # ignore hints and improvement suggestions
config :phoenix, :stacktrace_depth, 20 # show the stacktrace and last 20 files.
```

In productie worden fouten een stuk minder gedetailleerd getoond, omdat het verzamelen van bijvoorbeeld stacktraces intensief is, wat ten kostte gaat van de performance. Ook brengt het te gedetailleerd loggen op productie veiligheidsrisico's mee zich mee, het zou namelijk voor kunnen komen dat bij een mislukte query ook ineens de ingestelde database credentials te zien zijn.

Naast de applicatie logs kan het [minikube dashboard](https://minikube.sigs.k8s.io/docs/handbook/dashboard/) of vergelijkbare tooling voor de specifieke kubernetes installatie worden ingericht.
Deze tools kunnen worden gebruikt om deployments te vinden die (te) vaak crashen en restarten.

## Configuratie

De meeste configuratie variabelen voor de phoenix servers worden uit de environment variabelen gehaald tijdens
[runtime](https://www.amberbit.com/blog/2018/9/27/elixir-runtime-vs-compile-time-configuration/). 
Er is wel een container reboot nodig om het wijzigen van environment variabelen effect te laten hebben. 
Eerder was dit nog compile time, dit is runtime gemaakt om betere ondersteuning voor verschillende platformen, zoals kubernetes te leveren. Nu is het niet meer nodig om de image te rebuilden wanneer er op een ander platform wordt gedeployd.
Dit is op dezelfde manier opgezet als onze [medium post](https://erikknaake.medium.com/dockerizing-elixir-phoenix-2aaf56209b9f) beschrijft.

### Runtime environment variables

#### Minio

| Environment variable | Doel                                                              | Verplicht?                     |
| -------------------- | ----------------------------------------------------------------- | ------------------------------ |
| MINIO_ACCESS_KEY     | 'Gebruikersnaam' voor minio                                       | Ja                             |
| MINIO_SECRET_KEY     | Wachtwoord voor minio (wordt gebruikt voor cryptografie)          | Ja                             |

#### Phoenix

| Environment variable             | Doel                                                               | Verplicht?                     |
| -------------------------------- | ------------------------------------------------------------------ | ------------------------------ |
| SECRET_KEY_BASE                  | Op basis hiervan worden andere cryptografische geheimen afgeleid   | In productie                   |
| DATABASE_URL                     | Ecto url na de database                                            | In productie                   |
| HOST                             | Op welk domein de server draait, wordt gebruikt voor CORS          | Default: dwa-outdoor.prod      |
| PORT                             | Poort waarop de server connecties accepteert                       | Default: 4000                  |
| POOL_SIZE                        | Aantal connecties dat naar de database wordt opengehouden          | Default: 10                    |
| MINIO_ACCESS_KEY                 | 'Gebruikersnaam' voor minio                                        | Default: minio                 |
| MINIO_SECRET_KEY                 | Wachtwoord voor minio (wordt gebruikt voor cryptografie)           | Default: minio123              |
| MINIO_HOST                       | Domain where minio runs                                            | Default: file.dwa-outdoor.prod |
| TRAVEL_QUESTION_COOLDOWN         | Tijd in minuten die tussen pogingen op een reisvraag moet zitten   | Default: 5                     |
| TRAVEL_QUESTION_SWEEPER_COOLDOWN | Tijd in minuten die tussen het gebruik van bezembevers moet zitten | Default: 15                    |

### First time run environment variables

#### Postgres

| Environment variable | Doel                                                              | Verplicht?                     |
| -------------------- | ----------------------------------------------------------------- | ------------------------------ |
| POSTGRES_DB          | Database naam voor db die wordt aangemaakt                        | Ja                             |
| POSTGRES_USER        | Gebruiker die wordt aangemaakt                                    | Ja                             |
| POSTGRES_PASSWORD    | Wachtwoord voor de gebruiker die wordt aangemaakt                 | Ja                             |

## Schaalbaarheid configuratie

Voor nu zijn er een aantal harde waardes ingevuld in het kubernetes definitie bestand, we hebben het schaalbaar gemaakt om de aanvragen te verdelen met [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) en [Services](https://kubernetes.io/docs/concepts/services-networking/service/). 
Hieronder is een voorbeeld van een stukje kubernetes configuratie waarmee meerdere instanties van dezelfde container naast elkaar draaien:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: outdoor-dwa-svc
  namespace: outdoor-dwa
spec:
  type: NodePort
  selector:
    app: outdoor-dwa-app
  ports:
    - protocol: TCP
      port: 4000

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: outdoor-dwa-app-deployment
  namespace: outdoor-dwa
  labels:
    app: outdoor-dwa-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: outdoor-dwa-app
      tier: web
  template:
    metadata:
      labels:
        app: outdoor-dwa-app
        tier: web
```