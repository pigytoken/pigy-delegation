#!/usr/bin/env bash


for f in pool_meta/*.json
do
echo -n ${f%%.json}\ ; jq ".ticker" $f
done 2>/dev/null | sed -e '/null$/d' -e 's/^.*pool_meta\/\([^ ]\+\) "\([^ ]\+\)"$/\1,\2/' > pool_ticker.csv
