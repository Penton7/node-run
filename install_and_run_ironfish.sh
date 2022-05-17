#!/usr/bin/bash
#function installSnapshot {
#	# block: 290805
#	echo -e '\n\e[42mInstalling snapshot...\e[0m\n' && sleep 1
#  cd ~
#  wget -O $HOME/ironfish_snapshot_08112021.tar.gz https://storage.nodes.guru/ironfish_snapshot_08112021.tar.gz
#  mv $HOME/.ironfish/databases $HOME/.ironfish/databases_old
#  tar -xf $HOME/ironfish_snapshot_08112021.tar.gz -C $HOME/.ironfish
#  }

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

mkdir ironfish && cd ironfish

wget https://raw.githubusercontent.com/Penton7/node-run/main/ironfish/docker-compose.yml

read -p "Enter Node Name: " NODENAME;

echo "node_name=$NODENAME" > .env

docker-compose pull

docker-compose up -d

sleep 15;

docker-compose exec node ironfish config:set enableTelemetry true

docker-compose exec node ironfish status