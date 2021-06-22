#!/usr/bin/env bash

if [[ true ]]
then

  gsutil -m rsync -rdecC pages/  gs://data.functionally.dev/cardano/delegation/

else

  DIR_CID=$(ipfs add --quiet --pin=false --recursive=true pages | tail -n 1)
  
  ipfs name publish --key=pigy /ipfs/$DIR_CID
  
  curl -X POST                                                               \
    -H "pinata_api_key:$(cat pinata.key)"                                    \
    -H "pinata_secret_api_key:$(cat pinata.secret)"                          \
    -H "Content-Type: application/json"                                      \
    --data '{"hashToPin": "'$DIR_CID'", "pinataMetadata": {"name": "pigy"}}' \
    https://api.pinata.cloud/pinning/pinByHash

fi
