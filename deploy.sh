#!/usr/bin/env bash

set -ex

psql -f compute-eligibility.sql

gawk -f make-index.awk Eligibility.csv > pages/index.html

gawk -f build-pages.awk Eligibility.csv

DIR_CID=$(ipfs add --quiet --pin=false --recursive=true pages | tail -n 1)
  
ipfs name publish --key=pigy /ipfs/$DIR_CID
  
curl -X POST                                                               \
  -H "pinata_api_key:$(cat pinata.key)"                                    \
  -H "pinata_secret_api_key:$(cat pinata.secret)"                          \
  -H "Content-Type: application/json"                                      \
  --data '{"hashToPin": "'$DIR_CID'", "pinataMetadata": {"name": "pigy"}}' \
  https://api.pinata.cloud/pinning/pinByHash
