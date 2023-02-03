seid init penton7 --chain-id sei-testnet-2 -o

# Obtain the genesis file for sei-testnet-1:
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json > ~/.sei/config/genesis.json
# Obtain the address book for sei-testnet-1
curl https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json > ~/.sei/config/addrbook.json

seid start