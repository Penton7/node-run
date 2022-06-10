#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo systemctl stop seid

apt update && apt-get install -y git make

cd $HOME

ver="1.18.1" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.3beta

make install;

mv ~/go/bin/seid /usr/local/bin/



sudo tee <<EOF >/dev/null /etc/systemd/system/seid.service
[Unit]
Description=Sei-Network Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=$(which seid) start
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable seid.service
sudo systemctl restart seid