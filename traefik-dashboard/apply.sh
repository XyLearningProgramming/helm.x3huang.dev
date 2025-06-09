#!/bin/bash

set -ex

# Enter the directory where the script is located
cd "$(dirname "$0")"
export WORKSPACE="$(pwd)"

cat ${WORKSPACE}/service.yaml | envsubst | kubectl apply -f -
cat ${WORKSPACE}/ingress.yaml | envsubst | kubectl apply -f -

kubectl port-forward -n kube-system svc/traefik-dashboard 9000:9000