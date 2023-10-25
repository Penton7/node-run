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

if [ -d "$HOME/.lightning" ]; then
  echo "Directory exist..."
else
  echo "Directory not found. Creating..."
  mkdir .lightning
fi

echo "Creating FLEEK dir..."

if [ -d "$HOME/fleek" ]; then
  echo "Directory exist..."
else
  echo "Directory not found. Creating..."
  mkdir fleek
fi

cd fleek

docker-compose.yml <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/compose-files/docker-compose.fleek.yml)

docker-compose pull

docker-compose run -d

echo "Node started."

echo "Check logs command:  docker-compose logs"