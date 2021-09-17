#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p ipfs


set -e

export IPFS_PATH=$(cat keys/ipfs.path)

DIR=data

while true
do
  echo
  inotifywait $DIR
  sleep 10s
  CID=$(ipfs add --quiet --pin=false --recursive $DIR | tail -n 1)
  ipfs pin remote add --service=pinata --name=pigy-oracle-data /ipfs/$CID
  ipfs name publish --lifetime 120h --key=pigy-oracle-data /ipfs/$CID
done
