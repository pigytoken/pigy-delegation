#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p curl jq ipfs


# Abort on error.

set -e


# Configure paths.

export PATH=.:$PATH

export IPFS_PATH=$(cat keys/ipfs.path)

DIR=data


# Fetch the data.

# FIXME: Move the fetching code into Haskell.
JSON=$(./fetch-data.sh)

less $JSON


# Update the oracle's eUXxO.

for n in testnet
do
  gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
  mantra-oracle write $n.mantra-oracle                               \
                $(cat keys/pigy-oracle-0.address)                    \
                keys/pigy-oracle-0.skey                              \
                on-chain.json                                        \
                $JSON                                                \
                --metadata 247428
done

cp $JSON on-chain.json


# Archive to IPFS.

CID=$(ipfs add --quiet --pin=false --recursive $DIR | tail -n 1)
echo $CID

ipfs name publish --key=pigy-oracle-data /ipfs/$CID

ipfs pin remote add --service=pinata --name=pigy-oracle-data /ipfs/$CID

