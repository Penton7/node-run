#!/usr/bin/bash
FILE=~/.local/share/subspace-node/chains/subspace_test/network/secret_ed25519
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)


cd $HOME

if [ -f "$FILE" ]; then
    echo "Файл $FILE существует"
    mkdir backup-subspace
    cp ~/.local/share/subspace-node/chains/subspace_test/network/secret_ed25519 ~/backup-subspace/secret_ed25519
fi

sudo systemctl stop subspaced subspaced-farmer

farmer wipe && \
subspace purge-chain --chain gemini-1 -y > /dev/null 2>&1 && \
subspace purge-chain --chain testnet -y > /dev/null 2>&1

latest=$(wget -qO- https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name") && \
wget https://github.com/subspace/subspace/releases/download/${latest}/subspace-farmer-ubuntu-x86_64-${latest} -O subspace-farmer && \
wget https://github.com/subspace/subspace/releases/download/${latest}/subspace-node-ubuntu-x86_64-${latest} -O subspace-node && \

chmod +x subspace* && \
mv subspace* /usr/local/bin/

read -p "Enter Node Name: " SUBSPACE_NODENAME;
read -p "Enter Your Wallet: " SUBSPACE_WALLET;

echo 'export SUBSPACE_NODENAME='$SUBSPACE_NODENAME >> $HOME/.bash_profile
echo 'export SUBSPACE_WALLET='$SUBSPACE_WALLET >> $HOME/.bash_profile

source ~/.bash_profile
sleep 1

sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced.service
[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-node) \\
--chain="gemini-1" \\
--execution="wasm" \\
--pruning=1024 \\
--keep-blocks=1024 \\
--validator \\
--name="${SUBSPACE_NODENAME}"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced-farmer.service
[Unit]
Description=Subspace Farmer
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-farmer) farm \\
--reward-address=${SUBSPACE_WALLET} \\
--plot-size=100G
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer
