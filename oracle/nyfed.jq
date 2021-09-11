.refRates[] | {
  nyfed: {
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
