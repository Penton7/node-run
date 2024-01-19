#!/usr/bin/bash

. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

# Remove previous versions of Penumbra and related modules
echo "Removing old versions of Penumbra and related modules..."
sudo rm -rf /root/penumbra /root/cometbft

# Create a backup of wallet data
echo "Backing up wallet data..."
mkdir -p /root/penumbra_backup
cp -r /root/.penumbra /root/penumbra_backup

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev clang git-lfs tmux libclang-dev curl

# Install Go
GO_VERSION="1.18"
wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -xvf go${GO_VERSION}.linux-amd64.tar.gz
sudo mv go /usr/local

# Set Go environment variables
echo "export GOROOT=/usr/local/go" >> $HOME/.profile
echo "export GOPATH=$HOME/go" >> $HOME/.profile
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> $HOME/.profile
source $HOME/.profile

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Clone the Penumbra repository and checkout the specified version
git clone https://github.com/penumbra-zone/penumbra
cd penumbra
git fetch
git checkout v0.64.2

# Build pcli and pd
cargo build --release --bin pcli
cargo build --release --bin pd

# Install CometBFT
cd ..
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout v0.37.2

# Update Go modules
go mod tidy

# Proceed with installation
make install

# Increase the number of allowed open file descriptors
ulimit -n 4096

# Request the node name from the user
echo "Enter the name of your node:"
read MY_NODE_NAME

# Retrieve the external IP address of the server
IP_ADDRESS=$(curl -s ifconfig.me)

# Join the testnet
cd /root/penumbra
./target/release/pcli view reset
./target/release/pd testnet unsafe-reset-all
./target/release/pd testnet join --external-address $IP_ADDRESS:26656 --moniker $MY_NODE_NAME
cp ~/penumbra/target/release/pd /usr/local/bin/ || exit
cp ~/penumbra/target/release/pcli /usr/local/bin/ || exit
# Create a new wallet or restore an existing one
echo "Do you want to create a new wallet or restore an existing one? [new/restore]"
read WALLET_CHOICE
if [ "$WALLET_CHOICE" = "new" ]; then
    ./target/release/pcli init soft-kms generate
elif [ "$WALLET_CHOICE" = "restore" ]; then
    ./target/release/pcli init soft-kms import-phrase
    echo "Enter your seed phrase:"
    read SEED_PHRASE
    echo $SEED_PHRASE | ./target/release/pcli init soft-kms import-phrase
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo -e '\n\e[42mCreating a service for Cometbft Node ...\e[0m\n' && sleep 1

sudo tee /etc/systemd/system/cometbftd.service > /dev/null <<EOF
[Unit]
Description=Cometbft Node
After=network-online.target
[Service]
User=$USER
ExecStart=`which cometbft` start --home "$HOME/.penumbra/testnet_data/node0/cometbft/"
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

echo -e '\n\e[42mCreating a service for Penumbra Node...\e[0m\n' && sleep 1

sudo tee /etc/systemd/system/penumbrad.service > /dev/null <<EOF
[Unit]
Description=Penumbra Node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/pd start --home "$HOME/.penumbra/testnet_data/node0/pd"
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mEnabling cometbft and Penumbra Node services\e[0m\n' && sleep 1
sudo systemctl enable cometbftd
sudo systemctl enable penumbrad
sudo systemctl restart penumbrad
sleep 15
sudo systemctl restart cometbftd