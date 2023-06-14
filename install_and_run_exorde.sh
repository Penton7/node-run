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

git clone https://github.com/exorde-labs/ExordeModuleCLI.git

cd ./ExordeModuleCLI

git pull

#docker build -t exorde-cli .

read -p "Enter ETH Wallet Address: " ETH_WALLET


#docker run -d -e PYTHONUNBUFFERED=1 exorde-cli -m $ETH_WALLET -l 2

#docker ps -a

docker run \
-d \
--restart unless-stopped \
--pull always \
--name exorde \
exordelabs/exorde-cli -m $ETH_WALLET