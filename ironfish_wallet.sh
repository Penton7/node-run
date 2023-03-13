#!/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

cd $HOME
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt update
sudo apt install curl make clang pkg-config libssl-dev build-essential git jq nodejs -y

sudo npm install -g ironfish@0.1.70

echo -e "\e[1;32mType command for create wallet: \e[39m \e[1;44m ironfish wallet:create wallet \e[0m \n"

echo -e "\e[1;32mType command for export wallet: \e[39m \e[1;44m ironfish wallet:export wallet \e[0m \033[31;1;5m \n"

echo -e "\e[1;32mType command for export wallet MNEMONIC: \e[39m \e[1;44m ironfish wallet:export wallet --mnemonic --language=English \e[0m \n"