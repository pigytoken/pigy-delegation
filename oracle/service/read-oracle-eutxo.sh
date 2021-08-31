#!/usr/bin/env bash


# Abort on error.

set -e


### Set up the network.

export CARDANO_NODE_SOCKET_PATH=/data/alonzo.socket

MAGIC="--testnet-magic 8"

cardano-cli query protocol-parameters $MAGIC --out-file alonzo-purple.protocol


### Record the test addresses.

ADDRESS_2=$(cat keys/alonzo-purple.payment-2.address); echo $ADDRESS_2


### Record the minting policy.

CURRENCY=$(cardano-cli transaction policyid --script-file keys/alonzo-purple.policy-0.script); echo $CURRENCY


### Create the script address.

SCRIPT_FILE=alonzo-purple.plutus

ADDRESS_S=$(cardano-cli address build $MAGIC --payment-script-file $SCRIPT_FILE); echo $ADDRESS_S


### Find the UTxO for the oracle.

cardano-cli query utxo $MAGIC --address $ADDRESS_S

TXID_SCRIPT=3403192e000ad5a55dcc4daaab8edd649b488e736f6a82254542da635ffc6737#1


### See what funds are available.

cardano-cli query utxo $MAGIC --address $ADDRESS_2

TXID_ADA=3403192e000ad5a55dcc4daaab8edd649b488e736f6a82254542da635ffc6737#0
TXID_PIGY=cc813521d00b5e7071cc8869968235f8c017e7f4ca605cdc81833152811f844b#2


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
  --tx-out "$ADDRESS_S+5000000+1 $CURRENCY.tSOFR+50 $CURRENCY.tPIGY" \
    --tx-out-datum-hash $HASH \
  --tx-out "$ADDRESS_2+5000000+950 $CURRENCY.tPIGY" \
  --change-address $ADDRESS_2 \
  --tx-in-collateral $TXID_2#3 \
  --out-file tx.raw

cardano-cli transaction sign $MAGIC \
  --tx-body-file tx.raw \
  --out-file tx.signed \
  --signing-key-file keys/alonzo-purple.payment-2.skey

cardano-cli transaction submit $MAGIC \
  --tx-file tx.signed

