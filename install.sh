#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# name=install.sh
# Safe installer for common, authorized penetration-testing tools
# Purpose: Install tools on a Debian/Ubuntu/Kali-based system for use in authorized security testing only.
# IMPORTANT: This script intentionally does NOT include or automate any techniques to bypass
#          security controls (CDNs, WAFs, rate-limits) or to perform IP spoofing/evasion.
#          Use only with explicit, written authorization and follow rules of engagement.

set -euo pipefail

REPO_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "  ZeroIPSpoof - Safe installer"
echo "=============================================="

cat <<'EOF'
WARNING:
- This installer will add common security-testing tools to your system (nmap, hping3, proxychains4, etc.).
- ONLY run scans and active tests against systems you OWN or for which you have EXPLICIT WRITTEN PERMISSION.
- This script intentionally does NOT provide or automate evasion, spoofing, or WAF/CDN bypass techniques.
EOF

read -r -p "Do you HAVE explicit written permission to test the intended target(s)? Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Permission not confirmed. Aborting installation." >&2
  exit 1
fi

# Detect Debian-based systems (Debian/Ubuntu/Kali)
if [ -f /etc/debian_version ]; then
  echo "Debian-based system detected. Updating package lists..."
  sudo apt-get update -y

  echo "Installing common, authorized security-testing tools..."
  sudo apt-get install -y --no-install-recommends \
    nmap \
    nmap-scripts \
    hping3 \
    proxychains4 \
    masscan \
    sqlmap \
    nikto \
    gobuster \
    netcat-openbsd \
    tcpdump \
    curl \
    wget \
    jq \
    whois || {
      echo "Some packages may have failed to install. Please inspect apt output." >&2
    }

  # Optional: metasploit-framework on Kali (may not be needed on all systems)
  if grep -qi kali /etc/os-release 2>/dev/null || [ -f /etc/kalilinux-version ]; then
    echo "Detected Kali Linux. Installing metasploit-framework (may take time)..."
    sudo apt-get install -y metasploit-framework || echo "metasploit-framework install failed or skipped"
  fi
else
  echo "Unsupported OS for this installer. Please run on Debian/Ubuntu/Kali-based system." >&2
  exit 2
fi

# Create an INSTALL_NOTICE and safety guidance in the repo root
cat > "$REPO_ROOT_DIR/INSTALL_NOTICE.txt" <<'EOF'
ZeroIPSpoof - Installer notice
--------------------------------
This machine now has common security-testing tools installed (nmap, hping3, proxychains4, etc.).

IMPORTANT:
- Only perform security testing on systems you OWN or for which you have EXPLICIT WRITTEN PERMISSION.
- Do NOT attempt to bypass WAFs, CDNs, or any defensive controls without documented authorization and an approved method.
- proxychains4 only proxies TCP-based connections. UDP and ICMP traffic will NOT be tunneled through proxychains4.
- This repository intentionally omits automation for IP spoofing, decoy scans, and other evasion techniques.

Recommended next steps:
1) Keep proof of authorization and defined scope for all engagements.
2) Use staging/test environments when possible.
3) Consult your organization's legal/compliance team before performing high-impact tests.

EOF

chmod 644 "$REPO_ROOT_DIR/INSTALL_NOTICE.txt" || true

echo "Installation complete. See INSTALL_NOTICE.txt in the repository for safety guidance."
