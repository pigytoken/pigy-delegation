Creation of the PIGY Oracle
===========================

Here are the commands used to generate the keypairs for the oracle service, mint the tokens, and create the smart contract. We do this both for `testnet` and for `mainnet`.


## Record the version of cardano-cli

    $ cardano-cli --version
    
    cardano-cli 1.29.0 - linux-x86_64 - ghc-8.10
    git rev 4c59442958072657812c6c0bb8e0b4ab85ce1ba2


## Generate the first keypair and its mainnet and testnet address
    
    cardano-cli address key-gen --verification-key-file ../keys/pigy-oracle-0.vkey   \
                                --signing-key-file /dev/stdout                       \
    | gpg --armour --symmetric --cipher-algo AES256 > ../keys/pigy-oracle-0.skey.asc
    
    cardano-cli address build --mainnet                                                  \
                              --payment-verification-key-file ../keys/pigy-oracle-0.vkey \
                              --out-file ../keys/pigy-oracle-0.mainnet.address
    
    cardano-cli address build --testnet-magic 1097911063                                 \
                              --payment-verification-key-file ../keys/pigy-oracle-0.vkey \
                              --out-file ../keys/pigy-oracle-0.testnet.address


## Generate the second keypair and its mainnet and testnet address.
    
    cardano-cli address key-gen --verification-key-file ../keys/pigy-oracle-1.vkey   \
                                --signing-key-file /dev/stdout                       \
    | gpg --armour --symmetric --cipher-algo AES256 > ../keys/pigy-oracle-1.skey.asc
    
    cardano-cli address build --mainnet                                                  \
                              --payment-verification-key-file ../keys/pigy-oracle-1.vkey \
                              --out-file ../keys/pigy-oracle-1.mainnet.address
    
    cardano-cli address build --testnet-magic 1097911063                                 \
                              --payment-verification-key-file ../keys/pigy-oracle-1.vkey \
                              --out-file ../keys/pigy-oracle-1.testnet.address


## Pin the images to IPFS.

    ipfs add --quiet --pin=false ../ipfs/CORN.png 
    ipfs pin remote add --service=pinata \
                        --name=CORN /ipfs/QmPp9Jy1Wbtin4rcgEfNfqPiEJE6PcicKndUAiobwSu16p
    
    ipfs add --quiet --pin=false ../ipfs/FARM.png 
    ipfs pin remote add --service=pinata \
                        --name=FARM /ipfs/QmRgjCMJ8jWraJyjoNV9r3w3Gd1zKV4wG6SioZx8HBZv2s


## Create the minting script, for use with the first key.

    cat > minting-script.json << EOI
    {
      "type" : "all",
      "scripts" : [
        {
          "type" : "sig",
          "keyHash" : "$(cardano-cli address key-hash --payment-verification-key-file ../keys/pigy-oracle-0.vkey)"
        },
        {
          "type" : "before",
          "slot" : 40000000
        }
      ]
    }
    EOI


## Create the minting metadata.

    CURRENCY=$(cardano-cli transaction policyid --script-file minting-script.json)
    
    cat > minting-metadata.json << EOI
    {
      "721": {
        "$CURRENCY": {
          "CORN": {
            "name": "CORN",
            "image": "ipfs://QmPp9Jy1Wbtin4rcgEfNfqPiEJE6PcicKndUAiobwSu16p",
            "mediaType": "image/png",
            "description": "Control token for PIGY Oracle.",
            "url": "https://oracle.pigytoken.com"
          },
          "FARM": {
            "name": "FARM",
            "image": "ipfs://QmRgjCMJ8jWraJyjoNV9r3w3Gd1zKV4wG6SioZx8HBZv2s",
            "mediaType": "image/png",
            "description": "Datum token for PIGY Oracle.",
            "url": "https://oracle.pigytoken.com"
          }
        },
        "version": "1.0"
      }
    }
    EOI


## Create a socket so that we never have to store the decrypted key on disk and so that we can detect if another process reads the key.

    mkfifo ../keys/pigy-oracle-0.skey


## Mint and distribute the tokens.

    CARDANO_NODE_SOCKET_PATH=/data/testnet.socket \
    cardano-cli transaction build --testnet-magic 1097911063 --alonzo-era \
      --tx-in 1d6026c3518b0007c81c61023a579ef389fff67094c8dc7c4aa81e499a7ba332#0 \
      --tx-out "$(cat ../keys/pigy-oracle-0.testnet.address)+10000000+1 $CURRENCY.CORN" \
      --tx-out "$(cat ../keys/pigy-oracle-0.testnet.address)+10000000+1 $CURRENCY.FARM" \
      --tx-out "$(cat ../keys/pigy-oracle-0.testnet.address)+2000000" \
      --tx-out "addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp+2000000+4 $CURRENCY.CORN" \
      --change-address $(cat ../keys/pigy-oracle-0.testnet.address) \
      --mint "5 $CURRENCY.CORN+1 $CURRENCY.FARM" \
        --mint-script-file minting-script.json \
      --invalid-hereafter 40000000 \
      --json-metadata-no-schema \
      --metadata-json-file minting-metadata.json \
      --out-file tx.raw
    
    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    cardano-cli transaction sign --testnet-magic 1097911063 \
      --tx-body-file tx.raw \
      --out-file tx.signed \
      --signing-key-file ../keys/pigy-oracle-0.skey
    
    CARDANO_NODE_SOCKET_PATH=/data/testnet.socket \
    cardano-cli transaction submit --testnet-magic 1097911063 \
      --tx-file tx.signed
    
    cardano-cli transaction build-raw --mary-era \
      --tx-in 456320af1cf8e32eb0ca103a5134aa235fa832f5dc441952e5504902ed5877a2#0 \
      --tx-out "$(cat ../keys/pigy-oracle-0.mainnet.address)+75595738" \
      --tx-out "$(cat ../keys/pigy-oracle-0.mainnet.address)+10000000+1 $CURRENCY.CORN" \
      --tx-out "$(cat ../keys/pigy-oracle-0.mainnet.address)+10000000+1 $CURRENCY.FARM" \
      --tx-out "$(cat ../keys/pigy-oracle-0.mainnet.address)+2000000" \
      --tx-out "addr1q9dwrut84qpc4s8ff9lvfa8g57amd07n24xl3yjpxydhwg4h2fmwqlqxr2q85pumjhzzmhfkhjr25090hmhf60tzg2rsupdumh+2000000+4 $CURRENCY.CORN" \
      --fee 206685 \
      --mint "5 $CURRENCY.CORN+1 $CURRENCY.FARM" \
        --minting-script-file minting-script.json \
      --invalid-hereafter 40000000 \
      --json-metadata-no-schema \
      --metadata-json-file minting-metadata.json \
      --out-file tx.raw
    
    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    cardano-cli transaction sign --mainnet \
      --tx-body-file tx.raw \
      --out-file tx.signed \
      --signing-key-file ../keys/pigy-oracle-0.skey
    
    CARDANO_NODE_SOCKET_PATH=/data/mainnet.socket \
    cardano-cli transaction submit --mainnet \
      --tx-file tx.signed


## Register the token metadata.

    git clone git@github.com:functionally/cardano-token-registry.git
    pushd cardano-token-registry
    nix-shell
    cd mappings
    
    SUBJECT=$CURRENCY$(echo -n CORN | xxd -ps)
    
    token-metadata-creator entry --init $SUBJECT
    
    token-metadata-creator entry $SUBJECT \
      --name CORN \
      --ticker CORN \
      --description "Control token for PIGY Oracle." \
      --logo ../../../ipfs/CORN.png \
      --decimals 0 \
      --url https://oracle.pigytoken.com \
      --policy ../../minting-script.json
    
    token-metadata-creator entry $SUBJECT \
       -a ../../../keys/pigy-oracle-0.skey
    
    token-metadata-creator entry $SUBJECT \
      --finalize
    
    git commit $SUBJECT.json -m CORN
    
    cp $SUBJECT.json ../..
    
    SUBJECT=$CURRENCY$(echo -n FARM | xxd -ps)
    
    token-metadata-creator entry --init $SUBJECT
    
    token-metadata-creator entry $SUBJECT \
      --name FARM \
      --ticker FARM \
      --description "Datum token for PIGY Oracle." \
      --logo ../../../ipfs/FARM.png \
      --decimals 0 \
      --url https://oracle.pigytoken.com \
      --policy ../../build/minting-script.json
    
    token-metadata-creator entry $SUBJECT \
       -a ../../../keys/pigy-oracle-0.skey
    
    token-metadata-creator entry $SUBJECT \
      --finalize
    
    git commit $SUBJECT.json -m FARM
    
    cp $SUBJECT.json ../..
    
    git push
    exit
    popd


## View the eUTxOs available for creating the service.

    $ CARDANO_NODE_SOCKET_PATH=/data/testnet.socket cardano-cli query utxo --testnet-magic 1097911063 --address $(cat ../keys/pigy-oracle-0.testnet.address)                                           
    
                               TxHash                                 TxIx        Amount
    --------------------------------------------------------------------------------------
    aa13856cc45820029eba3461f5ce0541b83797309f4d1917611e72500dc69ed1     0        75624734 lovelace + TxOutDatumHashNone
    aa13856cc45820029eba3461f5ce0541b83797309f4d1917611e72500dc69ed1     1        10000000 lovelace + 1 fb353334ac071f79f6d938e0972640a6b6650815124e9d63fbc0b5e8.CORN + TxOutDatumHashNone
    aa13856cc45820029eba3461f5ce0541b83797309f4d1917611e72500dc69ed1     2        10000000 lovelace + 1 fb353334ac071f79f6d938e0972640a6b6650815124e9d63fbc0b5e8.FARM + TxOutDatumHashNone
    aa13856cc45820029eba3461f5ce0541b83797309f4d1917611e72500dc69ed1     3        2000000 lovelace + TxOutDatumHashNone

        
    $ CARDANO_NODE_SOCKET_PATH=/data/mainnet.socket cardano-cli query utxo --mainnet --address $(cat ../keys/pigy-oracle-0.mainnet.address)
    
                               TxHash                                 TxIx        Amount
    --------------------------------------------------------------------------------------
    41b2bf9badec879f09dc9154c582da12f0c5a7970cd3f922ed34baf83e19e2e1     0        75595738 lovelace
    41b2bf9badec879f09dc9154c582da12f0c5a7970cd3f922ed34baf83e19e2e1     1        10000000 lovelace + 1 fb353334ac071f79f6d938e0972640a6b6650815124e9d63fbc0b5e8.CORN
    41b2bf9badec879f09dc9154c582da12f0c5a7970cd3f922ed34baf83e19e2e1     2        10000000 lovelace + 1 fb353334ac071f79f6d938e0972640a6b6650815124e9d63fbc0b5e8.FARM
    41b2bf9badec879f09dc9154c582da12f0c5a7970cd3f922ed34baf83e19e2e1     3        2000000 lovelace


## Configure the oracle.

    cat > ../testnet.mantra-oracle << EOI
    Configuration
    {
      socketPath     = "/data/testnet.socket"
    , magic          = Just 1097911063
    , epochSlots     = 21600
    , controlAsset   = "$CURRENCY.CORN"
    , datumAsset     = "$CURRENCY.FARM"
    , feeAsset       = "8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY"
    , feeAmount      = 10
    , lovelaceAmount = 0
    }
    EOI
    
    cat > ../mainnet.mantra-oracle << EOI
    Configuration
    {
      socketPath     = "/data/mainnet.socket"
    , magic          = Nothing
    , epochSlots     = 21600
    , controlAsset   = "$CURRENCY.CORN"
    , datumAsset     = "$CURRENCY.FARM"
    , feeAsset       = "2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac664.PIGYToken"
    , feeAmount      = 10
    , lovelaceAmount = 0
    }
    EOI


## Record the version of the Mantra Oracle code.

    $ mantra-oracle --version
    Mantra Oracle 0.3.2.0, (c) 2021 Brian W Bush <code@functionally.io>
    
    $ git log -n 1 --pretty=oneline
    0748820adf93dfd62c7e3d02b4c9d121b3e45139 (HEAD -> dev, tag: 0.3.2.0, github/main, bitbucket/main, bitbucket/dev, 
    bitbucket/HEAD, main) ran tests on latest revision


## Create the Plutus scripts.

    $ mantra-oracle export ../testnet.mantra-oracle ../oracle.testnet.plutus | tee ../oracle.testnet.address
    addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp
    
    $ mantra-oracle export ../mainnet.mantra-oracle ../oracle.mainnet.plutus | tee ../oracle.mainnet.address
    addr1w83xtd6pekdv93xkj4qz77a5edyuhcxeuvlwex3xm0afukgj73l65


## Just to be careful, also compute the script address using `cardano-cli`.

    $ cardano-cli address build --testnet-magic 1097911063 --payment-script-file ../oracle.testnet.plutus
    addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp

    $ cardano-cli address build --mainnet --payment-script-file ../oracle.mainnet.plutus
    addr1w83xtd6pekdv93xkj4qz77a5edyuhcxeuvlwex3xm0afukgj73l65


## Submit the creation transaction.

    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    mantra-oracle create ../testnet.mantra-oracle                      \
                         $(cat ../keys/pigy-oracle-0.testnet.address)  \
                         ../keys/pigy-oracle-0.skey                    \
                         welcome-to-pigy-oracle.json                   \
                         --metadata 674
    
    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    mantra-oracle create ../mainnet.mantra-oracle                      \
                         $(cat ../keys/pigy-oracle-0.mainnet.address)  \
                         ../keys/pigy-oracle-0.skey                    \
                         welcome-to-pigy-oracle.json                   \
                         --metadata 674


## Update the oracle datum.

    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    mantra-oracle write ../testnet.mantra-oracle                       \
                  $(cat ../keys/pigy-oracle-0.testnet.address)         \
                  ../keys/pigy-oracle-0.skey                           \
                  welcome-to-pigy-oracle.json                          \
                  ../on-chain.json                                     \
                  --metadata 247428
    
    gpg -d ../keys/pigy-oracle-0.skey.asc > ../keys/pigy-oracle-0.skey &
    mantra-oracle write ../mainnet.mantra-oracle                       \
                  $(cat ../keys/pigy-oracle-0.mainnet.address)         \
                  ../keys/pigy-oracle-0.skey                           \
                  welcome-to-pigy-oracle.json                          \
                  ../on-chain.json                                     \
                  --metadata 247428


## Test reading the oracle.

### Create an example plutus script that reads the oracle data and tests whether it matches its own redeemer.

    mantra-oracle reader ../testnet.mantra-oracle example-reader.testnet.plutus \
    | tee example-reader.testnet.address

### Fund the example plutus script.

    cardano-cli transaction build --testnet-magic 1097911063 --alonzo-era \
      --protocol-params-file ../testnet.protocol \
      --tx-in 1333074f119ae58a7885822d9de4787203ddc7c0f3425ae8c657723425bd0368#0 \
      --tx-out "$(cat example-reader.testnet.address)+1500000" \
        --tx-out-datum-hash $(cardano-cli transaction hash-script-data --script-data-value '"irrelevant"') \
      --tx-out "addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp+3000000+10 8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY" \
      --change-address addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp \
      --out-file tx.raw
    
    cardano-cli transaction sign --testnet-magic 1097911063 \
      --tx-body-file tx.raw \
      --out-file tx.signed \
      --signing-key-file payment.skey
    
    cardano-cli transaction submit --testnet-magic 1097911063 \
      --tx-file tx.signed

### Read the oracle in order to remove the funds from the example reader script, in return for a payment of 10 PIGY.

    HASH=$(cardano-cli transaction hash-script-data --script-data-value "$(cat ../on-chain.json)")
    
    cardano-cli transaction build --testnet-magic 1097911063 --alonzo-era \
      --protocol-params-file ../testnet.protocol \
      --tx-in 74d0e9c5fa7bfe17268744b68523c6702b5557515c54844ca735fb9f1e70ed51#1 \
        --tx-in-script-file example-reader.testnet.plutus \
        --tx-in-datum-value '"irrelevant"' \
        --tx-in-redeemer-value "$(cat ../on-chain.json)" \
      --tx-in 7832efcc4ff87cbb479dd7d84afdc1b2763fa26536d2d2a9dabb8875e7a1c064#1 \
        --tx-in-script-file ../oracle.testnet.plutus \
        --tx-in-datum-value "$(cat ../on-chain.json)" \
        --tx-in-redeemer-value '1' \
      --tx-in 74d0e9c5fa7bfe17268744b68523c6702b5557515c54844ca735fb9f1e70ed51#2 \
      --tx-in 74d0e9c5fa7bfe17268744b68523c6702b5557515c54844ca735fb9f1e70ed51#0 \
      --tx-out "$(cat ../oracle.testnet.address)+5000000+1 $CURRENCY.FARM+10 8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY" \
        --tx-out-datum-hash $HASH \
      --change-address addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp \
      --tx-in-collateral 74d0e9c5fa7bfe17268744b68523c6702b5557515c54844ca735fb9f1e70ed51#0 \
      --out-file tx.raw
    
    cardano-cli transaction sign --testnet-magic 1097911063 \
      --tx-body-file tx.raw \
      --out-file tx.signed \
      --signing-key-file payment.skey
    
    cardano-cli transaction submit --testnet-magic 1097911063 \
      --tx-file tx.signed

### Check that the funds have been removed from the example reader script and that the PIGY has been deposited into the oracle.

    $ cardano-cli query utxo --testnet-magic 1097911063 --address $(cat example-reader.testnet.address)                                          
                               TxHash                                 TxIx        Amount
    --------------------------------------------------------------------------------------
    
    
    $ cardano-cli query utxo --testnet-magic 1097911063 --address $(cat ../oracle.testnet.address)
    
                               TxHash                                 TxIx        Amount
    --------------------------------------------------------------------------------------
    096b9eb1156b4a8d9716191b39613d36703fffef8656cc0e359e0002145c9f83     1        5000000 lovelace + 10 8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY + 1 fb353334ac071f79f6d938e0972640a6b6650815124e9d63fbc0b5e8.FARM + TxOutDatumHash ScriptDataInAlonzoEra "8ab0f5b933f216cd13d255366c8528df3c50f8202ac3e40d271fc056fb9501fc"
    
    
    $ cardano-cli query utxo --testnet-magic 1097911063 --address addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp
                               TxHash                                 TxIx        Amount
    --------------------------------------------------------------------------------------
    096b9eb1156b4a8d9716191b39613d36703fffef8656cc0e359e0002145c9f83     0        8724941 lovelace + TxOutDatumHashNone


## Start routine operations.

Simply run [update-oracle-eutxo.sh](../update-oracle-eutxo.sh) each day.
