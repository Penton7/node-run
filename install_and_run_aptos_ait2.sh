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

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

wget -qO $HOME/aptos.zip "https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-0.2.0/aptos-cli-0.2.0-Ubuntu-x86_64.zip"
unzip $HOME/aptos.zip

sudo cp ~/aptos /usr/bin/

export WORKSPACE=aptos-ait2
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE

#wget https://raw.githubusercontent.com/Penton7/node-run/main/aptos/docker-compose.yml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml

ip=$(wget -qO- eth0.me)


aptos genesis generate-keys --output-dir ~/$WORKSPACE
read -p "Enter Node name: " node_name;

aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $node_name \
    --validator-host $ip:6180

aptos key generate --output-file root_key
key_pub=$(cat root_key.pub)
key="0x"$key_pub

echo "---
      root_key: "$key"
      users:
        - $node_name
      chain_id: 40
      min_stake: 0
      max_stake: 100000
      min_lockup_duration_secs: 0
      max_lockup_duration_secs: 2592000
      epoch_duration_secs: 86400
      initial_lockup_timestamp: 1656615600
      min_price_per_gas_unit: 1
      allow_new_validators: true" | tee layout.yaml

wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.2.0/framework.zip
unzip framework.zip

aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE

docker-compose up -d