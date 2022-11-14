#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

#Env for node
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
DEFUND_PORT=40
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEFUND_CHAIN_ID=defund-private-2" >> $HOME/.bash_profile
echo "export DEFUND_PORT=${DEFUND_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

sudo apt-get update;
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y;

#check and install GOLANG
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.1.0
make install

defundd config chain-id $DEFUND_CHAIN_ID
defundd config keyring-backend test
defundd config node tcp://localhost:${DEFUND_PORT}657
defundd init $NODENAME --chain-id $DEFUND_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.defund/config/genesis.json "https://raw.githubusercontent.com/defund-labs/testnet/main/defund-private-2/genesis.json"

# set peers and seeds
SEEDS="85279852bd306c385402185e0125dffeed36bf22@38.146.3.194:26656,09ce2d3fc0fdc9d1e879888e7d72ae0fefef6e3d@65.108.105.48:11256"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml
