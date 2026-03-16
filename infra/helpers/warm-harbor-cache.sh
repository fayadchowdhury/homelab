#!/usr/bin/env bash
# warm-harbor-cache.sh
# Warms the Harbor proxy cache by pulling images through Harbor to /dev/null.
# Skips images already present in Harbor (checks manifest before pulling).
# All configuration and image list read from harbor.conf.
#
# Usage:
#   bash warm-harbor-cache.sh
#   bash warm-harbor-cache.sh /path/to/harbor.conf

set -uo pipefail

CONF="${1:-$(dirname "$0")/harbor.conf}"
if [ ! -f "$CONF" ]; then
  echo "ERROR: config file not found: $CONF"
  exit 1
fi
source "$CONF"

if ! command -v crane > /dev/null 2>&1; then
  echo "ERROR: crane is not installed."
  echo "  macOS:  brew install crane"
  echo "  Linux:  https://github.com/google/go-containerregistry/releases"
  exit 1
fi

HARBOR_HOST="${HARBOR_URL#http://}"
HARBOR_HOST="${HARBOR_HOST#https://}"

# ── Auth ──────────────────────────────────────────────────────────────────────

echo "Logging in to Harbor..."
crane auth login "$HARBOR_HOST" \
  --insecure \
  -u "$HARBOR_USER" \
  -p "$HARBOR_PASS"
echo ""

# ── Warm images ───────────────────────────────────────────────────────────────

warm_image() {
  local FULL_IMAGE="$1"
  local REGISTRY IMAGE_PATH PROJECT HARBOR_REF

  REGISTRY=$(echo "$FULL_IMAGE" | cut -d/ -f1)
  IMAGE_PATH=$(echo "$FULL_IMAGE" | cut -d/ -f2-)
  PROJECT=$(harbor_project_for "$REGISTRY" 2>/dev/null || echo "")

  if [ -z "$PROJECT" ]; then
    echo "  SKIP: no proxy project for registry $REGISTRY ($FULL_IMAGE)"
    return 0
  fi

  HARBOR_REF="$HARBOR_HOST/$PROJECT/$IMAGE_PATH"
  printf "%-60s" "$FULL_IMAGE"

  # Check if already cached by querying the manifest — fast, no download
  if crane manifest "$HARBOR_REF" --insecure > /dev/null 2>&1; then
    echo "already cached ✓"
    return 0
  fi

  # Not cached — pull through Harbor to populate the cache
  echo "pulling..."
  if crane pull "$HARBOR_REF" --insecure /dev/null 2>/dev/null; then
    printf "%-60s✓ cached\n" ""
  else
    printf "%-60s✗ failed (will pull on-demand)\n" ""
  fi
}

echo "=== Warming cache ==="
for image in "${CACHE_IMAGES[@]}"; do
  warm_image "$image"
done

echo ""
echo "=== Final state ==="
curl -sf -u "$HARBOR_USER:$HARBOR_PASS" \
  "$HARBOR_URL/api/v2.0/projects" | \
  python3 -c "
import sys, json
for p in sorted(json.load(sys.stdin), key=lambda x: x['name']):
    t = 'proxy-cache' if p.get('registry_id') else 'plain'
    print('  {:<20} {:<12} repos={}'.format(p['name'], t, p['repo_count']))
"
echo ""
echo "Done."