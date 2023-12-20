#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt-get update;

wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz

sudo rm -rf /usr/local/go

sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

rm go1.21.5.linux-amd64.tar.gz

echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile

source ~/.bash_profile

go version

git clone https://github.com/masa-finance/masa-oracle-go-testnet.git

cd masa-oracle-go-testnet

go build -v -o masa-node ./cmd/masa-node

#mkdir /root/.masa

#echo "private.key=/root/.masa/masa_oracle_key" > /root/.masa/masa_oracle_node.env

#read -p "Enter Secret Key Wallet:" secret_key;

#echo "${secret_key}" > /root/.masa/masa_oracle_key.ecdsa

#echo "08021220${secret_key}" > /root/.masa/masa_oracle_key

sudo tee <<EOF >/dev/null /etc/systemd/system/masad.service
[Unit]
Description=MASA103
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/root/masa-oracle-go-testnet
ExecStart=/root/masa-oracle-go-testnet/masa-node --bootnodes=/ip4/35.224.231.145/udp/4001/quic-v1/p2p/16Uiu2HAm47nBiewWLLzCREtY8vwPQtr5jTqyrEoUo6WnngwhsQuR,/ip4/104.198.43.138/udp/4001/quic-v1/p2p/16Uiu2HAkxiP8jjdHQWeCxTr7pD6BvoPkS8Z1skjCy9vdSRMACDcc,/ip4/107.223.13.174/udp/5001/quic-v1/p2p/16Uiu2HAmMkXJJpPAdEmp9QSqdcTPzvV2UxvZMEhYdVLFzbQHHczp,/ip4/35.202.227.74/udp/4001/quic-v1/p2p/16Uiu2HAmHuUejpUBFPCxy32QhGRAbv3tFwbzXmLkCoaNcZTyWWqN,/ip4/93.187.217.133/udp/4001/quic-v1/p2p/16Uiu2HAm5wvEfWGufJ1roGL6VhpFZ4scqPF1giLwES9jXfeEoeHs,/ip4/10.128.0.47/udp/4001/quic-v1/p2p/16Uiu2HAkxiP8jjdHQWeCxTr7pD6BvoPkS8Z1skjCy9vdSRMACDcc,/ip4/147.75.56.191/udp/4001/quic-v1/p2p/16Uiu2HAmVrXpTot74CFpdFNpTs26QminLwXT3HhXPSc1MFjnqqSR,/ip4/107.223.13.174/udp/4001/quic-v1/p2p/16Uiu2HAm2uQ5TGviRkqhYMpg7fjeoB4TfpSAhrbY87YZ4h9jYCNm,/ip4/34.171.201.124/udp/4001/quic-v1/p2p/16Uiu2HAmCKzfsynicpryPZTdcJsjmyzXn8tA13zMHHsoBxLdvVCE,/ip4/34.132.48.64/udp/4001/quic-v1/p2p/16Uiu2HAmNk4DDNiVu8ipN2cg5GLpGzN6ydd4EYps1NkiTDBRkctu --port=8080 --udp=true --tcp=false --start=true
Restart=on-failure
RestartSec=10
Environment=
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl enable masad

#sudo systemctl restart masad

