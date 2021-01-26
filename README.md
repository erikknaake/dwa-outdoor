# DwaOutdoor

![Build status](https://github.com/erikknaake/dwa-outdoor/workflows/Docker%20Image%20CI/badge.svg)
[![DWA](https://img.shields.io/endpoint?url=https://dashboard.cypress.io/badge/simple/kog6ht/development&style=flat&logo=cypress)](https://dashboard.cypress.io/projects/kog6ht/runs)

This project is nearly a clone of the original [iScout game](https://iscoutgame.com/), however it's focussed on horizontal scalability.
DwaOutdoor was created by 5 software development students following the DWA minor of HAN and received a perfect 10/10 score.

This project had to use Elixir with Phoenix and needed to take a look into docker. We also went and looked into kubernetes. 
We had 8 weeks for this project and invested 2 of those weeks in learning the technology stack.

Because we learned a lot about docker we were asked to write an article about it, [this is the medium post we wrote](https://erikknaake.medium.com/dockerizing-elixir-phoenix-2aaf56209b9f)

All documents are written in Dutch as this was a project for our study.

## Demo

[![Demo video](https://img.youtube.com/vi/lso_Wq3CcwA/hqdefault.jpg)](https://youtu.be/lso_Wq3CcwA)

## Starting the application

With docker:
- copy `.env.example` to `.env` and edit values as needed.
- `docker-compose up --env-file=.env`

Zie hoofdstuk [deployment](./docs/software_guidebook/11-deployment.md) in het software guidebook.

## Documents

- [Design](./docs/DESIGN.md)
- [Plan van aanpak](./docs/PLAN_VAN_AANPAK.md)
- [Software Guidebook](./docs/SOFTWARE_GUIDEBOOK.md)

## Contributors

- [Erik Knaake](https://github.com/erikknaake)
- [Maarten Grootoonk](https://github.com/MaartenGDev)
- [Julian de Bruin](https://github.com/Juliandb1708)
- [Dennis Vreman](https://github.com/dennisvrm)
- [Bonno Voorjans](https://github.com/BonnoVoorjans)
