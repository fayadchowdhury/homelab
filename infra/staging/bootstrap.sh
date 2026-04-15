#!/bin/bash
# bootstrap.sh

set -euo pipefail

# --- Usage ---
usage() {
  echo "Usage: $0 -u <github-username> -t <github-token>"
  exit 1
}

# --- Parse args ---
while getopts "u:t:" opt; do
  case $opt in
    u) GITHUB_USER="$OPTARG" ;;
    t) GITHUB_TOKEN="$OPTARG" ;;
    *) usage ;;
  esac
done

# --- Validate ---
if [[ -z "${GITHUB_USER:-}" || -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Error: both -u and -t are required"
  usage
fi

# --- 1. Create the cluster ---
kind create cluster --name staging --config=kind-config.yaml

# --- 2. Wait for it to be ready ---
kubectl wait --for=condition=Ready nodes --all --timeout=60s

# --- 3. Hand off to Flux ---
GITHUB_TOKEN="$GITHUB_TOKEN" \
flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository=homelab \
  --branch=master \
  --path=./cluster/staging \
  --personal