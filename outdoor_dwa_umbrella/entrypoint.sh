export CONTAINER_IP=$(hostname -i)
echo "ip: $CONTAINER_IP , name will be: phoenix@$CONTAINER_IP"
export RELEASE_DISTRIBUTION=name
export RELEASE_NODE="phoenix@${CONTAINER_IP}"
export CONNECT_TO_SERVER=true
./bin/standard eval "OutdoorDwa.Release.migrate"
./bin/standard start
