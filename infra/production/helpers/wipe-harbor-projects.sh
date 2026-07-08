#!/usr/bin/env bash
# wipe-harbor-projects.sh
# Deletes ALL repositories, artifacts, and projects from Harbor via the API.
# Does NOT touch registry endpoints, certs, or anything on the filesystem.
#
# Usage:
#   bash wipe-harbor-projects.sh
#   bash wipe-harbor-projects.sh /path/to/harbor.conf

set -uo pipefail

CONF="${1:-$(dirname "$0")/harbor.conf}"
if [ ! -f "$CONF" ]; then
  echo "ERROR: config file not found: $CONF"
  exit 1
fi
source "$CONF"

harbor_get() {
  curl -sk -u "$HARBOR_USER:$HARBOR_PASS" "$HARBOR_URL/api/v2.0/$1"
}

echo "=== Fetching current projects ==="
PROJECTS=$(harbor_get "projects" | \
  python3 -c "import sys,json; [print(p['name']) for p in json.load(sys.stdin)]" 2>/dev/null)

if [ -z "$PROJECTS" ]; then
  echo "No projects found (or failed to parse response). Nothing to do."
  exit 0
fi

echo "Found projects:"
echo "$PROJECTS" | sed 's/^/  - /'
echo ""

read -rp "This will permanently delete all repositories/artifacts in the above projects, then the projects themselves. Continue? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

STATE_FILE="$(dirname "$CONF")/harbor.cache-state"
if [ -f "$STATE_FILE" ]; then
  rm -f "$STATE_FILE"
  echo "Cleared warm cache state file: $STATE_FILE"
fi

while IFS= read -r PROJECT; do
  [ -z "$PROJECT" ] && continue
  echo ""
  echo "=== Project: $PROJECT ==="

  REPOS=$(harbor_get "projects/$PROJECT/repositories?page_size=100" | \
    python3 -c "import sys,json; [print(r['name']) for r in json.load(sys.stdin)]" 2>/dev/null)

  if [ -z "$REPOS" ]; then
    echo "  No repositories."
  else
    while IFS= read -r REPO_FULL; do
      [ -z "$REPO_FULL" ] && continue
      # REPO_FULL looks like "project/sub/path/image" — strip the leading "project/"
      REPO_NAME="${REPO_FULL#"$PROJECT"/}"
      REPO_ENCODED="${REPO_NAME//\//%252F}"

      HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
        -u "$HARBOR_USER:$HARBOR_PASS" -X DELETE \
        "$HARBOR_URL/api/v2.0/projects/$PROJECT/repositories/$REPO_ENCODED")

      case "$HTTP_CODE" in
        200) echo "  ✓ Deleted repo '$REPO_NAME'" ;;
        404) echo "  - Repo '$REPO_NAME' already gone" ;;
        *)   echo "  ERROR: HTTP $HTTP_CODE deleting repo '$REPO_NAME'" ;;
      esac
    done <<< "$REPOS"
  fi

  HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
    -u "$HARBOR_USER:$HARBOR_PASS" -X DELETE \
    "$HARBOR_URL/api/v2.0/projects/$PROJECT")

  case "$HTTP_CODE" in
    200) echo "  ✓ Deleted project '$PROJECT'" ;;
    404) echo "  - Project '$PROJECT' already gone" ;;
    *)   echo "  ERROR: HTTP $HTTP_CODE deleting project '$PROJECT' (it may not be empty — check for repos this script missed)" ;;
  esac
done <<< "$PROJECTS"

echo ""
echo "=== Remaining projects ==="
harbor_get "projects" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data:
    print('  (none)')
else:
    for p in data:
        print('  -', p['name'])
"
echo ""
echo "Done. Registry endpoints were not touched — re-run setup-harbor-projects.sh to recreate projects."