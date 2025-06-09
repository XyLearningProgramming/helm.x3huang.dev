#!/bin/bash

set -ex

# Enter the directory where the script is located
cd "$(dirname "$0")/.."
export WORKSPACE="$(pwd)"

# Process all files in secrets directory
for file in ./secrets/*; do
  # Ignore *.example.* files
  if [[ "$file" == *.example.* ]]; then
    continue
  fi

  # Get namespace from filename by removing extension
  ns="${file##*/}"         # Strip path
  ns="${ns%.*}"           # Remove all extensions

  # Create namespace if it doesn't exist
  kubectl create namespace "$ns" || true

  # Handle .env files differently from regular files
  if [[ "$file" == *.env ]]; then
    kubectl create secret generic "helmfile-secret-$ns" \
      --namespace "$ns" \
      --dry-run=client \
      --from-env-file="$file" \
      -o yaml | kubectl apply -f -
  else
    kubectl create secret generic "helmfile-secret-$ns" \
      --namespace "$ns" \
      --dry-run=client \
      --from-file="$(basename "$file")=$file" \
      -o yaml | kubectl apply -f -
  fi
done