#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

export NAMADA_TAG=v0.14.1
export TM_HASH=v0.1.4-abciplus

git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG

#build
make build-release
make install

#install tendermint
git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build

namada --version

export CHAIN_ID="public-testnet-4.0.16a35d789f4"
namada client utils join-network --chain-id $CHAIN_ID

sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=Namada Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=$(which namada) node ledger run
Restart=always
RestartSec=3
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namada
sudo systemctl start namada