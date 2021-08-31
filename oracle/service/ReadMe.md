Scripts for PIGY Oracle Service
===============================


Data Format
-----------

In addition to being posted on the blockchain as eUTxO data at the smart-contract address [`addr_test1wrlatjg53r4z49rzyg76eyxq5zlu66v4j5hucf25kuv3j9sv84h5p`](https://explorer.alonzo-purple.dev.cardano.org/en/address?address=addr_test1wrlatjg53r4z49rzyg76eyxq5zlu66v4j5hucf25kuv3j9sv84h5p), for convenience the data is also posted in the eUTxO as metadata with tag 247428 and at [ipns://k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray](http://gateway.pinata.cloud/ipns/k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray).

The service currently posts currency and precious metal spot prices. Here is an example:

    {
      "timestamp": "2021-08-31T13:13:47+00:00",
      "service": "https://oracle.pigytoken.com/",
      "currencies": {
        "source": "https://notnullsolutions.com/",
        "symbols" : [
          { "symbol": "EUR", "value":   84604, "scale": 100000, "unit" : "EUR/USD" },
          { "symbol": "GBP", "value":   72662, "scale": 100000, "unit" : "GBP/USD" },
          { "symbol": "IDR", "value": 1425395, "scale":    100, "unit" : "IDR/USD" }
        ]
      },
      "metals": {
        "source": "https://notnullsolutions.com/",
        "symbols" : [
          { "symbol": "Au", "value": 180398, "scale": 100, "unit": "USD/ounce" },
          { "symbol": "Ag", "value":   2392, "scale": 100, "unit": "USD/ounce" },
          { "symbol": "Pt", "value":   1008, "scale":   1, "unit": "USD/ounce" },
          { "symbol": "Pd", "value":   2501, "scale":   1, "unit": "USD/ounce" }
        ]
      },
      "sofr" : {
        "source": "https://www.newyorkfed.org/markets/reference-rates/sofr",
        "symbols" : [
          { "symbol": "SOFR", "value": 5, "scale": 100, "unit": "%" }
        ]
      }
    }

Because Plutus does not have a data type for real (floating point) numbers, the prices are represented as a value divided by a scale. Here is how to interpret the example above:

| Item           | Price               |
|----------------|---------------------|
| EUR            |     0.84604 EUR/USD |
| GBP            |     0.72662 GBP/USD |
| IDR            | 14253.95    IDR/USD |
| Au (Gold)      |  1803.98 USD/ounce  |
| Ag (Silver)    |    23.92 USD/ounce  |
| Pt (Platinum)  |  1008    USD/ounce  |
| Pd (Palladium) |  2501    USD/ounce  |
| SOFR           | 0.05%               |


Reading the Oracle
------------------

On Alonzo Purple, the oracle resides at [`addr_test1wrlatjg53r4z49rzyg76eyxq5zlu66v4j5hucf25kuv3j9sv84h5p`](https://explorer.alonzo-purple.dev.cardano.org/en/address?address=addr_test1wrlatjg53r4z49rzyg76eyxq5zlu66v4j5hucf25kuv3j9sv84h5p). The compiled Plutus code for the oracle is in [alonzo-purple.plutus](alonzo-purple.plutus). The source code is in the [`mantis-oracle`](https://github.com/functionally/mantis-oracle/blob/main/ReadMe.md) Haskell package.

The configuration [alonzo-purple.mantis-oracle](alonzo-purple.mantis-oracle) requires that `50 PIGY` be paid to the oracle when reading it and that no ADA may be withdrawn from the oracle when reading it.

Although the oracle is meant to be read by other smart contracts, it can also be read using the [`cardano-cli`](https://github.com/input-output-hk/cardano-node/blob/master/cardano-cli/README.md) tool. See the script [read-oracle-eutxo.sh](read-oracle-eutxo.sh) for an example.


Updating the Oracle Datum
-------------------------

The script [update-oracle-eutxo.sh](update-oracle-eutxo.sh) updates the oracle with new precious metal and currency prices.
