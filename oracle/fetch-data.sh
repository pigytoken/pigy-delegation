#!/usr/bin/env bash

set -e

TIMESTAMP=$(date --utc --rfc-3339=seconds | sed -e 's/ /T/')

DIR=data

JSON=$DIR/$TIMESTAMP.json

QUANDL_SECRET=$QUANDL_SECRET

curl -s 'https://www.quandl.com/api/v3/datasets/LBMA/GOLD?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"LBMA/GOLD/PM" : {url: "https://www.quandl.com/api/v3/datasets/LBMA/GOLD", date: .[0], value: (100 * .[2]) | round, scale: 100, unit: "USD/ounce"}}' \
> tmp/quandl-gold.json

curl -s 'https://www.quandl.com/api/v3/datasets/LBMA/SILVER?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"LBMA/SILVER" : {url: "https://www.quandl.com/api/v3/datasets/LBMA/SILVER", date: .[0], value: (1000 * .[1]) | round, scale: 1000, unit: "USD/ounce"}}' \
> tmp/quandl-silver.json

curl -s 'https://www.quandl.com/api/v3/datasets/BITFINEX/ADAUSD?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"BITFINEX/ADAUSD/Mid" : {url: "https://www.quandl.com/api/v3/datasets/BITFINEX/ADAUSD", date: .[0], value: (100000 * .[3]) | round, scale: 100000, unit: "USD/ADA"}}' \
> tmp/quandl-adausd.json

curl -s 'https://www.quandl.com/api/v3/datasets/BITFINEX/ADABTC?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"BITFINEX/ADABTC/Mid" : {url: "https://www.quandl.com/api/v3/datasets/BITFINEX/ADABTC", date: .[0], value: (100000000 * .[3]) | round, scale: 100000000, unit: "BTC/ADA"}}' \
> tmp/quandl-adabtc.json

curl -s 'https://www.quandl.com/api/v3/datasets/BITFINEX/BTCUSD?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"BITFINEX/BTCUSD/Mid" : {url: "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCUSD", date: .[0], value: (10 * .[3]) | round, scale: 10, unit: "USD/BTC"}}' \
> tmp/quandl-btcusd.json

curl -s 'https://www.quandl.com/api/v3/datasets/BITFINEX/BTCEUR?limit=1&api_key='$QUANDL_SECRET \
| jq '.dataset | .data | .[0] | {"BITFINEX/BTCEUR/Mid" : {url: "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCEUR", date: .[0], value: (10 * .[3]) | round, scale: 10, unit: "EUR/BTC"}}' \
> tmp/quandl-btceur.json

jq -s 'add | {"quandl": {source: "https://www.quandl.com/", symbols: .}}' tmp/quandl-*.json > tmp/quandl.json

curl -s 'https://markets.newyorkfed.org/api/rates/secured/sofr/last/1.json'  \
| jq '.refRates[] | {nyfed: {source: "https://www.newyorkfed.org", symbols: {"SOFR": {url: "https://markets.newyorkfed.org/api/rates/secured/sofr", date: .effectiveDate, value: (100 * .percentRate) | round, scale: 100, unit: "%"}}}}' \
> tmp/nyfed.json

jq -s 'add | {oracle: "https://oracle.pigytoken.com", timestamp : "'$TIMESTAMP'", data: .}' tmp/nyfed.json tmp/quandl.json \
> $JSON

echo $JSON
