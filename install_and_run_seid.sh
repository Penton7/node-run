#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

cd $HOME

wget https://github.com/Penton7/node-run/raw/main/sei/seid/seid

mv ./seid /usr/local/bin/

read -p "Enter Node Name: " MONIKER;

echo 'export MONIKER='$MONIKER >> $HOME/.bash_profile
source ~/.bash_profile
sleep 1

seid init $MONIKER --chain-id sei-testnet-2 -o


# Obtain the genesis file for sei-testnet-1:
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json > ~/.sei/config/genesis.json
# Obtain the address book for sei-testnet-1
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json > ~/.sei/config/addrbook.json

sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.01usei"/g' $HOME/.sei/config/app.toml

sudo tee <<EOF >/dev/null /etc/systemd/system/seid.service
[Unit]
Description=Sei-Network Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=$(which seid) start
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable seid.service
sudo systemctl restart seid


