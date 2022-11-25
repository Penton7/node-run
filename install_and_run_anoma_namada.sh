#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

cd $HOME

mkdir anoma-namada && cd anoma-namada

wget -qO./namada-ts https://github.com/anoma/namada-trusted-setup/releases/download/v1.1.0/namada-ts-linux-v1.1.0

read -p "Enter Namada TOKEN " TOKEN

./namada-ts contribute default https://contribute.namada.net $TOKEN
