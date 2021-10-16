#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p ipfs postgresql

set -ex

. $HOME/secrets/ipfs.sh
. $HOME/secrets/postgresql.sh

gawk 'BEGIN { FS = "\t" ; OFS = "," } FNR > 1 { print $2, $6, $5 }' pigy_ticker.tsv > pigy_ticker.csv

DATE=$(date --rfc-3339 seconds -u)

psql -f compute-eligibility.sql

gawk -f make-index.awk -v date="$DATE" Eligibility.csv > pages/index.html

gawk -f build-pages.awk -v date="$DATE" Eligibility.csv

DIR_CID=$(ipfs add --quiet --pin=false --recursive=true pages | tail -n 1)

ipfs pin remote add --service=pinata --name=pigy $DIR_CID
  
ipfs name publish --lifetime 120h --key=pigy /ipfs/$DIR_CID
