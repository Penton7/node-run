#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get update;

sudo apt-get install -y docker.io unzip;

sudo groupadd docker;

sudo usermod -aG docker $USER;

sudo chmod 666 /var/run/docker.sock

sudo systemctl restart docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

mkdir ironfish && cd ironfish

wget https://raw.githubusercontent.com/Penton7/node-run/main/ironfish/docker-compose.yml

read -p "Enter Node Name: " NODENAME;

echo "node_name=$NODENAME"

docker-compose pull

docker-compose up -d

sleep 15;

docker-compose exec node ironfish config:set enableTelemetry true


