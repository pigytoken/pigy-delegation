#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p curl jq ipfs


# Abort on error.

set -e


# Configure paths.

export PATH=.:$PATH

export IPFS_PATH=$(cat ipfs.path)

DIR=../data

TIMESTAMP=$(date --utc --rfc-3339=seconds | sed -e 's/ /T/')

JSON=$DIR/$TIMESTAMP.json


# Fetch the data.

# FIXME: Move the fetching code into Haskell.
curl --request GET \
     --url "https://live-metal-prices.p.rapidapi.com/v1/latest/XAU,XAG,PL,PA,USD,EUR,GBP,IDR/USD" \
     --header "x-rapidapi-host: live-metal-prices.p.rapidapi.com" \
     --header "x-rapidapi-key: $(cat rapidapi.secret)" \
| jq '.rates | {timestamp : "'$TIMESTAMP'", service : "https://oracle.pigytoken.com/", source : "https://notnullsolutions.com/", currencies : [{symbol : "USD", value : .USD, scale : 1}, {symbol : "EUR", value : (100000 * .EUR) | round, scale : 100000}, {symbol : "GBP", value : (100000 * .GBP) | round, scale : 100000}, {symbol : "IDR", value : (100 * .IDR) | round, scale : 100}], metals : [{symbol : "Au", value : (100 * .XAU) | round, scale : 100, unit : "ounce"}, {symbol : "Ag", value : (100 * .XAG) | round, scale : 100, unit : "ounce"}, {symbol : "Pt", value : .PL | round, scale : 1, unit : "ounce"}, {symbol : "Pd", value : .PA | round, scale : 1, unit : "ounce"}]}' > $JSON

less $JSON


# Update the oracle's eUXxO.

mantis-oracle write alonzo-purple.mantis-oracle           \
              $(cat keys/alonzo-purple.payment-2.address) \
              keys/alonzo-purple.payment-2.skey           \
              on-chain.json                               \
              $JSON                                       \
              --metadata 247428

cp $JSON on-chain.json


# Archive to IPFS.

CID=$(ipfs add --quiet --pin=false --recursive $DIR | tail -n 1)
echo $CID

ipfs name publish --key=pigy-oracle-data /ipfs/$CID

ipfs pin remote add --service=pinata --name=pigy-oracle-data /ipfs/$CID

