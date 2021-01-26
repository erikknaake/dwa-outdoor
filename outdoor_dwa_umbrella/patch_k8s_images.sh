if [ $# -eq 0 ]
  then
    echo "No semver argument was supplied, aborting"
    exit 1
fi
sed -i -E 's!(ghcr.io/erikknaake/dwa-outdoor(.*):)v(.*)!\1'$1'!g' ./outdoor_dwa_k8s.yml