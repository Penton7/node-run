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

git clone https://github.com/taikoxyz/simple-taiko-node.git

cd simple-taiko-node

cp .env.sample .env

read -p "Enter Private Key: " PRIVATE_KEY;

#read -p "Enter Wallet Address: " FEE_ADDRESS;

sed -i "s/ENABLE_PROVER=false/ENABLE_PROVER=true/g" .env

sed -i "s/L1_PROVER_PRIVATE_KEY=/L1_PROVER_PRIVATE_KEY=$PRIVATE_KEY/g" .env

read -p "Enter Sepolia HTTP Endpoint: " L1_ENDPOINT_HTTP;
read -p "Enter Sepolia WSS Endpoint: " L1_ENDPOINT_WS;

sed -i "s|L1_ENDPOINT_HTTP=|L1_ENDPOINT_HTTP=$L1_ENDPOINT_HTTP|g" .env

sed -i "s|L1_ENDPOINT_WS=|L1_ENDPOINT_WS=$L1_ENDPOINT_WS|g" .env


#sed "s/L2_SUGGESTED_FEE_RECIPIENT=/L2_SUGGESTED_FEE_RECIPIENT=$FEE_ADDRESS/g" -i .env.sample

docker-compose up -d