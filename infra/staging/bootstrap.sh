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
: "${AGE_KEY:?AGE_KEY is required}"

# --- Optional defaults ---
KUBECTL_WAIT_TIMEOUT="${KUBECTL_WAIT_TIMEOUT:-120s}"

# --- Preflight checks ---
for cmd in kind kubectl flux cilium docker; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ '$cmd' not found. Please install it first."
    exit 1
  fi
done

# --- 1. Create cluster ---
echo "🚀 Creating kind cluster: $CLUSTER_NAME"
kind create cluster \
  --name "$CLUSTER_NAME" \
  --config "$CLUSTER_CONFIG"

# --- 2. Wait for API server ---
echo "⏳ Waiting for API server..."
until kubectl cluster-info &>/dev/null 2>&1; do
  echo "  retrying..."
  sleep 3
done
echo "  ✓ API server is up"

# --- 3. Install Cilium directly ---
echo "🔌 Installing Cilium..."
cilium install \
  --version "$CILIUM_VERSION" \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="${CLUSTER_NAME}-control-plane" \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

# --- 4. Wait for Cilium ---
echo "⏳ Waiting for Cilium to be ready..."
cilium status --wait
echo "  ✓ Cilium is up"

# --- 5. Wait for nodes ---
echo "⏳ Waiting for nodes to be ready..."
kubectl wait \
  --for=condition=Ready nodes \
  --all \
  --timeout="$KUBECTL_WAIT_TIMEOUT"
echo "  ✓ Nodes are ready"

# --- 6. Create flux-system namespace ---
echo "🔧 Creating flux-system namespace..."
kubectl create namespace flux-system \
  --dry-run=client -o yaml | kubectl apply -f -

# --- 7. Create sops-age secret ---
echo "🔑 Creating sops-age secret..."

# Write age key to temp file with restricted permissions
AGE_TMPFILE=$(mktemp)
chmod 600 "$AGE_TMPFILE"

# Ensure temp file is removed on exit (even if script fails)
trap "rm -f $AGE_TMPFILE" EXIT

printf '%s' "$AGE_KEY" > "$AGE_TMPFILE"

kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey="$AGE_TMPFILE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "  ✓ sops-age secret created"

# --- 8. Verify sops-age secret ---
echo "🔍 Verifying sops-age secret..."

SECRET_VALUE=$(kubectl get secret sops-age \
  -n flux-system \
  -o jsonpath='{.data.age\.agekey}' | base64 -d)

if [[ "$SECRET_VALUE" == "$AGE_KEY" ]]; then
  echo "  ✓ Secret verified — keys match"
else
  echo "  ❌ Secret mismatch — stored key does not match AGE_KEY in .env"
  exit 1
fi

# --- 9. Bootstrap Flux ---
echo "🔄 Bootstrapping Flux..."
GITHUB_TOKEN="$GITHUB_TOKEN" \
flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO" \
  --branch="$GITHUB_BRANCH" \
  --path="$GITHUB_PATH" \
  --components-extra=image-reflector-controller,image-automation-controller \
  --personal

echo "✅ Bootstrap complete"