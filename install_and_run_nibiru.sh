#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update
sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git gcc chrony curl jq ncdu bsdmainutils htop net-tools lsof fail2ban wget -y

ver="1.19.4" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

cd $HOME
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.19.2
make build

sudo mv ./build/nibid /usr/local/bin/
cd $HOME

read -p "enter node name:" node_name

NIBIRU_MONIKER="$node_name"
NIBIRU_CHAIN="nibiru-itn-1"
NIBIRU_WALLET="$node_name"
FAUCET_URL="https://faucet.itn-1.nibiru.fi/"


echo 'export NIBIRU_MONIKER='${NIBIRU_MONIKER} >> $HOME/.bash_profile
echo 'export NIBIRU_CHAIN='${NIBIRU_CHAIN} >> $HOME/.bash_profile
echo 'export NIBIRU_WALLET='${NIBIRU_WALLET} >> $HOME/.bash_profile
source $HOME/.bash_profile

nibid init $NIBIRU_MONIKER --chain-id $NIBIRU_CHAIN

nibid config chain-id $NIBIRU_CHAIN

curl -s https://rpc.itn-1.nibiru.fi/genesis | jq -r .result.genesis > $HOME/.nibid/config/genesis.json

read -r -p "Create Pruning?[y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    pruning="custom"
    pruning_keep_recent="1000"
    pruning_interval="10"
    sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nibid/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml
else
    echo "next..."
fi

read -r -p "Off Indexer?[y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nibid/config/config.toml
else
    echo "..."
fi

NETWORK=nibiru-itn-1
sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.itn.nibiru.fi/$NETWORK/seeds)'"|g' $HOME/.nibid/config/config.toml

sed -i.bak 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml

sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibid
After=network-online.target
[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid

sleep 10

read -r -p "Create Wallet?[y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  nibid keys add $NIBIRU_WALLET
  NIBIRU_ADDR=$(nibid keys show $NIBIRU_WALLET -a)
  echo "SAVE MNEMONIC!!!"
  sleep 20
  echo 'export NIBIRU_ADDR='${NIBIRU_ADDR} >> $HOME/.bash_profile
  source $HOME/.bash_profile
else
  echo "..."
fi

curl -X POST -d '{"address": "'"$NIBIRU_ADDR"'", "coins": ["11000000unibi","100000000unusd","100000000uusdt"]}' $FAUCET_URL

sleep 15

nibid query bank balances $NIBIRU_ADDR
