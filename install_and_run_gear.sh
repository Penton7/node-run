#!/usr/bin/bash

echo  "────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"
echo  "─██████████████─██████████████─████████──────────██████████████─██████─────────██████████████─██████──██████─██████████████─"
echo  "─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░██──────────██░░░░░░░░░░██─██░░██─────────██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─"
echo  "─██░░██████░░██─██░░██████░░██─████░░██──────────██░░██████░░██─██░░██─────────██░░██████░░██─██░░██──██░░██─██░░██████░░██─"
echo  "─██░░██──██░░██─██░░██──██░░██───██░░██──────────██░░██──██░░██─██░░██─────────██░░██──██░░██─██░░██──██░░██─██░░██──██░░██─"
echo  "─██░░██──██░░██─██░░██──██░░██───██░░██──────────██░░██████░░██─██░░██─────────██░░██████░░██─██░░██████░░██─██░░██████░░██─"
echo  "─██░░██──██░░██─██░░██──██░░██───██░░██──────────██░░░░░░░░░░██─██░░██─────────██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─"
echo  "─██░░██──██░░██─██░░██──██░░██───██░░██──────────██░░██████░░██─██░░██─────────██░░██████████─██░░██████░░██─██░░██████░░██─"
echo  "─██░░██──██░░██─██░░██──██░░██───██░░██──────────██░░██──██░░██─██░░██─────────██░░██─────────██░░██──██░░██─██░░██──██░░██─"
echo  "─██░░██████░░██─██░░██████░░██─████░░████─██████─██░░██──██░░██─██░░██████████─██░░██─────────██░░██──██░░██─██░░██──██░░██─"
echo  "─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░██─██░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░██─────────██░░██──██░░██─██░░██──██░░██─"
echo  "─██████████████─██████████████─██████████─██████─██████──██████─██████████████─██████─────────██████──██████─██████──██████─"
echo  "────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────";

sudo apt-get update

sudo apt install -y git clang curl libssl-dev llvm libudev-dev

#curl https://sh.rustup.rs -sSf | sh

#source ~/.cargo/env

#rustup default stable;

#rustup update;

#rustup update nightly;

#rustup target add wasm32-unknown-unknown --toolchain nightly;

wget https://builds.gear.rs/gear-nightly-linux-x86_64.tar.xz && \

tar xvf gear-nightly-linux-x86_64.tar.xz && \

rm gear-nightly-linux-x86_64.tar.xz && \

chmod +x gear-node

read -p "Enter Node name: " node_name

echo "
[Unit] 
Description=Gear Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=$HOME/gear-node \
        --name $node_name \
        --execution wasm \
        --log runtime
Restart=on-failure
RestartSec=3
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/gear-node.service

sudo systemctl restart systemd-journald

sudo systemctl daemon-reload

sudo systemctl enable gear-node

sudo systemctl restart gear-node

#rustup toolchain add nightly;

#rustup target add wasm32-unknown-unknown --toolchain nightly;

./gear-node --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0' --name "$node_name"


