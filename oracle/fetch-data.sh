#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/b889a3f7a07515108cc9614639cd307cf2acbec5.tar.gz
#!nix-shell -i bash -p curl jq

set -e

TIMESTAMP=$(date --utc --rfc-3339=seconds | sed -e 's/ /T/')

if [[ -e keys/metalslive.secret ]]
then
  METALSLIVE=$(cat keys/metalslive.secret)
else
  METALSLIVE=
fi

mkdir -p data tmp

DIR=data

JSON=$DIR/$TIMESTAMP.json

{
  curl -s "https://markets.newyorkfed.org/api/rates/secured/sofr/last/1.json" \
  |  tee tmp/nyfed.raw \
  |  jq -f nyfed.jq \
  || echo '{}'
} 2> /dev/null > tmp/nyfed.json

{
  curl -s "https://api.coingecko.com/api/v3/simple/price?ids=cardano,bitcoin,ethereum&vs_currencies=btc,eth,usd,eur,idr,gbp,jpy" \
  |  tee tmp/coingeck.raw \
  |  jq -f coingecko.jq \
  || echo '{}'
} 2> /dev/null > tmp/coingecko.json

{
  curl -s "https://api.metals.live/v1/spot$METALSLIVE" \
  |  tee tmp/metalslive-spot.raw \
  |  jq -f metalslive-spot.jq \
  || echo '{}'
} 2> /dev/null > tmp/metalslive-spot.json

{
  curl -s "https://api.metals.live/v1/spot/commodities$METALSLIVE" \
  |  tee tmp/metalslive-commodity.raw \
  |  jq -f metalslive-commodity.jq \
  || echo '{}'
} 2> /dev/null > tmp/metalslive-commodity.json

if [[ `stat -c %s tmp/metalslive-spot.json` -gt 3 ]] || [[ `stat -c %s tmp/metalslive-commodity.json` -gt 3 ]]
then
  jq -s 'add | {metalslive: {notice: "Data provided by metals.live", source: "https://api.metals.live", symbols: .}}' \
    tmp/metalslive-spot.json \
    tmp/metalslive-commodity.json \
  > tmp/metalslive.json
else
  echo '{}' > tmp/metalslive.json
fi

jq -s 'add | {disclaimer: "ipfs://QmccBPKZqh9BJTJpC8oM6rc4gBrpcVXqcixX9KCsE6yDKd", oracle: "https://oracle.pigytoken.com", timestamp: "'$TIMESTAMP'", data: .}' \
  tmp/nyfed.json  \
  tmp/coingecko.json \
  tmp/metalslive.json \
> $JSON

echo $JSON
