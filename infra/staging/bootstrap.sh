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

# --- 2. Wait for API server
echo "⏳ Waiting for API server..."
until kubectl cluster-info &>/dev/null 2>&1; do
  echo "  retrying..."
  sleep 3
done
echo "  ✓ API server is up"

# --- 3. Install Cilium directly
echo "🔌 Installing Cilium..."
cilium install \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="${CLUSTER_NAME}-control-plane" \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

# --- 4. Wait for Cilium
echo "⏳ Waiting for Cilium to be ready..."
cilium status --wait
echo "  ✓ Cilium is up"

# --- 5. Wait for readiness ---
echo "⏳ Waiting for nodes to be ready..."
kubectl wait \
  --for=condition=Ready nodes \
  --all \
  --timeout="$KUBECTL_WAIT_TIMEOUT"

# --- 6. Bootstrap Flux ---
echo "🔄 Bootstrapping Flux..."

GITHUB_TOKEN="$GITHUB_TOKEN" \
flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO" \
  --branch="$GITHUB_BRANCH" \
  --path="$GITHUB_PATH" \
  --personal

echo "✅ Bootstrap complete"