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

wget https://github.com/massalabs/massa/releases/download/TEST.10.0/massa_TEST.10.0_release_linux.tar.gz

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
	    if [ ! -d $HOME/massa_backup ]; then
		./massa-client wallet_generate_private_key
	    else
		sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
		sudo systemctl restart massad
		sudo cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat	
	    fi
	    . <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/insert_variables.sh)
	    if [ ! -d $HOME/massa_backup ]; then
		mkdir $HOME/massa_backup
		sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
		sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
	    fi
