#!/usr/bin/env bash
#
# rebuild_cluster.sh - tear down, provision and configure the production cluster,
# timing every phase (and per-VM provisioning / per-Ansible-task times).
#
# Usage:
#   ./rebuild_cluster.sh                 # run from repo root
#   REPO_ROOT=/path/to/repo ./rebuild_cluster.sh
#   VM_FILTER='proxmox_vm|aws_instance' ./rebuild_cluster.sh
#
# Env vars:
#   REPO_ROOT   repo root (default: current directory)
#   VM_FILTER   regex matched against terraform resource addresses to decide
#               which resources count as "VMs" (default below)
#   LOG_DIR     where logs/summary are written (default: ./rebuild-logs/<timestamp>)

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$PWD}"
TF_DIR="$REPO_ROOT/infra/production/terraform"
ANSIBLE_DIR="$REPO_ROOT/infra/production/ansible"
HELPER="$REPO_ROOT/infra/production/helpers/parse_inventory.py"
INVENTORY="$ANSIBLE_DIR/inventory.ini"
PLAYBOOK="playbooks/setup.yaml"

VM_FILTER="${VM_FILTER:-virtual_machine|_vm|instance|droplet|server|libvirt_domain}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="${LOG_DIR:-$REPO_ROOT/rebuild-logs/$STAMP}"
mkdir -p "$LOG_DIR"

# ---------- timing helpers ----------

now() {
  if [[ -n "${EPOCHREALTIME:-}" ]]; then
    echo "${EPOCHREALTIME/,/.}"
  elif date +%s.%N 2>/dev/null | grep -qv N; then
    date +%s.%N
  else
    python3 -c 'import time; print(f"{time.time():.6f}")'
  fi
}

fmt() { # seconds -> "1m 23.4s"
  awk -v s="$1" 'BEGIN {
    h = int(s/3600); m = int((s-h*3600)/60); sec = s - h*3600 - m*60
    if (h > 0)      printf "%dh %dm %.1fs", h, m, sec
    else if (m > 0) printf "%dm %.1fs", m, sec
    else            printf "%.1fs", sec
  }'
}

STEP_NAMES=()
STEP_SECS=()
FAILED_STEP=""

print_summary() {
  local total=0 i
  {
    echo
    echo "=============== TIMING SUMMARY ==============="
    for i in "${!STEP_NAMES[@]}"; do
      printf "  %-28s %s\n" "${STEP_NAMES[$i]}" "$(fmt "${STEP_SECS[$i]}")"
      total=$(awk -v a="$total" -v b="${STEP_SECS[$i]}" 'BEGIN{print a+b}')
    done
    echo "  ------------------------------------------"
    printf "  %-28s %s\n" "TOTAL" "$(fmt "$total")"
    [[ -n "$FAILED_STEP" ]] && echo "  !! FAILED during: $FAILED_STEP"
    echo "=============================================="
    echo "Logs: $LOG_DIR"
  } | tee "$LOG_DIR/summary.txt"
}

# run_step "<name>" <command...>
run_step() {
  local name="$1"; shift
  echo
  echo ">>> [$name] started at $(date '+%H:%M:%S')"
  local start end rc=0
  start=$(now)
  "$@" || rc=$?
  end=$(now)
  local secs
  secs=$(awk -v a="$start" -v b="$end" 'BEGIN{printf "%.3f", b-a}')
  STEP_NAMES+=("$name")
  STEP_SECS+=("$secs")
  echo "<<< [$name] finished in $(fmt "$secs") (exit $rc)"
  if (( rc != 0 )); then
    FAILED_STEP="$name"
    print_summary
    exit "$rc"
  fi
}

# ---------- parse "Creation complete after 1m5s" lines from terraform logs ----------

parse_tf_durations() { # <logfile> <label> <verb: Creation|Destruction>
  python3 - "$1" "$2" "$3" "$VM_FILTER" <<'PY'
import re, sys

logfile, label, verb, vm_filter = sys.argv[1:5]
pat = re.compile(rf"^(\S+): {verb} complete after (\S+)")
unit = re.compile(r"(?:(\d+)h)?(?:(\d+)m(?!s))?(?:(\d+(?:\.\d+)?)(ms|s))?")

def to_secs(s):
    m = unit.fullmatch(s)
    if not m:
        return None
    h, mi, v, u = m.groups()
    total = int(h or 0) * 3600 + int(mi or 0) * 60
    if v:
        total += float(v) / (1000 if u == "ms" else 1)
    return total

def fmt(t):
    m, s = divmod(t, 60)
    return f"{int(m)}m {s:04.1f}s" if m else f"{s:.1f}s"

rows = []
with open(logfile, errors="replace") as f:
    for line in f:
        m = pat.match(line.strip())
        if m:
            secs = to_secs(m.group(2))
            if secs is not None:
                rows.append((m.group(1), secs))

if not rows:
    print(f"\n[{label}] no '{verb} complete' lines found in log")
    sys.exit(0)

vms = [r for r in rows if re.search(vm_filter, r[0])]
print(f"\n--- {label}: per-resource times (resources run in parallel, so these overlap) ---")
for name, secs in sorted(rows, key=lambda r: -r[1]):
    tag = "  [VM]" if (name, secs) in vms else ""
    print(f"  {name:<60} {fmt(secs):>10}{tag}")

if vms:
    avg = sum(s for _, s in vms) / len(vms)
    print(f"\n  VMs: {len(vms)} | avg {fmt(avg)} | "
          f"min {fmt(min(s for _, s in vms))} | max {fmt(max(s for _, s in vms))}")
else:
    print(f"\n  (no resources matched VM_FILTER='{vm_filter}'; adjust it to get per-VM stats)")
PY
}

# ---------- steps ----------

do_destroy() {
  ( cd "$TF_DIR" && terraform destroy -auto-approve -no-color ) 2>&1 | tee "$LOG_DIR/01-destroy.log"
}

do_apply() {
  ( cd "$TF_DIR" && terraform apply -auto-approve -no-color ) 2>&1 | tee "$LOG_DIR/02-apply.log"
}

do_inventory() {
  ( cd "$TF_DIR" && terraform output -json ) | python3 "$HELPER" "$INVENTORY"
}

do_ansible() {
  (
    cd "$ANSIBLE_DIR"
    # profile_tasks => per-task timings; timer => total playbook time
    export ANSIBLE_CALLBACKS_ENABLED="profile_tasks,timer"
    export ANSIBLE_CALLBACK_WHITELIST="profile_tasks,timer"   # older Ansible
    export PROFILE_TASKS_SORT_ORDER="descending"
    export PROFILE_TASKS_TASK_OUTPUT_LIMIT="15"
    ansible-playbook "$PLAYBOOK" -v
  ) 2>&1 | tee "$LOG_DIR/04-ansible.log"
}

# ---------- main ----------

echo "Cluster rebuild started $(date)"
echo "Logs: $LOG_DIR"

run_step "terraform destroy"     do_destroy
run_step "terraform apply"       do_apply
run_step "generate inventory"    do_inventory
run_step "ansible configuration" do_ansible

parse_tf_durations "$LOG_DIR/01-destroy.log" "Teardown"  "Destruction" | tee -a "$LOG_DIR/summary.txt"
parse_tf_durations "$LOG_DIR/02-apply.log"   "Provision" "Creation"    | tee -a "$LOG_DIR/summary.txt"

print_summary