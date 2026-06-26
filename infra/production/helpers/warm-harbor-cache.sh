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
  local REGISTRY IMAGE_PATH PROJECT HARBOR_REF TMPFILE

  REGISTRY=$(echo "$FULL_IMAGE" | cut -d/ -f1)
  IMAGE_PATH=$(echo "$FULL_IMAGE" | cut -d/ -f2-)
  PROJECT=$(harbor_project_for "$REGISTRY" 2>/dev/null || echo "")

  if [ -z "$PROJECT" ]; then
    printf "%-60s %s\n" "$FULL_IMAGE" "SKIP (no proxy project for $REGISTRY)"
    return 0
  fi

  HARBOR_REF="$HARBOR_HOST/$PROJECT/$IMAGE_PATH"
  printf "%-60s" "$FULL_IMAGE"

  local REPO_NAME="${IMAGE_PATH%:*}"
  local REPO_ENCODED="${REPO_NAME//\//%252F}"

  # Check if any artifact exists in this repo
  local COUNT
  COUNT=$(curl -sf \
    -u "$HARBOR_USER:$HARBOR_PASS" \
    "$HARBOR_URL/api/v2.0/projects/$PROJECT/repositories/$REPO_ENCODED/artifacts?page_size=1" \
    2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "0")

  if [ "$COUNT" -gt 0 ]; then
    echo "already cached ✓"
    return 0
  fi

  # Create temp file and guarantee cleanup on function exit
  TMPFILE=$(mktemp /tmp/crane-pull-XXXXXX.tar 2>/dev/null || mktemp)
  trap "rm -f '$TMPFILE'" RETURN

  # Pull through Harbor to trigger upstream fetch and cache
  if crane pull "$HARBOR_REF" "$TMPFILE" --insecure 2>/dev/null; then
    echo "✓ cached"
  else
    echo "✗ failed (will pull on-demand)"
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