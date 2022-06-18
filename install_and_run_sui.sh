#!/usr/bin/bash

function checkDocker {
  if systemctl --all --type service | grep -q "docker";then
      echo "docker exists."
  else
      echo "docker does NOT exist."
      sudo apt-get install -y docker.io;

      sudo groupadd docker;

      sudo usermod -aG docker $USER;

      sudo chmod 666 /var/run/docker.sock

      sudo systemctl restart docker
  fi
}

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get update;

checkDocker

cd $HOME

git clone https://github.com/MystenLabs/sui.git

cd sui/docker/fullnode

wget https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml

wget https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

docker-compose up -d