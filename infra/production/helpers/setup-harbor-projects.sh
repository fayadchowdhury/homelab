#!/usr/bin/env bash
# setup-harbor-projects.sh
# Idempotently creates Harbor registry endpoints and proxy cache projects.
# All configuration is read from harbor.conf in the same directory.
#
# Usage:
#   bash setup-harbor-projects.sh
#   bash setup-harbor-projects.sh /path/to/harbor.conf

set -uo pipefail  # removed -e so a single failure doesn't abort the whole script

CONF="${1:-$(dirname "$0")/harbor.conf}"
if [ ! -f "$CONF" ]; then
  echo "ERROR: config file not found: $CONF"
  exit 1
fi
source "$CONF"

# ── Helpers ───────────────────────────────────────────────────────────────────

harbor_get() {
  curl -sf -u "$HARBOR_USER:$HARBOR_PASS" "$HARBOR_URL/api/v2.0/$1"
}

upsert_registry() {
  local NAME="$1" URL="$2" TYPE="$3"
  local ACCESS_KEY="${4:-}" ACCESS_SECRET="${5:-}"

  if [ -n "$ACCESS_KEY" ]; then
    PAYLOAD="{\"name\":\"$NAME\",\"url\":\"$URL\",\"type\":\"$TYPE\",\"insecure\":false,\"credential\":{\"access_key\":\"$ACCESS_KEY\",\"access_secret\":\"$ACCESS_SECRET\",\"type\":\"basic\"}}"
  else
    PAYLOAD="{\"name\":\"$NAME\",\"url\":\"$URL\",\"type\":\"$TYPE\",\"insecure\":false}"
  fi

  ID=$(harbor_get "registries?name=${NAME}" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null || echo "")

  if [ -n "$ID" ]; then
    echo "  Registry '$NAME' exists (id=$ID) — updating"
    RESPONSE=$(curl -s -w "\n%{http_code}" -u "$HARBOR_USER:$HARBOR_PASS" \
      -X PUT "$HARBOR_URL/api/v2.0/registries/$ID" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")
    CODE=$(echo "$RESPONSE" | tail -1)
    [ "$CODE" = "200" ] && echo "  ✓ Updated" || echo "  ERROR: HTTP $CODE — $(echo "$RESPONSE" | head -1)"
  else
    echo "  Registry '$NAME' not found — creating"
    RESPONSE=$(curl -s -w "\n%{http_code}" -u "$HARBOR_USER:$HARBOR_PASS" \
      -X POST "$HARBOR_URL/api/v2.0/registries" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")
    CODE=$(echo "$RESPONSE" | tail -1)
    [ "$CODE" = "201" ] && echo "  ✓ Created" || echo "  ERROR: HTTP $CODE — $(echo "$RESPONSE" | head -1)"
  fi
}

upsert_proxy_project() {
  local PROJECT="$1" REGISTRY_NAME="$2"

  REGISTRY_ID=$(harbor_get "registries?name=${REGISTRY_NAME}" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null || echo "")

  if [ -z "$REGISTRY_ID" ]; then
    echo "  ERROR: registry '$REGISTRY_NAME' not found — cannot create project '$PROJECT'"
    return 0
  fi

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "$HARBOR_USER:$HARBOR_PASS" \
    -X POST "$HARBOR_URL/api/v2.0/projects" \
    -H "Content-Type: application/json" \
    -d "{\"project_name\":\"$PROJECT\",\"public\":true,\"registry_id\":$REGISTRY_ID}")

  case "$HTTP_CODE" in
    201) echo "  ✓ Created project '$PROJECT'" ;;
    409) echo "  ✓ Project '$PROJECT' already exists — skipping" ;;
    *)   echo "  ERROR: HTTP $HTTP_CODE for project '$PROJECT'" ;;
  esac
}

upsert_plain_project() {
  local PROJECT="$1"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "$HARBOR_USER:$HARBOR_PASS" \
    -X POST "$HARBOR_URL/api/v2.0/projects" \
    -H "Content-Type: application/json" \
    -d "{\"project_name\":\"$PROJECT\",\"public\":true}")
  case "$HTTP_CODE" in
    201) echo "  ✓ Created project '$PROJECT'" ;;
    409) echo "  ✓ Project '$PROJECT' already exists — skipping" ;;
    *)   echo "  ERROR: HTTP $HTTP_CODE for project '$PROJECT'" ;;
  esac
}

# ── Wait for Harbor ───────────────────────────────────────────────────────────

echo "Waiting for Harbor API..."
until harbor_get "systeminfo" > /dev/null 2>&1; do
  echo "  Not ready, retrying in 5s..."
  sleep 5
done
echo "Harbor is ready."
echo ""

# ── Registry endpoints ────────────────────────────────────────────────────────

echo "=== Upserting registry endpoints ==="
for entry in "${REGISTRIES[@]}"; do
  upsert_registry $entry
done
echo ""

# ── Proxy cache projects ──────────────────────────────────────────────────────

echo "=== Upserting proxy cache projects ==="
for entry in "${PROXY_PROJECTS[@]}"; do
  upsert_proxy_project $entry
done
echo ""

# ── Plain projects ────────────────────────────────────────────────────────────

echo "=== Upserting plain projects ==="
for project in "${PLAIN_PROJECTS[@]}"; do
  upsert_plain_project "$project"
done
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────

echo "=== Current state ==="
harbor_get "projects" | python3 -c "
import sys, json
for p in sorted(json.load(sys.stdin), key=lambda x: x['name']):
    t = 'proxy-cache' if p.get('registry_id') else 'plain'
    print('  {:<20} {:<12} repos={}'.format(p['name'], t, p['repo_count']))
"
echo ""
echo "Done."