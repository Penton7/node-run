#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo rm -rf gitopia .gitopia

sudo apt-get update

sudo apt-get install -y make gcc golang-go

mkdir -p $HOME/go/bin

echo "export PATH=$PATH:$(go env GOPATH)/bin" >> ~/.bash_profile

source ~/.bash_profile

curl https://get.gitopia.com | sudo bash

git clone -b v0.13.0 gitopia://gitopia1dlpc7ps63kj5v0kn5v8eq9sn2n8v8r5z9jmwff/gitopia;

cd gitopia && make install

sudo cp $HOME/go/bin/gitopiad /usr/bin/gitopiad
read -p "Enter Node Name: " MONIKER
export GITOPIA_MONIKER="$MONIKER"
export GITOPIA_CHAIN_ID="gitopia-janus-testnet"

gitopiad init --chain-id $GITOPIA_CHAIN_ID $GITOPIA_MONIKER


curl -s "$GITOPIA_NET/genesis.json" > $HOME/.gitopia/config/genesis.json

gitopiad validate-genesis
#git clone gitopia://gitopia1dlpc7ps63kj5v0kn5v8eq9sn2n8v8r5z9jmwff/testnets;

#cp ./testnets/$GITOPIA_CHAIN_ID/genesis.json $HOME/.gitopia/config/genesis.json;
sudo tee <<EOF >/dev/null /etc/systemd/system/gitopiad.service

[Unit]
Description=gitopia Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=/usr/bin/gitopiad start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl daemon-reload
sudo systemctl restart systemd-journald
sudo systemctl restart gitopiad
