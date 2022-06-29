#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop screen unzip bc fail2ban htop -y

# Install GO 1.17.2
cd $HOME && \
ver="1.17.2" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

read -p "Enter Node Name: " MONIKER;
read -p "Enter Wallet Name: " WALLET;

# Set variables
TIKER=palomad && \
CHAIN=paloma-testnet-5 && \
TOKEN=ugrain && \
PROJECT=palomad && \
CONFIG=.paloma && \
NODE=http://localhost:26657 && \
GENESIS_JSON_PATH=https://raw.githubusercontent.com/palomachain/testnet/master/paloma-testnet-5/genesis.json

# ONE COMMAND
echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile && \
echo "export WALLET=$WALLET" >> $HOME/.bash_profile && \
echo "export TIKER=$TIKER" >> $HOME/.bash_profile && \
echo "export CHAIN=$CHAIN" >> $HOME/.bash_profile && \
echo "export TOKEN=$TOKEN" >> $HOME/.bash_profile && \
echo "export PROJECT=$PROJECT" >> $HOME/.bash_profile && \
echo "export CONFIG=$CONFIG" >> $HOME/.bash_profile && \
echo "export NODE=$NODE" >> $HOME/.bash_profile && \
echo "export GENESIS_JSON_PATH=$GENESIS_JSON_PATH" >> $HOME/.bash_profile && \
source $HOME/.bash_profile

# Get binar
sudo wget -O - https://github.com/palomachain/paloma/releases/download/v0.2.4-prealpha/paloma_0.2.4-prealpha_Linux_x86_64.tar.gz | \
sudo tar -C /usr/local/bin -xvzf - palomad
sudo chmod +x /usr/local/bin/palomad
# Required until we figure out cgo
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/api/libwasmvm.x86_64.so

$TIKER init $MONIKER --chain-id $CHAIN && \
$TIKER config chain-id $CHAIN && \
$TIKER config keyring-backend test && \
$TIKER config node $NODE

sudo tee /etc/systemd/system/$TIKER.service > /dev/null <<EOF
[Unit]
Description=$PROJECT Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which $TIKER) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Start service | ONE COMMAND
sudo systemctl daemon-reload && \
sudo systemctl enable $TIKER && \
sudo systemctl restart $TIKER && \
sudo journalctl -u $TIKER -f -o cat
