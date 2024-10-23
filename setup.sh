#!/bin/bash

# Change /etc/needrestart/needrestart.conf to skip confirmations for restarting required services
sed -i 's/^#\$nrconf{restart} = '\''i'\'';/$nrconf{restart} = '\''a'\'';/' /etc/needrestart/needrestart.conf

# Install required packages
apt-get install -y \
    libssl-dev \
    pkg-config \
    ca-certificates \
    git \
    jq

# Install Docker and Docker Compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

curl -L https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

git clone https://github.com/ambrosus/airdao-nop.git
cd airdao-nop || return

./update.sh

# Check OS and download the appropriate binary
if [ -f /etc/debian_version ]; then
    DISTRO=$(lsb_release -is)
    ARCH=$(uname -m)

    if [[ "$DISTRO" == "Debian" || "$DISTRO" == "Ubuntu" ]]; then
        if [[ "$ARCH" == "x86_64" ]]; then
            echo "Detected $DISTRO with architecture $ARCH"
            # Download binary for Debian/Ubuntu x86_64
            curl -L -o airdao-nop-release https://your-link-to-binary/airdao-nop-release-x86_64
        elif [[ "$ARCH" == "arm64" ]]; then
            echo "Detected $DISTRO with architecture $ARCH"
            # Download binary for Debian/Ubuntu arm64
            curl -L -o airdao-nop-release https://your-link-to-binary/airdao-nop-release-arm64
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
    else
        echo "Unsupported distribution: $DISTRO"
        exit 1
    fi
else
    echo "This script supports only Debian/Ubuntu systems."
    exit 1
fi