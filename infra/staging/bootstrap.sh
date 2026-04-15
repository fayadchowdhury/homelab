#!/bin/bash

set -euo pipefail

# --- Load env ---
ENV_FILE="${ENV_FILE:-.env}"

if [[ -f "$ENV_FILE" ]]; then
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

# --- Validate required variables ---
: "${GITHUB_USER:?GITHUB_USER is required}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
: "${GITHUB_REPO:?GITHUB_REPO is required}"
: "${GITHUB_BRANCH:?GITHUB_BRANCH is required}"
: "${GITHUB_PATH:?GITHUB_PATH is required}"
: "${CLUSTER_NAME:?CLUSTER_NAME is required}"
: "${CLUSTER_CONFIG:?CLUSTER_CONFIG is required}"

# --- Optional defaults ---
KUBECTL_WAIT_TIMEOUT="${KUBECTL_WAIT_TIMEOUT:-60s}"

echo "🚀 Creating kind cluster: $CLUSTER_NAME"

# --- 1. Create cluster ---
kind create cluster \
  --name "$CLUSTER_NAME" \
  --config "$CLUSTER_CONFIG"

# --- 2. Wait for readiness ---
echo "⏳ Waiting for nodes to be ready..."
kubectl wait \
  --for=condition=Ready nodes \
  --all \
  --timeout="$KUBECTL_WAIT_TIMEOUT"

# --- 3. Bootstrap Flux ---
echo "🔄 Bootstrapping Flux..."

GITHUB_TOKEN="$GITHUB_TOKEN" \
flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO" \
  --branch="$GITHUB_BRANCH" \
  --path="$GITHUB_PATH" \
  --personal

echo "✅ Bootstrap complete"