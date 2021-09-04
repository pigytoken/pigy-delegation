#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p curl jq ipfs


# Abort on error.

set -e


# Configure paths.

export PATH=.:$PATH

export IPFS_PATH=$(cat ipfs.path)

DIR=../data


# Export the Plutus script.

mantra-oracle export testnet.mantra-oracle testnet.plutus


# Fetch the data.

# FIXME: Move the fetching code into Haskell.
JSON=$(./fetch-data.sh)

less $JSON


# Update the oracle's eUXxO.

mantra-oracle create testnet.mantra-oracle                \
              $(cat keys/alonzo-purple.payment-2.address) \
              keys/alonzo-purple.payment-2.skey           \
              $JSON                                       \
              --metadata 247428

cp $JSON on-chain.json


# Archive to IPFS.

CID=$(ipfs add --quiet --pin=false --recursive $DIR | tail -n 1)
echo $CID

ipfs name publish --key=pigy-oracle-data /ipfs/$CID

ipfs pin remote add --service=pinata --name=pigy-oracle-data /ipfs/$CID

