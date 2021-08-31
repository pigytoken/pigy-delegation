Scripts for PIGY Oracle Service
===============================


Updating the Oracle Datum
-------------------------

The script [update-oracle-eutxo.sh](update-oracle-eutxo.sh) updates the oracle with new precious metal and currency prices.


Reading the Oracle
------------------

On Alonzo Purple, the oracle resides at `addr_test1wrlatjg53r4z49rzyg76eyxq5zlu66v4j5hucf25kuv3j9sv84h5p`. The compiled Plutus code for the oracle is in [alonzo-purple.plutus](alonzo-purple.plutus). The source code is in the [`mantis-oracle`](https://github.com/functionally/mantis-oracle/blob/main/ReadMe.md) Haskell package.

The configuration [alonzo-purple.mantis-oracle](alonzo-purple.mantis-oracle) requires that `50 PIGY` be paid to the oracle when reading it and that no ADA may be withdrawn from the oracle when reading it.

Although the oracle is meant to be read by other smart contracts, it can also be read using the [`cardano-cli`](https://github.com/input-output-hk/cardano-node/blob/master/cardano-cli/README.md) tool. See the script [read-oracle-eutxo.sh](read-oracle-eutxo.sh) for an example.
