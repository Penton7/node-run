#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update

sudo apt install make build-essential gcc git jq chrony -y

wget -q -O - https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar xvzf - -C /usr/local

cat <<EOT >> $HOME/.bashrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export GO111MODULE=on
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
EOT

source ~/.bashrc

go version

git clone https://github.com/mars-protocol/hub

cd hub

git checkout v1.0.0-rc7

make install

read -p "Enter Node Name: " node_name;

marsd init $node_name --chain-id ares-1

read -p "Enter Key Name: " key_name;

marsd keys add $key_name

wget -O ~/.mars/config/genesis.json https://raw.githubusercontent.com/mars-protocol/networks/main/ares-1/genesis.json

export SEEDS=TBD
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.mars/config/config.toml

sudo cat <<EOF >> /etc/systemd/system/marsd.service
[Unit]
Description=Mars Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/.go/bin/marsd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start marsd
