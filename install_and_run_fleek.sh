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

sudo apt-get install -y unzip;

checkDocker

curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

cd $HOME

mkdir .lightning

sudo docker run \
    -d \
    -p 4200-4299:4200-4299 \
    -p 4300-4399:4300-4399 \
    --mount type=bind,source=$HOME/.lightning,target=/root/.lightning \
    --name lightning-node \
    -it ghcr.io/fleek-network/lightning:latest