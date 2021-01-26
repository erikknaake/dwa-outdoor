FROM minio/mc:RELEASE.2020-12-18T10-53-53Z
LABEL org.opencontainers.image.source https://github.com/erikknaake/dwa-outdoor

COPY create-bucket-entrypoint.sh ./create-bucket-entrypoint.sh