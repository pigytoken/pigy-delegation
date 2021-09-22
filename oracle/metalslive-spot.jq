add | {
  Au: { value: (100 * (.gold      | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
, Pt: { value: (100 * (.platinum  | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
, Ag: { value: (100 * (.silver    | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
, Pd: { value: (100 * (.palladium | tonumber)) | round, scale: 100, unit: "USD/oz", date: (.timestamp / 1000) | todate}
}
