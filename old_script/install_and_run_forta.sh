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

sudo curl https://dist.forta.network/pgp.public -o /usr/share/keyrings/forta-keyring.asc -s;

echo 'deb [signed-by=/usr/share/keyrings/forta-keyring.asc] https://dist.forta.network/repositories/apt stable main' | sudo tee -a /etc/apt/sources.list.d/forta.list;

sudo apt-get update;

sudo apt-get install -y docker.io forta;

sudo groupadd docker;

sudo usermod -aG docker $USER;

sudo echo '{
   "default-address-pools": [
        {
            "base":"172.17.0.0/12",
            "size":16
        },
        {
            "base":"192.168.0.0/16",
            "size":20
        },
        {
            "base":"10.99.0.0/16",
            "size":24
        }
    ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker

read -p "passphrase: " passphrase

forta init --passphrase $passphrase

sudo mkdir /etc/systemd/system/forta.service.d

sudo echo '
[Service]
Environment="FORTA_DIR='$HOME'/.forta"
Environment="FORTA_PASSPHRASE='$passphrase'"
' | sudo tee /etc/systemd/system/forta.service.d/env.conf

echo '
chainId: 56

scan:
  jsonRpc:
    url: https://bsc-dataseed.binance.org/

trace:
  enabled: false

' | tee -a $HOME/.forta/config.yml


sudo systemctl enable forta

sudo systemctl start forta

#forta run --passphrase $passphrase
