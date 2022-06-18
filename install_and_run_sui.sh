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

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

cd $HOME

git clone https://github.com/MystenLabs/sui.git

cd sui/docker/fullnode

wget https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml

wget https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

sed "s/3.9/3.3/g" docker-compose.yaml

sed "s/127.0.0.1/0.0.0.0/g" fullnode-template.yaml

docker-compose up -d
