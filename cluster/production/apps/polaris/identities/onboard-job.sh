#!/bin/sh
# Ensures one Polaris principal + principal role per tool and delivers each tool's credential as a
# Kubernetes Secret in the tool's own namespace. Idempotent; credentials are only issued when needed.
#   IDENTITIES = space separated "principal:namespace:secretName" entries
set -eu

POLARIS="${POLARIS_URL:-http://polaris.polaris.svc.cluster.local:8181}"
MGMT="$POLARIS/api/management/v1"
CAT="$POLARIS/api/catalog/v1"
REALM_HDR="Polaris-Realm: ${POLARIS_REALM:-POLARIS}"
: "${IDENTITIES:?}" "${ROOT_SECRET:?}"
OUT=/tmp/resp.json

api() {  # api METHOD URL [JSON] -> prints HTTP status, body in $OUT
  m="$1"; u="$2"; d="${3:-}"
  if [ -n "$d" ]; then
    curl -s -o "$OUT" -w '%{http_code}' -X "$m" "$u" -H "Authorization: Bearer $TOKEN" \
      -H "$REALM_HDR" -H 'Content-Type: application/json' -d "$d"
  else
    curl -s -o "$OUT" -w '%{http_code}' -X "$m" "$u" -H "Authorization: Bearer $TOKEN" \
      -H "$REALM_HDR" -H 'Content-Type: application/json'
  fi
}
ok() {   # 2xx or 409 pass, anything else aborts
  case "$1" in
    2??|409) echo "  $2 -> $1" ;;
    *) echo "FAILED: $2 -> $1"; cat "$OUT"; echo; exit 1 ;;
  esac
}

echo "== waiting for Polaris, getting admin token"
TOKEN=""; i=0
while [ "$i" -lt 60 ]; do
  TOKEN=$(curl -s -X POST "$CAT/oauth/tokens" -H "$REALM_HDR" \
    -d grant_type=client_credentials -d client_id=root -d "client_secret=$ROOT_SECRET" \
    -d scope=PRINCIPAL_ROLE:ALL 2>/dev/null | jq -r '.access_token // empty' 2>/dev/null) || TOKEN=""
  [ -n "$TOKEN" ] && break
  i=$((i + 1)); sleep 10
done
[ -n "$TOKEN" ] || { echo "Polaris did not become ready"; exit 1; }

for entry in $IDENTITIES; do
  P="${entry%%:*}"; rest="${entry#*:}"; NS="${rest%%:*}"; SECRET="${rest#*:}"
  ROLE="${P}_role"
  echo "== $P -> secret $NS/$SECRET"

  CID=""; CSEC=""
  code=$(api POST "$MGMT/principals" "{\"principal\":{\"name\":\"$P\"}}")
  if [ "$code" = "409" ]; then
    if kubectl -n "$NS" get secret "$SECRET" >/dev/null 2>&1; then
      echo "  principal and secret exist, credentials untouched"
    else
      echo "  principal exists but secret is missing -> rotating credentials"
      ok "$(api POST "$MGMT/principals/$P/rotate")" "rotate"
      CID=$(jq -r '.credentials.clientId' "$OUT"); CSEC=$(jq -r '.credentials.clientSecret' "$OUT")
    fi
  else
    ok "$code" "create principal"
    CID=$(jq -r '.credentials.clientId' "$OUT"); CSEC=$(jq -r '.credentials.clientSecret' "$OUT")
  fi

  ok "$(api POST "$MGMT/principal-roles" "{\"principalRole\":{\"name\":\"$ROLE\"}}")" "principal role $ROLE"
  ok "$(api PUT "$MGMT/principals/$P/principal-roles" "{\"principalRole\":{\"name\":\"$ROLE\"}}")" "assign $ROLE"

  if [ -n "$CID" ]; then
    case "$CID$CSEC" in *null*|"") echo "no credentials in response"; exit 1 ;; esac
    echo "  writing secret"
    kubectl -n "$NS" create secret generic "$SECRET" \
      --from-literal=POLARIS_CREDENTIAL="$CID:$CSEC" \
      --from-literal=POLARIS_CLIENT_ID="$CID" \
      --from-literal=POLARIS_CLIENT_SECRET="$CSEC" \
      --dry-run=client -o yaml | kubectl apply -f -
  fi
done
echo "identities complete"