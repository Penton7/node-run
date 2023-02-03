#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

#Install Go 1.18.3
wget https://golang.org/dl/go1.18.3.linux-amd64.tar.gz; \
rm -rv /usr/local/go; \
tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && \
rm -v go1.18.3.linux-amd64.tar.gz && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version > /dev/null

#Install binary project
cd $HOME && git clone https://github.com/haqq-network/haqq && \
cd haqq && \
make install && \
haqqd version

read -p "Enter Node name: " node_name;

#Init moniker and set chainid
haqqd init $node_name --chain-id haqq_54211-2 && \
haqqd config chain-id haqq_54211-2

#Create wallet
haqqd keys add $node_name

#Add genesis account
haqqd add-genesis-account $node_name 10000000000000000000aISLM

#Create gentx
haqqd gentx $node_name 10000000000000000000aISLM \
--chain-id=haqq_54211-2 \
--moniker="$node_name" \
--commission-max-change-rate 0.05 \
--commission-max-rate 0.20 \
--commission-rate 0.05 \
--website="" \
--security-contact="" \
--identity="" \
--details=""