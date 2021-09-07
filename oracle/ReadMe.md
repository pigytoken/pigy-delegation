Using the PIGY Oracle Service
=============================

The PIGY Oracle is a community-driven, lowest cost oracle to benefit SPOs. See https://oracle.pigytoken.com/ for details.

This oracle service (a Plutus smart contract) ran on Alonzo Purple, is now running on the Cardano TestNet, and will migrate to the Cardano MainNet immediately after the Alonzo HFC event. To the extent feasible, we will freely add community-nominated data sources to the PIGY Oracle. We have completely open-sourced the on- and off-chain code so that the Cardano community can easily deploy their own customized oracles for whatever data feeds they wish.

*   [Data Format](#data-format)
*   [Technical Details](#techical-details)
*   [Reading the Oracle Datum](#reading-the-oracle-datum)
*   [Risks](#risks)
*   [Disclaimer](ipfs/disclaimer.txt)

Please feel free to [contact us](mailto:code@functionally.io) with questions, concerns, or requests for assistance. In particular, we welcome collaboration, the nomination of new data feeds to include in the oracle, additional deployments of this oracle, deployments of competing oracles, and decentralization efforts.

![Example Transaction using the PIGY Oracle](example.png)


Data Format
-----------

In addition to being posted on the blockchain as eUTxO data at the smart-contract address [`addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp`](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp), for convenience the data is also posted in the eUTxO as metadata with tag `247428` and also at [ipns://k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray](http://gateway.pinata.cloud/ipns/k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray).

The service currently posts cryptocurrency and precious metal spot prices. Here is [an example](https://explorer.cardano-testnet.iohkdev.io/en/transaction?id=7832efcc4ff87cbb479dd7d84afdc1b2763fa26536d2d2a9dabb8875e7a1c064):

    {
      "disclaimer": "ipfs://QmccBPKZqh9BJTJpC8oM6rc4gBrpcVXqcixX9KCsE6yDKd",
      "oracle": "https://oracle.pigytoken.com",
      "timestamp": "2021-09-06T14:49:54+00:00",
      "data": {
        "nyfed": {
          "source": "https://www.newyorkfed.org",
          "symbols": {
            "SOFR": { "url": "https://markets.newyorkfed.org/api/rates/secured/sofr", "date": "2021-09-02", "value": 5, "scale": 100, "unit": "%" }
          }
        },
        "quandl": {
          "source": "https://www.quandl.com",
          "symbols": {
            "LBMA/GOLD/PM":        { "date": "2021-09-03", "value": 182370, "scale":       100, "unit": "USD/ounce", "url": "https://www.quandl.com/api/v3/datasets/LBMA/GOLD"       },
            "LBMA/SILVER":         { "date": "2021-09-03", "value":  24055, "scale":      1000, "unit": "USD/ounce", "url": "https://www.quandl.com/api/v3/datasets/LBMA/SILVER"     },
            "BITFINEX/ADAUSD/Mid": { "date": "2021-09-05", "value": 291205, "scale":    100000, "unit": "USD/ADA"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/ADAUSD" },
            "BITFINEX/ADABTC/Mid": { "date": "2021-09-05", "value":   5626, "scale": 100000000, "unit": "BTC/ADA"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/ADABTC" },
            "BITFINEX/BTCUSD/Mid": { "date": "2021-09-05", "value": 517745, "scale":        10, "unit": "USD/BTC"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCUSD" },
            "BITFINEX/BTCEUR/Mid": { "date": "2021-09-05", "value": 435735, "scale":        10, "unit": "EUR/BTC"  , "url": "https://www.quandl.com/api/v3/datasets/BITFINEX/BTCEUR" }
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
| BITFINEX/ADAUSD/Mid | ADA Price in USD                 |     2.91205    USD/ADA   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/ADAUSD-ADA-USD-Exchange-Rate) |
| BITFINEX/ADABTC/Mid | ADA Price in BTC                 |     0.00005626 BTC/ADA   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/ADABTC-ADA-BTC-Exchange-Rate) |
| BITFINEX/BTCUSD/Mid | BTC Price in USD                 | 51774.5        USD/BTC   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/BTCUSD-BTC-USD-Exchange-Rate) |
| BITFINEX/BTCEUR/Mid | BTC Price in EUR                 | 43573.5        EUR/BTC   | [Quandl + Bitfinex](https://www.quandl.com/data/BITFINEX/BTCEUR-BTC-EUR-Exchange-Rate) |

Archives of the data posted by the oracle are available at [ipns://k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray](http://gateway.pinata.cloud/ipns/k51qzi5uqu5dgsw6m8og2thi7kzs9lxjb7w0y4r20u0lkrm92vuqja644v6ray).


Technical Details
-----------------

See [`mantra-oracle`](https://github.com/functionally/mantra-oracle/blob/main/ReadMe.md) for complete technical details and source code.

The oracle users three types of native tokens:

*   The **fee** token: Each time another smart contract reads data from the oracle, it needs to pay a quantity of the *fee token* to the oracle contract.
*   The **datum** token: The oracle always has at its address an eUTxO that holds the *datum token*, and the oracle's data is attached to this eUTxO.
*   The **control** token: The operator of the oracle uses the *control token* to update the data in the oracle by sending it in a transaction with new data for the datum token to hold. (This token can also be used to delete the oracle altogether, ending its smart contract.)

Here are the tokens used by the two oracles:

| Network   | Control Token                                                                         | Datum Token                                                                           | Fee for Using Oracle                                                                                                    |
|-----------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `testnet` | [CORN](https://testnet.cardanoscan.io/token/441a1e1ad3783507896ef766e98d267c1a2f18cb) | [FARM](https://testnet.cardanoscan.io/token/3f638d4277da839ff6afc03a5a403dad48c94b9d) | 10 [tPIGY](https://testnet.cardanoscan.io/token/8bb3b343d8e404472337966a722150048c768d0a92a9813596c5338d.tPIGY) + 0 ADA |
| `mainnet` | [CORN](https://cardanoscan.io/token/441a1e1ad3783507896ef766e98d267c1a2f18cb)         | [FARM](https://cardanoscan.io/token/3f638d4277da839ff6afc03a5a403dad48c94b9d)         | 10 [PIGY](https://cardanoscan.io/token/2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac664.PIGYToken) + 0 ADA      |

The oracle runs on both `testnet` and `mainnet`:

| Network   | Configuration                                   | Address                                                                                                                                                                                             | Plutus Script                                  | Plutus Code                                                                                                                                  |
|-----------|-------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `testnet` | [testnet.mantra-oracle](testnet.mantra-oracle)] | [`addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp`](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr_test1wzpw9x08aymg7g50v5fet6hxgf2phwvhum7uq8mvwr0geasgctrpp) | [oracle.testnet.plutus](oracle.testnet.plutus) | [`Mantra.Oracle`](https://github.com/functionally/mantis-oracle/blob/0748820adf93dfd62c7e3d02b4c9d121b3e45139/src/Mantra/Oracle.hs#L95-L149) |
| `mainnet` | [mainnet.mantra-oracle](mainnet.mantra-oracle)] | [`addr1w83xtd6pekdv93xkj4qz77a5edyuhcxeuvlwex3xm0afukgj73l65`](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr1w83xtd6pekdv93xkj4qz77a5edyuhcxeuvlwex3xm0afukgj73l65)           | [oracle.mainnet.plutus](oracle.mainnet.plutus) | [`Mantra.Oracle`](https://github.com/functionally/mantis-oracle/blob/0748820adf93dfd62c7e3d02b4c9d121b3e45139/src/Mantra/Oracle.hs#L95-L149) |

You can verify the above using the following procedure:

1.  Install the Haskell package [`mantra-oracle-0.3.2.0`](https://github.com/functionally/mantis-oracle/tree/0748820adf93dfd62c7e3d02b4c9d121b3e45139).
    
2.  Run the following to create the Plutus scripts and addresses:
        mantra-oracle export testnet.mantra-oracle oracle.testnet.plutus
        mantra-oracle export mainnet.mantra-oracle oracle.mainnet.plutus
    
3.  Compare the addresses to the table above.

See [how the oracles were created](build/ReadMe.md) for the step-by-step recipe that was used to bulid the oracles.


Reading the Oracle Datum
------------------------

In order to read the oracle, a transaction must do the following:

*   Consume the oracle eUTxO that holds the `FARM` token.
    *   *Script:* [oracle.testnet.plutus](oracle.testnet.plutus) or [oracle.mainnet.plutus](oracle.mainnet.plutus).
    *   *Datum:* a copy of the metadata whose hash resides in the eUTxO. It's easiest to compute this hash by looking at the JSON in the tag `247428` of the metadata attached to that eUTxO.
    *   *Redeemer:* the integer `1`, which tells the oracle that the datum is to be read.
*   Pay back to the oracle's address ([oracle.testnet.address](oracle.testnet.address) or [oracle.mainnet.address](oracle.mainnet.address)) the value consumed from its eUTxO plus *exactly* `10 tPIGY` (on `testnet`) or `10 PIGY` (on `mainnet`).

The oracle is meant to be used by another Plutus smart contract. See [Test Reading the Oracle](build/ReadMe.md#test-reading-the-oracle) for a step-by-step recipe for using [an example Plutus script for reading the oracle](https://github.com/functionally/mantis-oracle/blob/0748820adf93dfd62c7e3d02b4c9d121b3e45139/src/Mantra/Oracle/Reader.hs#L58-L94).

Nevertheless, you can also read the oracle data using `cardano-cli`, as shown in the recipe [read-oracle-eutxo.sh](read-oracle-eutxo.sh).

Please [create an issue](https://github.com/functionally/mantis-oracle/issues) or [contact us](mailto:code@functionally.io) if you have questions, concerns, or requests for assistance. We welcome collaboration and the nomination of new data feeds to include in the oracle.



Risks
-----

| Risk           | Mitigation                                                                                                                                                                                                                                                                                                                                   |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Transparency   | 100% of the [source code](https://github.com/functionally/mantis-oracle) and [configuration](.) for the oracle are available online and [signed by the developer](https://api.github.com/users/bwbush/gpg_keys)                                                                                                                              |
| Integrity      | Users can compare the [primary sources](#data-formats) against the oracle's transactions, or run the [data-retrieval script](fetch-data.sh) themselves and compare those results against the oracle's postings.                                                                                                                              |
| Quality        | The oracle has been thoroughly tested via manual analysis, [a semi-automated exhaustive test suite](https://github.com/functionally/mantis-oracle/blob/main/tests/ReadMe.md), the Plutus simulator, and the Plutus Application Backend.                                                                                                      |
| Security       | The oracle's active [control token](https://cardanoscan.io/token/441a1e1ad3783507896ef766e98d267c1a2f18cb) is held in a well-secured wallet, and its backup control tokens will be stored in a multisig wallet. The oracle itself is not controlled by signing keys. A copy of the oracle service's Security Plan is available upon request. |
| Cost           | For each reading by a smart contract, the oracle collects no ADA and 10 [PIGY](https://cardanoscan.io/token/2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac664.PIGYToken), which is a token readily available from stakepool operations. The network-determined ~0.78 ADA transaction fee must also be paid.                           |
| Continuity     | The oracle's transactions fees (~0.78 ADA/day or 285 ADA/year) for its daily postings are funded by ADA donation sufficient to power the oracle until at least until Epoch 360.                                                                                                                                                              |
| Centralization | We endeavor to decentralize this oracle. Please [contact us](mailto:code@functionally.io) is would you like to collaborate on the decentralization effort or host an addtional instance of the oracle.                                                                                                                                       |


Disclaimer
----------

THE SERVICE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE OPERATORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SERVICE OR THE USE OR OTHER DEALINGS IN THE SERVICE.
