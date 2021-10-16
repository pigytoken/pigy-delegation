add | {
  Ir: { value: (  100 * (.iridium   | tonumber)) | round, scale:   100, unit: "USD/toz", date: (.timestamp / 1000) | todate}
, Ru: { value: (  100 * (.ruthenium | tonumber)) | round, scale:   100, unit: "USD/toz", date: (.timestamp / 1000) | todate}
, Rh: { value: (  100 * (.rhodium   | tonumber)) | round, scale:   100, unit: "USD/toz", date: (.timestamp / 1000) | todate}
, Al: { value: (  100 * (.aluminum  | tonumber)) | round, scale:   100, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Cu: { value: (10000 * (.copper    | tonumber)) | round, scale: 10000, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Sn: { value: (  100 * (.tin       | tonumber)) | round, scale:   100, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Pb: { value: (10000 * (.lead      | tonumber)) | round, scale: 10000, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Ni: { value: ( 1000 * (.nickel    | tonumber)) | round, scale:  1000, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Zn: { value: ( 1000 * (.zinc      | tonumber)) | round, scale:  1000, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
, Co: { value: (  100 * (.cobalt    | tonumber)) | round, scale:   100, unit: "USD/lb" , date: (.timestamp / 1000) | todate}
}
