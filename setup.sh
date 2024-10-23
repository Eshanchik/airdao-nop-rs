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

git clone https://github.com/Eshanchik/airdao-nop-rs.git
cd airdao-nop-rs || return

chmod +x update.sh
./update.sh

# Verify that the system is based on Debian or Ubuntu
if [ -f /etc/debian_version ]; then
    DISTRO=$(lsb_release -is)
    ARCH=$(uname -m)

    if [[ "$DISTRO" == "Debian" || "$DISTRO" == "Ubuntu" ]]; then
        if [[ "$ARCH" == "x86_64" ]]; then
            echo "Detected: $DISTRO with $ARCH architecture"
            curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" -H "X-GitHub-Api-Version: 2022-11-28" -o airdao-nop-release.zip https://api.github.com/repos/Eshanchik/airdao-nop-rs/releases/assets/201163639
            unzip airdao-nop-release.zip
            rm airdao-nop-release.zip
            chmod +x ./airdao-nop-rs
        elif [[ "$ARCH" == "arm64" ]]; then
            echo "Detected: $DISTRO with $ARCH architecture"
            curl -L -H "Accept: application/octet-stream" -H "Authorization: Bearer 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" -H "X-GitHub-Api-Version: 2022-11-28" -o airdao-nop-release.zip https://api.github.com/repos/Eshanchik/airdao-nop-rs/releases/assets/201163639
            unzip airdao-nop-release.zip
            rm airdao-nop-release.zip
            chmod +x ./airdao-nop-rs
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
    else
        echo "Unsupported distribution: $DISTRO"
        exit 1
    fi
else
    echo "This script only supports Debian/Ubuntu based systems."
    exit 1
fi

./airdao-nop-rs
