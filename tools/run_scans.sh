#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# name=tools/run_scans.sh
# Safe scan runner for authorized engagements.
# Usage examples:
#  ./tools/run_scans.sh --target example.com --mode http_vuln
#  ./tools/run_scans.sh --target 1.2.3.4 --mode quick_tcp --script "vuln"
#
# IMPORTANT: This script REQUIRES explicit written permission for the target.
# It intentionally does NOT automate WAF/CDN bypass, IP spoofing, or other evasion techniques.

set -euo pipefail

REPO_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="ChatGPT Image Jun 2, 2026, 01_08_01 PM.jpg"
IMAGE_PATH="$REPO_ROOT_DIR/$IMAGE_NAME"

print_usage(){
  cat <<EOF
Usage: $0 --target <target> --mode <mode> [--script <nse_script>] [--dry-run]

Modes:
  quick_tcp     - proxychains4 nmap -sT -Pn --open --script=<script>
  vuln_scan     - proxychains4 nmap -sS -O -sU --script=vuln <target>  (Note: -sU uses UDP; proxychains does NOT proxy UDP)
  slow_vuln     - proxychains4 nmap -sT -Pn -T1 --scan-delay 10s --script=vuln
  http_vuln     - proxychains4 nmap -sT -Pn -p 80,443 -T1 --scan-delay 15s --script=http-vuln-static,http-vuln* --script-args 'http.useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"'
  ntp_info      - sudo nmap -sU -p 123 --script=ntp-info <target>  (UDP scan; proxychains will not tunnel this)

Examples:
  $0 --target example.com --mode quick_tcp --script vuln
  $0 --target 10.0.0.5 --mode ntp_info

IMPORTANT: Only use against targets you have explicit written permission to test.
EOF
}

TARGET=""
MODE=""
NSE_SCRIPT=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --script) NSE_SCRIPT="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --help) print_usage; exit 0;;
    *) echo "Unknown arg: $1"; print_usage; exit 2;;
  esac
done

if [ -z "$TARGET" ] || [ -z "$MODE" ]; then
  print_usage
  exit 2
fi

# Show banner image if present. Try to open in default viewer, fallback to printing path.
show_image(){
  if [ -f "$IMAGE_PATH" ]; then
    echo "Displaying project image: $IMAGE_NAME"
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$IMAGE_PATH" >/dev/null 2>&1 || true
    elif command -v display >/dev/null 2>&1; then
      # ImageMagick's display
      display "$IMAGE_PATH" >/dev/null 2>&1 &
    elif command -v feh >/dev/null 2>&1; then
      feh "$IMAGE_PATH" >/dev/null 2>&1 &
    elif command -v img2txt >/dev/null 2>&1; then
      # libcaca img2txt / aalib
      img2txt "$IMAGE_PATH" || true
    else
      echo "Image file exists at: $IMAGE_PATH"
      echo "Install xdg-utils, feh, display (ImageMagick) or img2txt to open it automatically."
    fi
  else
    echo "No project image found at $IMAGE_PATH"
  fi
}

read -r -p "Do you HAVE explicit written permission to test ${TARGET}? Type YES to continue: " CONF
if [ "$CONF" != "YES" ]; then
  echo "Permission not confirmed. Aborting." >&2
  exit 1
fi

# show image in background (non-blocking if it opens a viewer)
show_image &

TS=$(date -u +"%Y%m%dT%H%M%SZ")
OUTDIR="scans/${TARGET}/${TS}"
mkdir -p "$OUTDIR"

run_cmd(){
  echo "+ $*"
  if [ "$DRY_RUN" -eq 0 ]; then
    # shellcheck disable=SC2086
    eval "$@" 2>&1 | tee -a "${OUTDIR}/scan.log"
  else
    echo "(dry-run) would run: $*"
  fi
}

case "$MODE" in
  quick_tcp)
    if [ -z "$NSE_SCRIPT" ]; then NSE_SCRIPT="default"; fi
    CMD="proxychains4 nmap -sT -Pn --open --script=${NSE_SCRIPT} ${TARGET} -oA ${OUTDIR}/quick_tcp"
    run_cmd "$CMD"
    ;;
  vuln_scan)
    echo "NOTE: vuln_scan includes a UDP (-sU) flag. proxychains4 will not proxy UDP traffic. You may need to run without proxychains for full UDP coverage."
    CMD="proxychains4 nmap -sS -O -sU --script=vuln ${TARGET} -oA ${OUTDIR}/vuln_scan"
    run_cmd "$CMD"
    ;;
  slow_vuln)
    CMD="proxychains4 nmap -sT -Pn -T1 --scan-delay 10s --script=vuln ${TARGET} -oA ${OUTDIR}/slow_vuln"
    run_cmd "$CMD"
    ;;
  http_vuln)
    CMD="proxychains4 nmap -sT -Pn -p 80,443 -T1 --scan-delay 15s --script=http-vuln-static,http-vuln* --script-args 'http.useragent=\"Mozilla/5.0 (Windows NT 10.0; Win64; x64)\"' ${TARGET} -oA ${OUTDIR}/http_vuln"
    run_cmd "$CMD"
    ;;
  ntp_info)
    echo "UDP scan: running direct (requires sudo). This will NOT be proxied via proxychains."
    CMD="sudo nmap -sU -p 123 --script=ntp-info ${TARGET} -oA ${OUTDIR}/ntp_info"
    run_cmd "$CMD"
    ;;
  *)
    echo "Unknown mode: $MODE"; print_usage; exit 3;
    ;;
esac

echo "Scan finished. Output in ${OUTDIR} (scan.log contains combined output)."
