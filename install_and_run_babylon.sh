#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

#Env for node
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export BABYLON_MONIKER='$NODENAME >> $HOME/.bash_profile
fi

sudo apt -q update
sudo apt install git build-essential curl jq --yes
sudo apt -qy upgrade


#install GOLANG
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)


# Clone project repository
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.8.3

# Build binaries
make install

# Prepare binaries for Cosmovisor
mkdir -p $HOME/.babylond/cosmovisor/genesis/bin
mv build/babylond $HOME/.babylond/cosmovisor/genesis/bin/
rm -rf build

# Create application symlinks
sudo ln -s $HOME/.babylond/cosmovisor/genesis $HOME/.babylond/cosmovisor/current -f
sudo ln -s $HOME/.babylond/cosmovisor/current/bin/babylond /usr/local/bin/babylond -f

# Download and install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

wget https://github.com/babylonchain/networks/raw/main/bbn-test-3/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json

# Create service
sudo tee /etc/systemd/system/babylon.service > /dev/null << EOF
[Unit]
Description=babylon node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --x-crisis-skip-assert-invariants
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_NAME=babylond"
Environment="DAEMON_HOME=${HOME}/.babylond"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.babylond/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable babylon.service

# Set node configuration
babylond config chain-id bbn-test-3

# Replace the --keyring-backend argument with a backend of your choice
babylond --keyring-backend test keys add my-key

# Initialize the node
babylond init $BABYLON_MONIKER --chain-id bbn-test-3


# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00001ubbn\"|" $HOME/.babylond/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.babylond/config/app.toml

sudo systemctl start babylon.service && sudo journalctl -u babylon.service -f --no-hostname -o cat