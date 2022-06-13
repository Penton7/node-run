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

cd ~

git clone https://github.com/masa-finance/masa-node-v1.0.git masa

cd masa

wget https://raw.githubusercontent.com/Penton7/node-run/main/masa/docker-compose.01k.yml

read -p "Enter Node Name: " node_name;

echo "NODE_ID=$node_name"

PRIVATE_CONFIG=ignore docker-compose -f docker-compose.01k.yml up -d

sleep 5

docker-compose exec masa-node geth attach /qdata/dd/geth.ipc --exec web3.admin.nodeInfo.enode | sed "s|127.0.0.1|$(wget -qO- eth0.me)|"
