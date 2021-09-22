add | {
  Ir: { value: (  100 * (.iridium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
, Ru: { value: (  100 * (.ruthenium | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
, Rh: { value: (  100 * (.rhodium   | tonumber)) | round, scale:   100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
}
