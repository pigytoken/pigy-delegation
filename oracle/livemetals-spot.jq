{
  livemetals: {
    source: "https://api.metals.live"
  , symbols: {
      Au: { value: (100 * (.[0].gold      | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.[4].timestamp / 1000) | todate}
    , Pt: { value: (100 * (.[1].platinum  | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.[4].timestamp / 1000) | todate}
    , Ag: { value: (100 * (.[2].silver    | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.[4].timestamp / 1000) | todate}
    , Pd: { value: (100 * (.[3].palladium | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.[4].timestamp / 1000) | todate}
    }
  }
}
