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
sudo rm -rf /usr/local/go /usr/bin/go
wget -q https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
sudo tar -xzf go1.21.6.linux-amd64.tar.gz -C /usr/local
sudo tar -xzf go1.21.6.linux-amd64.tar.gz -C /usr/bin
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
export GO111MODULE=on
#GOPATH MUST BE OUTSIDE OF GOROOT directory!!!
export GOPATH=/mnt/sda1/programming/gopath
export PATH=$PATH:$GOPATH/bin
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPROXY=direct
source ~/.bashrc

# Clone project repository
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.8.3

# Build binaries
make build
make install

# Prepare binaries for Cosmovisor
mkdir -p $HOME/.babylond/cosmovisor/genesis/bin
mv build/babylond $HOME/.babylond/cosmovisor/genesis/bin/
rm -rf build

# Create application symlinks
sudo ln -s $HOME/.babylond/cosmovisor/genesis $HOME/.babylond/cosmovisor/current -f
sudo ln -s $HOME/.babylond/cosmovisor/current/bin/babylond /usr/local/bin/babylond -f

# Initialize the node
babylond init $BABYLON_MONIKER --chain-id bbn-test-3

wget https://github.com/babylonchain/networks/raw/main/bbn-test-3/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json

# Set minimum gas price
sed -i -e "s|^network *=.*|network = \"signet\"|" ~/.babylond/config/app.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00001ubbn\"|" $HOME/.babylond/config/app.toml

mkdir -p ~/.babylond
mkdir -p ~/.babylond/cosmovisor
mkdir -p ~/.babylond/cosmovisor/genesis
mkdir -p ~/.babylond/cosmovisor/genesis/bin
mkdir -p ~/.babylond/cosmovisor/upgrades

# Download and install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Create service
sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=Babylon daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --x-crisis-skip-assert-invariants
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_NAME=babylond"
Environment="DAEMON_HOME=${HOME}/.babylond"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"

[Install]
WantedBy=multi-user.target
EOF
sudo -S systemctl daemon-reload
sudo -S systemctl enable babylond
sudo -S systemctl start babylond



# Replace the --keyring-backend argument with a backend of your choice
#babylond --keyring-backend test keys add my-key
#babylond keys add wallet

# Set pruning
#sed -i \
#  -e 's|^pruning *=.*|pruning = "custom"|' \
#  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
#  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
#  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
#  $HOME/.babylond/config/app.toml

### NEED RUN NEXT ###
# babylond create-bls-key $ADDR
# sed -i -e "s|^timeout_commit *=.*|timeout_commit = \"30s\"|" ~/.babylond/config/config.toml
# sed -i -e "s|^key-name *=.*|key-name = \"wallet\"|" $HOME/.babylond/config/app.toml
#{
#        "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":""},
#        "amount": "1000000stake",
#        "moniker": "penton7",
#        "security": "noreply@a01k.io",
#        "details": "node runner",
#        "commission-rate": "0.1",
#        "commission-max-rate": "0.2",
#        "commission-max-change-rate": "0.01",
#        "min-self-delegation": "1"
#}
# babylond tx checkpointing create-validator ~/.babylond/config/validator.json \
#      --chain-id="bbn-test-3" \
#      --gas="auto" \
#      --gas-adjustment="1.5" \
#      --gas-prices="0.025ubbn" \
#      --from=wallet