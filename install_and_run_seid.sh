#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

apt update && apt-get install -y git make build-essential

cd $HOME

ver="1.18.1" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.6beta

make install;

mv ~/go/bin/seid /usr/local/bin/


read -p "Enter Node Name: " MONIKER;

echo 'export MONIKER='$MONIKER >> $HOME/.bash_profile
source ~/.bash_profile
sleep 1

seid init $MONIKER --chain-id sei-testnet-2 -o

external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26666\"/" $HOME/.sei/config/config.toml

# Obtain the genesis file for sei-testnet-2:
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json > ~/.sei/config/genesis.json
# Obtain the address book for sei-testnet-2
curl https://raw.githubusercontent.com/Penton7/node-run/main/sei/addrbook.json > ~/.sei/config/addrbook.json

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

#seid tx staking create-validator \
#    --amount 1usei \
#    --pubkey "sei18ugzutfu9m0dwrrdg278h000k3x8zvwcmdyp2c" \
#    --moniker penton7 \
#    --chain-id "sei-testnet-2" \
#    --from penton7 \
#    --commission-rate "0.10" \
#    --commission-max-rate "0.20" \
#    --commission-max-change-rate "0.01" \
#    --min-self-delegation "1" \
#    --fees "2000usei"
#
#
#    seid tx staking create-validator \
#        --amount=1usei \
#        --pubkey=$PUBKEY \
#        --moniker=$MONIKER \
#        --chain-id "sei-testnet-2" \
#        --from=penton7 \
#        --commission-rate="0.10" \
#        --commission-max-rate="0.20" \
#        --commission-max-change-rate="0.01" \
#        --min-self-delegation="1" \
#        --fees="2000usei"
