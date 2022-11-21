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

snarkos account new

nohup ./run-prover.sh