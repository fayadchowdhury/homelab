#!/bin/bash

set -euo pipefail

# --- Load env ---
ENV_FILE="${ENV_FILE:-.env}"

if [[ -f "$ENV_FILE" ]]; then
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

# --- Validate ---
: "${CLUSTER_NAME:?CLUSTER_NAME is required}"

echo "⚠️  Tearing down cluster: $CLUSTER_NAME"

# --- Check if cluster exists ---
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "🧹 Deleting kind cluster..."
  kind delete cluster --name "$CLUSTER_NAME"
  echo "✅ Cluster deleted"
else
  echo "ℹ️  Cluster '$CLUSTER_NAME' does not exist, skipping"
fi

echo "🎉 Teardown complete"