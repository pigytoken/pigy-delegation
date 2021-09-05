#!/usr/bin/env bash


# Abort on error.

set -e


### Set up the network.

export CARDANO_NODE_SOCKET_PATH=/data/testnet.socket

MAGIC="--testnet-magic 1097911063"

cardano-cli query protocol-parameters $MAGIC --out-file testnet.protocol


### Record the test addresses.

ADDRESS_2=$(cat keys/alonzo-purple.payment-2.address); echo $ADDRESS_2


### Record the minting policy.

ASSET_CONTROL=469f9a74824555709042fb95aa2d11e3c7fa4eada2fe97bc287687dd.FARM
ASSET_DATUM=150ee39332bddb6083c2294cedb206aadbf7606e4bf53184fc7e9cad.PIGSTY
ASSET_FEE=8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY


### Record the script address.

SCRIPT_FILE=testnet.plutus

ADDRESS_S=$(cardano-cli address build $MAGIC --payment-script-file $SCRIPT_FILE); echo $ADDRESS_S


### Find the UTxO for the oracle.

cardano-cli query utxo $MAGIC --address $ADDRESS_S

TXID_SCRIPT=d0cca8b82263a4c1ad2c4f845ab58ed5610fdb1fcbe76faa92d19ef5aa2655b2#1


### See what funds are available at the payment address.

cardano-cli query utxo $MAGIC --address $ADDRESS_2

TXID_ADA=d0cca8b82263a4c1ad2c4f845ab58ed5610fdb1fcbe76faa92d19ef5aa2655b2#0
TXID_PIGY=df1a9c98421bccee0b6edf708c7c10909fc968b402b459fd2500d63874143b01#0
TXID_COLLATERAL=d0cca8b82263a4c1ad2c4f845ab58ed5610fdb1fcbe76faa92d19ef5aa2655b2#3


### Read the oracle.

JSON=$(cat on-chain.json | tr -d '\n')

HASH=$(cardano-cli transaction hash-script-data --script-data-value "$JSON"); echo $HASH

cardano-cli transaction build $MAGIC --alonzo-era \
  --protocol-params-file alonzo-purple.protocol \
  --tx-in $TXID_SCRIPT \
    --tx-in-script-file $SCRIPT_FILE \
    --tx-in-datum-value "$JSON" \
    --tx-in-redeemer-value '1' \
  --tx-in $TXID_ADA \
  --tx-in $TXID_PIGY \
  --tx-out "$ADDRESS_S+5000000+1 $ASSET_DATUM+10 $ASSET_FEE" \
    --tx-out-datum-hash $HASH \
  --tx-out "$ADDRESS_2+5000000+190 $ASSET_FEE" \
  --change-address $ADDRESS_2 \
  --tx-in-collateral $TXID_COLLATERAL \
  --out-file tx.raw

cardano-cli transaction sign $MAGIC \
  --tx-body-file tx.raw \
  --out-file tx.signed \
  --signing-key-file keys/alonzo-purple.payment-2.skey

cardano-cli transaction submit $MAGIC \
  --tx-file tx.signed

