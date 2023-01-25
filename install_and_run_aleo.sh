#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update && sudo apt install curl -y < "/dev/null"
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq

sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

git clone https://github.com/AleoHQ/snarkOS

cd snarkOS

cargo install --path .

read -p "Enter Private Key: " PROVER_KEY;

echo "[Unit]
      Description=Aleod Node
      After=network.target

      [Service]
      User=root
      Type=simple
      WorkingDirectory=/root/snarkOS
      ExecStart=/root/.cargo/bin/cargo run --release -- start --nodisplay --prover $PROVER_KEY
      Restart=on-failure
      LimitNOFILE=65535
      
      StandardOutput=append:/var/log/aleod.log
      StandardError=append:/var/log/aleod.log

      [Install]
      WantedBy=multi-user.target" > /etc/systemd/system/aleod.service

sudo systemctl enable aleod
sudo systemctl start aleod
sudo systemctl status aleod
