Using the PIGY Oracle Service
=============================

The PIGY Oracle is a community-driven, lowest cost oracle to benefit SPOs. See https://oracle.pigytoken.com/ for details.

This oracle service (a Plutus smart contract) ran on Alonzo Purple, is now running on the Cardano TestNet, and will migrate to the Cardano MainNet immediately after the Alonzo HFC event. To the extent feasible, we will freely add community-nominated data sources to the PIGY Oracle. We have completely open-sourced the on- and off-chain code so that the Cardano community can easily deploy their own customized oracles for whatever data feeds they wish.

![Example Transaction using the PIGY Oracle](../pages/example.png)


Data Format
-----------

In addition to being posted on the blockchain as eUTxO data at the smart-contract address [`addr_test1wquuc74u5r702y8jpazgm3nusse6jaj68cm2xqyzyqhyu8g25ysjg`](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr_test1wquuc74u5r702y8jpazgm3nusse6jaj68cm2xqyzyqhyu8g25ysjg), for convenience the data is also posted in the eUTxO as metadata with tag 247428 and at [ipns://k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray](http://gateway.pinata.cloud/ipns/k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray).

The service currently posts cryptocurrency and precious metal spot prices. Here is [an example](https://explorer.cardano-testnet.iohkdev.io/en/transaction?id=4e488b6c986dfb76a3350c1bfd4246b8ec87b29c6a18d0733ca03c633ced5a5c):

    {
      "oracle": "https://oracle.pigytoken.com",
      "timestamp": "2021-09-04T16:30:16+00:00",
      "data": {
        "nyfed": {
          "source": "https://www.newyorkfed.org",
          "symbols": {
            "SOFR": { "date": "2021-09-02", "value": 5, "scale": 100, "unit": "%", "url": "https://markets.newyorkfed.org/api/rates/secured/sofr" }
          }
        },
        "quandl": {
          "source": "https://www.quandl.com/",
          "symbols": {
            "LBMA/GOLD/PM"       : { "date": "2021-09-03", "value": 182370, "scale":       100, "unit": "USD/ounce", "url": "https://www.quandl.com/api/v3/datasets/LBMA/GOLD"       },
            "LBMA/SILVER"        : { "date": "2021-09-03", "value":  24055, "scale":      1000, "unit": "USD/ounce", "url": "https://www.quandl.com/api/v3/datasets/LBMA/SILVER"     },
            "BITFINEX/ADAUSD/Mid": { "date": "2021-09-03", "value": 294015, "scale":    100000, "unit": "USD/ADA"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/ADAUSD" },
            "BITFINEX/ADABTC/Mid": { "date": "2021-09-03", "value":   5916, "scale": 100000000, "unit": "BTC/ADA"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/ADABTC" },
            "BITFINEX/BTCUSD/Mid": { "date": "2021-09-03", "value": 497545, "scale":        10, "unit": "USD/BTC"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCUSD" },
            "BITFINEX/BTCEUR/Mid": { "date": "2021-09-03", "value": 418795, "scale":        10, "unit": "EUR/BTC"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCEUR" }
          }
        }
      }
    }

Because Plutus does not have a data type for real (floating point) numbers, the prices are represented as a value divided by a scale. Here is how to interpret the example above:

| Symbol              | Description                      | Value                    |                                                                                        |
|---------------------|----------------------------------|-------------------------:|----------------------------------------------------------------------------------------|
| SOFR                | Secured Overnight Financing Rate |     0.05       %         | [New York Federal Reserve Bank](https://www.newyorkfed.org)                            |
| LBMA/GOLD/PM        | Gold Price                       |  1823.70       USD/ounce | [Quandl + LBMA](https://www.quandl.com/data/LBMA/GOLD-Gold-Price-London-Fixing)        |
| LBMA/SILVER         | Silver Price                     |    24.055      USD/ounce | [Quandl + LBMA](https://www.quandl.com/data/LBMA/SILVER-Silver-Price-London-Fixing)    |
| BITFINEX/ADAUSD/Mid | ADA Price in USD                 |     2.94015    USD/ADA   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/ADAUSD-ADA-USD-Exchange-Rate) |
| BITFINEX/ADABTC/Mid | ADA Price in BTC                 |     0.00005916 BTC/ADA   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/ADABTC-ADA-BTC-Exchange-Rate) |
| BITFINEX/BTCUSD/Mid | BTC Price in USD                 | 49754.5        USD/BTC   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/BTCUSD-BTC-USD-Exchange-Rate) |
| BITFINEX/BTCEUR/Mid | BTC Price in EUR                 | 41879.5        EUR/BTC   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/BTCEUR-BTC-EUR-Exchange-Rate) |


Technical Details
-----------------

See [`mantra-oracle`](https://github.com/functionally/mantra-oracle/blob/main/ReadMe.md) for complete technical details and source code.

The oracle users three types of native tokens:

*   The **fee** token: Each time another smart contract reads data from the oracle, it needs to pay a quantity of the *fee token* to the oracle contract.
*   The **datum** token: The oracle always has at its address an eUTxO that holds the *datum token*, and the oracle's data is attached to this eUTxO.
*   The **control** token: The operator of the oracle uses the *control token* to update the data in the oracle by sending it in a transaction with new data for the datum token to hold. (This token can also be used to delete the oracle altogether, ending its smart contract.)


Reading the Oracle Datum
------------------------

On the Cardano TestNet, the oracle resides at [`addr_test1wquuc74u5r702y8jpazgm3nusse6jaj68cm2xqyzyqhyu8g25ysjg`](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr_test1wquuc74u5r702y8jpazgm3nusse6jaj68cm2xqyzyqhyu8g25ysjg). The compiled Plutus code for the oracle is in [testnet.plutus](testnet.plutus). The source code is in the [`mantra-oracle`](https://github.com/functionally/mantra-oracle/blob/main/ReadMe.md) Haskell package.

The configuration [testnet.mantra-oracle](testnet.mantra-oracle) requires that `10 tPIGY` tokens be paid to the oracle when reading it and that no ADA may be withdrawn from the oracle when reading it. The datum token is `1 PIGSTY`.

Although the oracle is meant to be read by other smart contracts, it can also be read using the [`cardano-cli`](https://github.com/input-output-hk/cardano-node/blob/master/cardano-cli/README.md) tool. See the script [read-oracle-eutxo.sh](read-oracle-eutxo.sh) for an example.


Creating the Oracle Datum
-------------------------

The script [create-oracle-eutxo.sh](create-oracle-eutxo.sh) creates the oracle with new precious metal and currency prices. The control token is `1 FARM`.


Updating the Oracle Datum
-------------------------

The script [update-oracle-eutxo.sh](update-oracle-eutxo.sh) updates the oracle with new precious metal and currency prices.
