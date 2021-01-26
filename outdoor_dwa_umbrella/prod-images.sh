docker build . -t ghcr.io/erikknaake/dwa-outdoor/dwa-outdoor-app:latest -f Dockerfile --build-arg DATABASE_URL=localhost --build-arg SECRET_KEY_BASE=localhost --build-arg HOST=http://localhost --build-arg PORT=4000 --build-arg APPS_PATH=apps --build-arg CONFIG_PATH=config --build-arg DOMAIN_PATH=apps/outdoor_dwa --build-arg WEB_PATH=apps/outdoor_dwa_web --build-arg RELEASE_NAME=standard --build-arg REL_PATH=rel --build-arg UMBRELLA_PATH=/outdoor_dwa_umbrella
docker push ghcr.io/erikknaake/dwa-outdoor/dwa-outdoor-app:latest