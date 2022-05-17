#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

cd $HOME
rm -rf subspace*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/snapshot-2022-may-03/subspace-node-ubuntu-x86_64-snapshot-2022-may-03
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/snapshot-2022-may-03/subspace-farmer-ubuntu-x86_64-snapshot-2022-may-03
chmod +x subspace*
mv subspace* /usr/local/bin/

read -p "Enter Node Name: " SUBSPACE_NODENAME;
read -p "Enter Your Wallet: " SUBSPACE_WALLET;

echo 'export SUBSPACE_NODENAME='$SUBSPACE_NODENAME >> $HOME/.bash_profile
echo 'export SUBSPACE_WALLET='$SUBSPACE_WALLET >> $HOME/.bash_profile

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain testnet --wasm-execution compiled --execution wasm --bootnodes \"/dns/farm-rpc.subspace.network/tcp/30333/p2p/12D3KooWPjMZuSYj35ehced2MTJFf95upwpHKgKUrFRfHwohzJXr\" --rpc-cors all --rpc-methods unsafe --ws-external --validator --telemetry-url \"wss://telemetry.polkadot.io/submit/ 1\" --telemetry-url \"wss://telemetry.subspace.network/submit 1\" --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $SUBSPACE_WALLET --plot-size 20G
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


mv $HOME/subspaced* /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer
