{
  Ir: { value: (  100 * (.[0].iridium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
, Ru: { value: (  100 * (.[1].ruthenium | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
, Rh: { value: (  100 * (.[2].rhodium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.[9].timestamp / 1000) | todate}
}
