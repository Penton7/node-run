#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo mkdir -p /etc/apt/keyrings
curl -fsSL repo.chainflip.io/keys/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/chainflip.gpg

gpg --show-keys /etc/apt/keyrings/chainflip.gpg

echo "deb [signed-by=/etc/apt/keyrings/chainflip.gpg] https://repo.chainflip.io/perseverance/ focal main" | sudo tee /etc/apt/sources.list.d/chainflip.list



sudo apt-get update;

sudo apt-get install -y unzip chainflip-cli chainflip-node chainflip-engine;

sudo mkdir /etc/chainflip/keys

read -p "Enter Your Validator Wallet Private Key: " VALIDATOR_WALLET_PRIVATE_KEY

echo -n "$VALIDATOR_WALLET_PRIVATE_KEY" | sudo tee /etc/chainflip/keys/ethereum_key_file

chainflip-node key generate

read -p "Enter Your Chainflip Secret Seed: " SECRET_SEED

echo -n "${SECRET_SEED:2}" | sudo tee /etc/chainflip/keys/signing_key_file

sudo chainflip-node key generate-node-key --file /etc/chainflip/keys/node_key_file

sudo chmod 600 /etc/chainflip/keys/ethereum_key_file
sudo chmod 600 /etc/chainflip/keys/signing_key_file
sudo chmod 600 /etc/chainflip/keys/node_key_file
history -c

sudo mkdir -p /etc/chainflip/config

ip=$(wget -qO- eth0.me)


echo """# Default configurations for the CFE
[node_p2p]
node_key_file = "/etc/chainflip/keys/node_key_file"
ip_address="$ip"
port = "8078"

[state_chain]
ws_endpoint = "ws://127.0.0.1:9944"
signing_key_file = "/etc/chainflip/keys/signing_key_file"

[eth]
# Ethereum RPC endpoints (websocket and http for redundancy).
ws_node_endpoint = "wss://eth-goerli.g.alchemy.com/v2/MUTLRhD-MwPDulRhFwg_wqwn6wnQoMSF"
http_node_endpoint = "https://eth-goerli.g.alchemy.com/v2/MUTLRhD-MwPDulRhFwg_wqwn6wnQoMSF"

# Ethereum private key file path. This file should contain a hex-encoded private key.
private_key_file = "/etc/chainflip/keys/ethereum_key_file"

[signing]
db_file = "/etc/chainflip/data.db"""" | sudo tee /etc/chainflip/config/Default.toml

sudo systemctl enable chainflip-node
sudo systemctl start chainflip-node
sudo systemctl status chainflip-node
