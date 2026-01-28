#!/bin/sh
set -eu

REPORT="/tmp/boot-report.txt"
RAW_DMESG="/tmp/boot-report-dmesg.raw"

: > "$REPORT"

log() {
  printf "%s\n" "$*" >> "$REPORT"
}

run_cmd() {
  label="$1"
  shift
  log ""
  log "## $label"
  if [ "$#" -eq 0 ]; then
    return 0
  fi
  if command -v "$1" >/dev/null 2>&1; then
    "$@" >>"$REPORT" 2>&1 || log "[warn] command failed: $*"
  else
    log "[missing] $1"
  fi
}

cat_file() {
  label="$1"
  file="$2"
  log ""
  log "## $label"
  if [ -r "$file" ]; then
    cat "$file" >>"$REPORT" 2>&1 || log "[warn] failed to read $file"
  else
    log "[missing] $file"
  fi
}

list_dir() {
  label="$1"
  dir="$2"
  log ""
  log "## $label"
  if [ -d "$dir" ]; then
    ls -la "$dir" >>"$REPORT" 2>&1 || log "[warn] failed to list $dir"
  else
    log "[missing] $dir"
  fi
}

detect_init() {
  if command -v systemd-analyze >/dev/null 2>&1 || [ -x /bin/systemd ] || [ -x /sbin/systemd ]; then
    echo "systemd"
  elif [ -f /etc/inittab ]; then
    echo "sysvinit/busybox (inittab present)"
  else
    if command -v ps >/dev/null 2>&1; then
      comm=$(ps -p 1 -o comm= 2>/dev/null || true)
      if [ -n "$comm" ]; then
        echo "$comm"
      else
        echo "unknown"
      fi
    else
      echo "unknown"
    fi
  fi
}

compute_gaps() {
  if command -v dmesg >/dev/null 2>&1; then
    dmesg >"$RAW_DMESG" 2>/dev/null || true
    awk 'match($0,/^\[[[:space:]]*([0-9]+(\.[0-9]+)?)\]/,a){
           t=a[1]+0;
           if(prev!=""){
             gap=t-prev;
             if(gap>0){
               printf "%10.3f s gap: %10.3f -> %10.3f | %s\n",gap,prev,t,$0
             }
           }
           prev=t
         }' "$RAW_DMESG" 2>/dev/null \
      | sort -nr 2>/dev/null \
      | head -n 5 2>/dev/null || true
  else
    echo "[missing] dmesg"
  fi
  return 0
}

if [ -r /proc/uptime ]; then
  UPTIME=$(awk '{print $1}' /proc/uptime 2>/dev/null || cat /proc/uptime)
else
  UPTIME="missing"
fi

INIT_SYS=$(detect_init)
GAPS=$(compute_gaps)

log "Boot Time Report"
log "Summary:"
log "Uptime seconds: $UPTIME"
log "Detected init system: $INIT_SYS"
log "Suspected largest dmesg gaps:"
if [ -n "$GAPS" ]; then
  printf "%s\n" "$GAPS" | while IFS= read -r line; do
    log "  $line"
  done
else
  log "  [no data]"
fi

cat_file "Kernel cmdline" "/proc/cmdline"
cat_file "Uptime (raw)" "/proc/uptime"

run_cmd "dmesg (raw)" dmesg
run_cmd "dmesg (human, if available)" dmesg -T

if command -v systemd-analyze >/dev/null 2>&1; then
  run_cmd "systemd-analyze" systemd-analyze
  run_cmd "systemd-analyze blame" systemd-analyze blame
  run_cmd "systemd-analyze critical-chain" systemd-analyze critical-chain
fi

cat_file "/etc/inittab" "/etc/inittab"
list_dir "/etc/init.d" "/etc/init.d"
list_dir "/etc/rcS.d" "/etc/rcS.d"

run_cmd "mount" mount
cat_file "/proc/mounts" "/proc/mounts"
cat_file "/etc/fstab" "/etc/fstab"

run_cmd "ip addr" ip addr
run_cmd "ip route" ip route
run_cmd "ps" ps

run_cmd "logread (last 200 lines, if available)" logread -n 200

log ""
log "Report written to $REPORT"
echo "$REPORT"
