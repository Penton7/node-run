#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)


sudo systemctl stop subspaced subspaced-farmer

latest=$(wget -qO- https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name") && \
wget https://github.com/subspace/subspace/releases/download/${latest}/subspace-farmer-ubuntu-x86_64-${latest} -O subspace-farmer && \
wget https://github.com/subspace/subspace/releases/download/${latest}/subspace-node-ubuntu-x86_64-${latest} -O subspace-node && \

chmod +x subspace* && \
mv subspace* /usr/local/bin/

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer
