{
  coingecko: {
    notice: "Data provided by CoinGecko",
    source: "https://www.coingecko.com/api",
    symbols: {
      ADAUSD: {value: (      100 * .cardano.usd)  | round, scale:       100, unit: "USD/ADA"},
      ADAEUR: {value: (      100 * .cardano.eur)  | round, scale:       100, unit: "EUR/ADA"},
      ADAGBP: {value: (      100 * .cardano.gbp)  | round, scale:       100, unit: "GBP/ADA"},
      ADAIDR: {value: (        1 * .cardano.idr)  | round, scale:         1, unit: "IDR/ADA"},
      ADAJPY: {value: (      100 * .cardano.jpy)  | round, scale:       100, unit: "JPY/ADA"},
      ADABTC: {value: (100000000 * .cardano.btc)  | round, scale: 100000000, unit: "BTC/ADA"},
      ADAETH: {value: (100000000 * .cardano.eth)  | round, scale: 100000000, unit: "ETH/ADA"},
      BTCUSD: {value: (        1 * .bitcoin.usd)  | round, scale:         1, unit: "USD/BTC"},
      BTCEUR: {value: (        1 * .bitcoin.eur)  | round, scale:         1, unit: "EUR/BTC"},
      BTCGBP: {value: (        1 * .bitcoin.gbp)  | round, scale:         1, unit: "GBP/BTC"},
      BTCIDR: {value: (        1 * .bitcoin.idr)  | round, scale:         1, unit: "IDR/BTC"},
      BTCJPY: {value: (        1 * .bitcoin.jpy)  | round, scale:         1, unit: "JPY/BTC"},
      BTCETH: {value: (  1000000 * .bitcoin.eth)  | round, scale:   1000000, unit: "ETH/BTC"},
      ETHUSD: {value: (      100 * .ethereum.usd) | round, scale:       100, unit: "USD/ETH"},
      ETHEUR: {value: (      100 * .ethereum.eur) | round, scale:       100, unit: "EUR/ETH"},
      ETHGBP: {value: (      100 * .ethereum.gbp) | round, scale:       100, unit: "GBP/ETH"},
      ETHIDR: {value: (        1 * .ethereum.idr) | round, scale:         1, unit: "IDR/ETH"},
      ETHJPY: {value: (        1 * .ethereum.jpy) | round, scale:         1, unit: "JPY/ETH"},
      ETHBTC: {value: (  1000000 * .ethereum.btc) | round, scale:   1000000, unit: "BTC/ETH"},
    }
  }
}
