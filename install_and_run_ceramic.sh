#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt update

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

source .bashrc

nvm install 16

mkdir "${HOME}/.npm-packages"
npm config set prefix "${HOME}/.npm-packages"

NPM_PACKAGES="${HOME}/.npm-packages"
echo export PATH="$PATH:$NPM_PACKAGES/bin" >> .bash_profile
echo export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man" >> .bash_profile

source ~/.bash_profile

npm install -g @ceramicnetwork/cli

nvm use --delete-prefix v16.18.1 --silent


echo "[Unit]
      Description=Ceramic Node
      After=network.target

      [Service]
      User=root
      Type=simple
      WorkingDirectory=/root/.npm-packages
      ExecStart=/root/ceramic daemon
      Restart=on-failure
      LimitNOFILE=65535
      
      StandardOutput=append:/var/log/ceramic-daemon.log
      StandardError=append:/var/log/ceramic-daemon.log

      [Install]
      WantedBy=multi-user.target" > /etc/systemd/system/ceramic-daemon.service

sudo systemctl enable ceramic-daemon
sudo systemctl start ceramic-daemon
sudo systemctl status ceramic-daemon
