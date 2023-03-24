#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

#Env for node
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export DEFUND_MONIKER='$NODENAME >> $HOME/.bash_profile
fi
DEFUND_PORT=40
if [ ! $WALLET ]; then
	echo "export DEFUND_WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEFUND_CHAIN=orbit-alpha-1" >> $HOME/.bash_profile
echo "export DEFUND_PORT=${DEFUND_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

sudo apt-get update;
sudo apt install make clang pkg-config libssl-dev build-essential git gcc chrony curl jq ncdu bsdmainutils htop net-tools lsof fail2ban wget -y;

#check and install GOLANG
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.4"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

#clone; build; install
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.2.6
make install
cd $HOME
defundd version

defundd init $DEFUND_MONIKER --chain-id $DEFUND_CHAIN

SEEDS=f902d7562b7687000334369c491654e176afd26d@170.187.157.19:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@rpc-1.defund.nodes.guru:45656
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.defund/config/config.toml
peers="f902d7562b7687000334369c491654e176afd26d@170.187.157.19:26656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@rpc-2.defund.nodes.guru:45656,878c7b70a38f041d49928dc02418619f85eecbf6@rpc-3.defund.nodes.guru:45656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.defund/config/config.toml

curl -s https://raw.githubusercontent.com/defund-labs/testnet/main/orbit-alpha-1/genesis.json > ~/.defund/config/genesis.json

read -r -p "Create Pruning?[y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    pruning="custom"
    pruning_keep_recent="1000"
    pruning_keep_every="0"
    pruning_interval="50"
    sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
    sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml
else
    echo "next..."
fi

indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.defund/config/config.toml

sed -i.bak 's/minimum-gas-prices =.*/minimum-gas-prices = "0.0025ufetf"/g' $HOME/.defund/config/app.toml

sudo tee /etc/systemd/system/defund.service > /dev/null <<EOF
[Unit]
Description=Defund
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable defund
sudo systemctl restart defund


read -r -p "Do You Have Wallet?[y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  defundd keys add $DEFUND_WALLET --recover
  DEFUND_ADDR=$(defundd keys show $DEFUND_WALLET -a)
  echo 'export DEFUND_ADDR='${DEFUND_ADDR} >> $HOME/.bash_profile
  source $HOME/.bash_profile
else
  defundd keys add $DEFUND_WALLET
  DEFUND_ADDR=$(defundd keys show $DEFUND_WALLET -a)
  echo "SAVE MNEMONIC!!!"
  sleep 20
  echo 'export DEFUND_ADDR='${DEFUND_ADDR} >> $HOME/.bash_profile
  source $HOME/.bash_profile
fi

defundd query bank balances $DEFUND_ADDR


