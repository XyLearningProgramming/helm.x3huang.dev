#!/bin/bash

set -ex

# Enter the directory where the script is located
cd "$(dirname "$0")/.."
export WORKSPACE="$(pwd)"

for file in ./secrets/*.env; do
  # Ignore *.example.env
  if [[ "$file" == *.example.env ]]; then
    continue
  fi
  ns="${file##*/}"         # Strip path
  ns="${ns%.env}"          # Remove .env extension to get namespace
  kubectl create namespace "$ns" || true
  kubectl create secret generic helmfile-secret \
    --namespace "$ns" \
    --dry-run=client \
    --from-env-file="$file" \
    -o yaml | kubectl apply -f -
done