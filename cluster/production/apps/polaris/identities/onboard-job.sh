#!/bin/sh
# Ensures one Polaris principal + principal role per tool and delivers each tool's credential as a
# Kubernetes Secret in the tool's own namespace. Idempotent; credentials are only issued when needed.
#   IDENTITIES = space separated "principal:namespace:secretName" entries
#
# Polaris shows a client secret ONLY when it is created or reset. Two safeguards follow from that:
#   1. Before touching Polaris, check that this ServiceAccount may write the Secret (otherwise the one-time
#      secret would be lost).
#   2. If a principal exists but its Secret is missing, issue a new secret: try the reset endpoint first and,
#      if the root principal is not allowed to use it, delete and recreate the principal. (Rotation is not
#      usable here: Polaris only lets a principal rotate its OWN credentials.)
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

  # Safeguard 1: never create or change anything in Polaris if we cannot deliver the credential.
  for verb in get create patch update; do
    if ! kubectl auth can-i "$verb" secrets -n "$NS" >/dev/null 2>&1; then
      echo "FAILED: cannot '$verb' secrets in namespace '$NS' (missing namespace or RoleBinding?). Nothing was changed in Polaris." >&2
      exit 1
    fi
  done

  CID=""; CSEC=""
  code=$(api POST "$MGMT/principals" "{\"principal\":{\"name\":\"$P\"}}")
  if [ "$code" = "409" ]; then
    if kubectl -n "$NS" get secret "$SECRET" >/dev/null 2>&1; then
      echo "  principal and secret exist, credentials untouched"
    else
      # Safeguard 2: principal exists but we no longer hold its secret.
      echo "  principal exists but secret is missing -> resetting credentials"
      code=$(api POST "$MGMT/principals/$P/reset")
      if [ "$code" != "200" ]; then
        echo "  reset not permitted ($code) -> recreating principal"
        ok "$(api DELETE "$MGMT/principals/$P")" "delete principal"
        code=$(api POST "$MGMT/principals" "{\"principal\":{\"name\":\"$P\"}}")
        [ "$code" = "201" ] || { echo "FAILED: recreate principal -> $code"; cat "$OUT"; echo; exit 1; }
        echo "  recreate principal -> 201"
      else
        echo "  reset -> 200"
      fi
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