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

wget -qO $HOME/aptos.zip "https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.1/aptos-cli-0.3.1-Ubuntu-x86_64.zip"
unzip $HOME/aptos.zip

sudo cp ~/aptos /usr/bin/

export WORKSPACE=aptos-ait3
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE

#wget https://raw.githubusercontent.com/Penton7/node-run/main/aptos/docker-compose.yml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml

ip=$(wget -qO- eth0.me)


aptos genesis generate-keys --assume-yes --output-dir ~/$WORKSPACE
read -p "Enter Node name: " node_name;

aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $node_name \
    --validator-host $ip:6180

aptos key generate --output-file root_key
key_pub=$(cat root_key.pub)
key="0x"$key_pub

echo "
root_key: \"D04470F43AB6AEAA4EB616B72128881EEF77346F2075FFE68E14BA7DEBD8095E\"
users: [\"$node_name\"]
chain_id: 43
allow_new_validators: false
epoch_duration_secs: 7200
is_test: true
min_stake: 100000000000000
min_voting_threshold: 100000000000000
max_stake: 100000000000000000
recurring_lockup_duration_secs: 86400
required_proposer_stake: 100000000000000
rewards_apy_percentage: 10
voting_duration_secs: 43200
voting_power_increase_limit: 20" > layout.yaml

wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.3.0/framework.mrb

aptos genesis generate-genesis --assume-yes --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
sleep 2

docker-compose up -d