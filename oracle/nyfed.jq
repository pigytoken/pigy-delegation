.refRates[] | {
  nyfed: {
    notice: "Data provided by Federal Reserve Bank of New York",
    source: "https://www.newyorkfed.org",
    symbols: {
      SOFR: {
        url: "https://markets.newyorkfed.org/api/rates/secured/sofr",
        date: .effectiveDate,
        value: (100 * .percentRate) | round,
        scale: 100, unit: "%"
      }
    }
  }
}
