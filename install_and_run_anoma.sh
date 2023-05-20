#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

export NAMADA_TAG=v0.15.3
export TM_HASH=v0.1.5-abciplus

#git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
#
##build
#make build-release
#make install
#
##install tendermint
#git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
#make build

wget -qO $HOME/namada.tar.gz https://github.com/anoma/namada/releases/download/v0.15.3/namada-v0.15.3-Linux-x86_64.tar.gz
rm -rf $HOME/namada-v0.15.3-Linux-x86_64/
tar -xvf $HOME/namada.tar.gz
cd namada-v0.15.3-Linux-x86_64
cp namada* /usr/bin/

namada --version

read -p "Enter node name: " ALIAS

export CHAIN_ID="public-testnet-8.0.b92ef72b820"

cd ~

namada client utils join-network --chain-id $CHAIN_ID --genesis-validator $ALIAS

sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=Namada Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/.namada
ExecStart=/usr/bin/namada --base-dir=/root/.namada node ledger run
Restart=always
RestartSec=3
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namada
sudo systemctl restart namada