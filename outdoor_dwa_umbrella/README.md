# OutdoorDwa.Umbrella

## Run with docker-compose
1. [Setup up an .env file](#setting-up-an-env-file)
2. `docker-compose --env-file=.env up --scale phoenix=x` where x is the number of phoenix instances to run

## Run development mode

1. `mix setup`
2. [Setup up an .env file](#setting-up-an-env-file)
3. Start Postgres and the minio cluster `docker-compose --env-file=.env up db minio-loadbalancer minio1 minio2`
4. `mix phx.server`

## Setting up an .env file

1. Copy `.env.example` to `.env` (`cp .env.example .env`)
2. Edit values to your needs

This is required to prevent checking in our application secrets.