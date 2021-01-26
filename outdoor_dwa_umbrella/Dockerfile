FROM elixir:1.9-alpine as build

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python
ARG APPS_PATH
ARG CONFIG_PATH
ARG DOMAIN_PATH
ARG WEB_PATH
ARG REL_PATH
ARG RELEASE_NAME
ARG UMBRELLA_PATH
RUN echo $UMBRELLA_PATH
RUN mkdir $UMBRELLA_PATH
WORKDIR $UMBRELLA_PATH

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# Install dependencies
RUN mkdir ./$APPS_PATH
RUN mkdir ./$DOMAIN_PATH
RUN mkdir ./$WEB_PATH
# Install node_modules
COPY $WEB_PATH/assets/package*.json ./$WEB_PATH/assets/
RUN npm i --prefix ./$WEB_PATH/assets
# install mix dependencies
COPY mix.* ./
COPY $DOMAIN_PATH/mix.* $DOMAIN_PATH
COPY $WEB_PATH/mix.* $WEB_PATH
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Build front-end
COPY $WEB_PATH/assets ./$WEB_PATH/assets
RUN npm run deploy --prefix ./$WEB_PATH/assets

# Copy app code
COPY $CONFIG_PATH $CONFIG_PATH
COPY $APPS_PATH $APPS_PATH

RUN mix phx.digest

# build release
COPY $REL_PATH $REL_PATH
RUN mix release $RELEASE_NAME

# prepare release image
FROM alpine:3.9 AS app
# install runtime dependencies
RUN apk add --update openssl postgresql-client curl

# Create folder for storing pdf files
RUN mkdir -p /apps/outdoor_dwa_web/priv/static/practical_task_pdf/

# Download kubectl client
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl && mv kubectl /usr/bin

EXPOSE 4000
ENV MIX_ENV=prod
ARG RELEASE_NAME
ARG UMBRELLA_PATH
ARG WEB_PATH
# copy release to app container
COPY --from=build $UMBRELLA_PATH/_build/prod/rel/$RELEASE_NAME/ .
COPY entrypoint.sh ./entrypoint.sh

LABEL org.opencontainers.image.source https://github.com/erikknaake/dwa-outdoor

CMD ["sh", "./entrypoint.sh"]