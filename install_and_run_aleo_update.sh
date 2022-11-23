#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

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


      [Install]
      WantedBy=multi-user.target" > /etc/systemd/system/aleod.service

sudo systemctl enable aleod
sudo systemctl start aleod
sudo systemctl status aleod