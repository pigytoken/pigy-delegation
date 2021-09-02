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

JSON_1=tmp-1.json
JSON_2=tmp-2.json
JSON=$DIR/$TIMESTAMP.json


# Export the Plutus script.

mantra-oracle export testnet.mantra-oracle testnet.plutus


# Fetch the data.

# FIXME: Move the fetching code into Haskell.

curl --request GET \
     --url "https://live-metal-prices.p.rapidapi.com/v1/latest/XAU,XAG,PL,PA,USD,EUR,GBP,IDR/USD" \
     --header "x-rapidapi-host: live-metal-prices.p.rapidapi.com" \
     --header "x-rapidapi-key: $(cat rapidapi.secret)" \
| jq '.rates | {timestamp : "'$TIMESTAMP'", service : "https://oracle.pigytoken.com", currencies : {source : "https://notnullsolutions.com", symbols: [{symbol : "EUR", value : (100000 * .EUR) | round, scale : 100000, unit: "EUR/USD"}, {symbol : "GBP", value : (100000 * .GBP) | round, scale : 100000, unit: "GBP/USD"}, {symbol : "IDR", value : (100 * .IDR) | round, scale : 100, unit: "IDR/USD"}]}, metals : {source : "https://notnullsolutions.com", symbols: [{symbol : "Au", value : (100 * .XAU) | round, scale : 100, unit : "USD/ounce"}, {symbol : "Ag", value : (100 * .XAG) | round, scale : 100, unit : "USD/ounce"}, {symbol : "Pt", value : .PL | round, scale : 1, unit : "USD/ounce"}, {symbol : "Pd", value : .PA | round, scale : 1, unit : "USD/ounce"}]}}' > $JSON_1

curl -s 'https://markets.newyorkfed.org/api/rates/secured/sofr/last/1.json'  \
| jq '.refRates[] | {nyfed: {source: "https://www.newyorkfed.org/markets/reference-rates/sofr", symbols: [{symbol: "SOFR", value: (100 * .percentRate) | round, scale: 100, unit: "%"}]}}' \
> $JSON_2

jq -s add $JSON_1 $JSON_2 > $JSON

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

