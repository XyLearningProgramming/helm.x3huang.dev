#!/bin/bash
set -euo pipefail
# set -x  # uncomment for debugging

# Move to workspace root (script’s parent dir)
cd "$(dirname "$0")/.."
export WORKSPACE="$(pwd)"

# Use a Bash associative array to collect files per namespace.
# Each entry ns_files[$ns] is a '|'‑delimited list of file paths.
declare -A ns_files

# 1. Collect files by namespace
for file in ./secrets/*; do
  # Skip example files
  if [[ "$file" == *.example.* ]]; then
    continue
  fi

  # Derive namespace from filename: strip path, then strip extension
  ns="${file##*/}"
  ns="${ns%%.*}"

  # Append to the list for this namespace; use '|' as separator
  ns_files["$ns"]+="$file|"
done

# 2. For each namespace, build and apply a single Secret manifest
for ns in "${!ns_files[@]}"; do
  files_str="${ns_files[$ns]}"
  # Split the '|'‑delimited string into an array; the last element may be empty
  IFS="|" read -r -a files <<< "$files_str"

  # Ensure namespace exists
  kubectl create namespace "$ns" >/dev/null 2>&1 || true

  secretName="helmfile-secret-$ns"

  # Build the kubectl create secret generic command with multiple --from-*
  # We'll do dry-run=client -o yaml, then pipe to kubectl apply -f -.
  cmd=(kubectl create secret generic "$secretName" --namespace "$ns" --dry-run=client -o yaml)

  for file in "${files[@]}"; do
    # Skip empty entries (due to trailing separator)
    if [[ -z "$file" ]]; then
      continue
    fi

    if [[ "$file" == *.env ]]; then
      # .env files: key/values from env-file
      cmd+=(--from-env-file="$file")
    else
      # For other files: use basename as key
      key="$(basename "$file")"
      cmd+=(--from-file="$key=$file")
    fi
  done

  # Execute creation+apply
  # This will replace the Secret if it exists (i.e., override data entirely with current files).
  "${cmd[@]}" | kubectl apply -f -

  echo "Applied Secret '$secretName' in namespace '$ns' from files: ${files[*]}"
done
