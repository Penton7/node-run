#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

open_ports() {
    sudo systemctl stop massad
    . <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/ports_opening.sh) 31244 31245
    sudo tee <<EOF >/dev/null $HOME/massa/massa-node/config/config.toml
[network]
routable_ip = "`wget -qO- eth0.me`"
EOF
    sudo apt install net-tools -y
    netstat -ntlp | grep "massa-node"
    sudo systemctl restart massad
}

sudo apt update

wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1l-1ubuntu1.3_amd64.deb

sudo dpkg -i libssl1.1_1.1.1l-1ubuntu1.3_amd64.deb

local massa_version=`wget -qO- https://api.github.com/repos/massalabs/massa/releases/latest | jq -r ".tag_name"`
    wget -qO $HOME/massa.tar.gz "https://github.com/massalabs/massa/releases/download/${massa_version}/massa_${massa_version}_release_linux.tar.gz"
    if [ `wc -c < "$HOME/massa.tar.gz"` -ge 1000 ]; then
	rm -rf $HOME/massa/
	tar -xvf $HOME/massa.tar.gz
	chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client
    fi

echo "[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/massa-node/massa-node
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/massad.service

sudo systemctl enable massad
sudo systemctl daemon-reload
#sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
open_ports

cd $HOME/massa/massa-client/

./massa-client wallet_generate_private_key