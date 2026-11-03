#!/usr/bin/env bash
#
# image_report.sh - report on container images in the cluster.
#
# Produces, in one timestamped directory:
#   cache_images.txt   images in use + digests, formatted as a CACHE_IMAGES=( ... ) body
#   running.txt        the same images, one per line, unquoted (registry/image@sha256:...)
#   latest.tsv         workloads/pods using :latest or an untagged image (digest-pinned images skipped)
#   always.tsv         workloads/pods with imagePullPolicy: Always
#   pause.txt          pause image(s) cached on the nodes (not visible in pod status)
#   diff.txt           diff against CACHE_IMAGES in harbor.conf (only if HARBOR_CONF is set)
#   summary.txt        counts and the same tables, printed to the screen at the end
#
# Usage:
#   ./image_report.sh
#   KUBECONFIG=~/.kube/config-production ./image_report.sh
#   HARBOR_CONF=./harbor.conf OUT_DIR=./reports ./image_report.sh
#
# Env vars:
#   KUBECONFIG   cluster to query            (default: kubectl's default)
#   HARBOR_CONF  harbor.conf to diff against (default: none)
#   KEEP_FILE    text file of extra registry/image@sha256:... lines (one per line) to always
#                include, for images that only run on demand (e.g. a Spark image). They are
#                added to cache_images.txt and are not flagged as stale in diff.txt.
#   OUT_DIR      parent directory for output (default: ./image-reports)
#
# Needs: kubectl, jq. Read-only: nothing in the cluster is changed.

set -euo pipefail

OUT_DIR="${OUT_DIR:-./image-reports}"
HARBOR_CONF="${HARBOR_CONF:-}"
KEEP_FILE="${KEEP_FILE:-}"
STAMP="$(date +%Y%m%d-%H%M%S)"
REPORT="$OUT_DIR/$STAMP"

for bin in kubectl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "Missing required tool: $bin" >&2; exit 1; }
done
kubectl version --request-timeout=10s >/dev/null 2>&1 || { echo "Cannot reach the cluster with kubectl (check KUBECONFIG)." >&2; exit 1; }

mkdir -p "$REPORT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ---------- fetch once, reuse ----------

echo "Fetching cluster state..."
kubectl get pods -A -o json > "$WORK/pods.json"
kubectl get deploy,sts,ds,job,cronjob -A -o json > "$WORK/workloads.json"
kubectl get nodes -o json > "$WORK/nodes.json"

# ---------- 1. images in use, with the digest the nodes actually pulled ----------

jq -r '
  [ .items[]
    | ((.status.containerStatuses // [])
     + (.status.initContainerStatuses // [])
     + (.status.ephemeralContainerStatuses // []))[]
    | .imageID ]
  | map(select(test("@sha256:")) | sub("^docker-pullable://"; ""))
  | unique | .[]' "$WORK/pods.json" > "$REPORT/running.txt"

# pods whose imageID had no registry digest (e.g. locally loaded images): listed so nothing is silently dropped
jq -r '
  [ .items[] | . as $p
    | ((.status.containerStatuses // [])
     + (.status.initContainerStatuses // [])
     + (.status.ephemeralContainerStatuses // []))[]
    | select((.imageID // "") | test("@sha256:") | not)
    | "\($p.metadata.namespace)/\($p.metadata.name)\t\(.name)\t\(.image)\t\(.imageID // "")" ]
  | unique | .[]' "$WORK/pods.json" > "$REPORT/no-digest.tsv"

# pause image(s) are not in pod status, so they come from the node image list
jq -r '.items[].status.images[]?.names[] | select(test("@sha256:")) | select(test("/pause@"))' \
  "$WORK/nodes.json" | sort -u > "$REPORT/pause.txt"

# full set to cache = running images + pause + anything in KEEP_FILE
{
  cat "$REPORT/running.txt" "$REPORT/pause.txt"
  if [[ -n "$KEEP_FILE" ]]; then
    if [[ -f "$KEEP_FILE" ]]; then grep -o '[A-Za-z0-9./_-]*@sha256:[a-f0-9]*' "$KEEP_FILE" || true
    else echo "KEEP_FILE=$KEEP_FILE not found; ignoring." >&2; fi
  fi
} | sort -u > "$WORK/all_images.txt"

awk -F/ '
BEGIN { m["docker.io"]="dockerhub"; m["ghcr.io"]="ghcr"; m["quay.io"]="quay"; m["registry.k8s.io"]="k8s-registry"; m["cgr.dev"]="cgr" }
$1 != last { if (NR > 1) print ""; print "  # " $1 " → " (($1 in m) ? m[$1] : "UNMAPPED"); last = $1 }
{ printf "  \"%s\"\n", $0 }' "$WORK/all_images.txt" > "$REPORT/cache_images.txt"

# ---------- 2. :latest / untagged, and 3. imagePullPolicy: Always ----------
# Workload level (where you fix it in Git) plus pod level (catches operator-created pods).

LATEST_FILTER='
  select(.image | test("@sha256:") | not)
  | select(.image | (test(":latest$") or (test(":[^/]+$") | not)))'

{
  printf 'SOURCE\tCONTAINER\tIMAGE\tPULL_POLICY\n'
  {
    jq -r '
      .items[] | . as $o
      | (.spec.template // .spec.jobTemplate.spec.template).spec
      | ((.containers // []) + (.initContainers // []))[]
      | '"$LATEST_FILTER"'
      | "\($o.kind)/\($o.metadata.namespace)/\($o.metadata.name)\t\(.name)\t\(.image)\t\(.imagePullPolicy // "default")"' "$WORK/workloads.json"
    jq -r '
      .items[] | . as $p
      | ((.spec.containers // []) + (.spec.initContainers // []))[]
      | '"$LATEST_FILTER"'
      | "Pod/\($p.metadata.namespace)/\($p.metadata.name)\t\(.name)\t\(.image)\t\(.imagePullPolicy // "default")"' "$WORK/pods.json"
  } | sort -u
} > "$REPORT/latest.tsv"

{
  printf 'SOURCE\tCONTAINER\tIMAGE\n'
  {
    jq -r '
      .items[] | . as $o
      | (.spec.template // .spec.jobTemplate.spec.template).spec
      | ((.containers // []) + (.initContainers // []))[]
      | select(.imagePullPolicy == "Always")
      | "\($o.kind)/\($o.metadata.namespace)/\($o.metadata.name)\t\(.name)\t\(.image)"' "$WORK/workloads.json"
    jq -r '
      .items[] | . as $p
      | ((.spec.containers // []) + (.spec.initContainers // []))[]
      | select(.imagePullPolicy == "Always")
      | "Pod/\($p.metadata.namespace)/\($p.metadata.name)\t\(.name)\t\(.image)"' "$WORK/pods.json"
  } | sort -u
} > "$REPORT/always.tsv"

# ---------- optional: diff against harbor.conf ----------

if [[ -n "$HARBOR_CONF" ]]; then
  if [[ -f "$HARBOR_CONF" ]]; then
    sed -n '/^CACHE_IMAGES=(/,/^)/p' "$HARBOR_CONF" \
      | grep -o '[A-Za-z0-9./_-]*@sha256:[a-f0-9]*' | sort -u > "$WORK/old.txt" || true
    cp "$WORK/all_images.txt" "$WORK/new.txt"
    # "<" = in harbor.conf but not running or kept (stale, or not running right now); ">" = running but missing from harbor.conf
    diff "$WORK/old.txt" "$WORK/new.txt" > "$REPORT/diff.txt" || true
  else
    echo "HARBOR_CONF=$HARBOR_CONF not found; skipping diff." >&2
  fi
fi

# ---------- summary ----------

count() { grep -c . "$1" 2>/dev/null || true; }
rows()  { tail -n +2 "$1" | grep -c . || true; }

{
  echo "Image report  $(date)"
  echo "Cluster: $(kubectl config current-context 2>/dev/null || echo unknown)"
  echo "Output:  $REPORT"
  echo
  echo "Images in use (with digest) ........ $(count "$REPORT/running.txt")"
  echo "Containers without a registry digest $(count "$REPORT/no-digest.tsv")   (usually pods still starting/pulling; see no-digest.tsv)"
  echo ":latest / untagged ................. $(rows "$REPORT/latest.tsv")"
  echo "imagePullPolicy: Always ............ $(rows "$REPORT/always.tsv")"
  if [[ -s "$REPORT/pause.txt" ]]; then
    echo "Pause image(s) on nodes:"; sed 's/^/  /' "$REPORT/pause.txt"
  fi
  if [[ -f "$REPORT/diff.txt" ]]; then
    echo "Diff vs $HARBOR_CONF: $(grep -c '^<' "$REPORT/diff.txt" || true) only in harbor.conf, $(grep -c '^>' "$REPORT/diff.txt" || true) only in cluster (see diff.txt)"
  fi
  if grep -q 'UNMAPPED' "$REPORT/cache_images.txt"; then
    echo
    echo "!! UNMAPPED registries in cache_images.txt: add them to harbor_project_for() and the Harbor config."
  fi
  echo
  echo "=== :latest / untagged ==="
  if [[ "$(rows "$REPORT/latest.tsv")" -gt 0 ]]; then column -t -s $'\t' "$REPORT/latest.tsv" 2>/dev/null || cat "$REPORT/latest.tsv"; else echo "(none)"; fi
  echo
  echo "=== imagePullPolicy: Always ==="
  if [[ "$(rows "$REPORT/always.tsv")" -gt 0 ]]; then column -t -s $'\t' "$REPORT/always.tsv" 2>/dev/null || cat "$REPORT/always.tsv"; else echo "(none)"; fi
  echo
  echo "Notes:"
  echo " - Only pods running right now are seen. CronJob pods between runs, JupyterHub/Spark/Airflow/CNPG pods"
  echo "   created on demand, and scaled-to-zero workloads need their digests added by hand."
  echo " - Workload rows are where to fix things in Git; Pod rows may come from operators or Helm charts."
} | tee "$REPORT/summary.txt"
