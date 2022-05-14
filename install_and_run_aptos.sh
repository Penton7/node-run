#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get update;

sudo apt-get install -y docker.io;

sudo groupadd docker;

sudo usermod -aG docker $USER;

sudo chmod 666 /var/run/docker.sock

sudo systemctl restart docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

wget -qO $HOME/aptos.zip "https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip"
unzip $HOME/aptos.zip

sudo cp ~/aptos /usr/bin/

export WORKSPACE=testnet
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE

wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml

aptos genesis generate-keys --output-dir ~/$WORKSPACE
read -p "Enter Node name: " node_name;

ip=$(wget -qO- eth0.me)
aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $node_name \
    --validator-host $ip:6180 \
    --full-node-host $ip:6182


echo "---
      root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
      users:
        - $node_name
      chain_id: 23" | tee layout.yaml


wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip framework.zip

aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE

docker-compose up -d