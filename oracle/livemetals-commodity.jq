{
  livemetals: {
    source: "https://api.metals.live/v1/spot/commodities"
  , symbols: {
      Ir: { value: (  100 * (.[0].iridium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Ru: { value: (  100 * (.[1].ruthenium | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Rh: { value: (  100 * (.[2].rhodium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Al: { value: (  100 * (.[3].aluminum  | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Cu: { value: (10000 * (.[4].copper    | tonumber)) | round, scale: 10000, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Pb: { value: (10000 * (.[5].lead      | tonumber)) | round, scale: 10000, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Zn: { value: ( 1000 * (.[6].zinc      | tonumber)) | round, scale:  1000, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Ni: { value: ( 1000 * (.[7].nickel    | tonumber)) | round, scale:  1000, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    , Sn: { value: (  100 * (.[8].tin       | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
    }
  }
}
