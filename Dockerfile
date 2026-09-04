# Start from Debian slim to keep image small. Install common tools used by this repo.
# NOTE: Running raw network scans from inside a container requires additional Linux capabilities
# (e.g., --cap-add=NET_RAW --cap-add=NET_ADMIN) or privileged mode. Use cautiously and only
# against targets you are authorized to test.

FROM debian:bookworm-slim

LABEL maintainer="ASM Shamimul Islam <82109063+Cyber-Nexsus@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Install core packages (keep list minimal; users can modify Dockerfile for more tools)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    gnupg \
    curl \
    wget \
    ca-certificates \
    net-tools \
    iproute2 \
    nmap \
    hping3 \
    proxychains4 \
    masscan \
    sqlmap \
    nikto \
    gobuster \
    netcat-openbsd \
    tcpdump \
    jq \
    whois \
 && rm -rf /var/lib/apt/lists/*

# Create workdir and copy repo files (optional)
WORKDIR /opt/zeroipspoof
COPY . /opt/zeroipspoof

# Ensure scripts are executable
RUN chmod +x /opt/zeroipspoof/install.sh || true
RUN chmod +x /opt/zeroipspoof/tools/run_scans.sh || true

# Entrypoint prints a short help - container not designed for unattended scans
ENTRYPOINT ["/bin/bash", "-lc", "echo \"ZeroIPSpoof container ready. Read /opt/zeroipspoof/README.md and use tools/run_scans.sh with authorization.\" && /bin/bash"]
