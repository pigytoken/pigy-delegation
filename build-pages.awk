#!/usr/bin/env -S gawk -f


BEGIN {
  FS = ","
  lastPoolHash = ""
}

FNR > 1 {

  gsub(">", "\\&gt;")

  poolHash = $1
  poolAddress = $2
  poolTicker = $3
  epochNo = $4
  stakeHash = $5
  stakeAddress = $6
  firstEpoch = $7
  noEpochs = $8
  stakedAda = $9
  pigyRange = $10

  if (lastPoolHash != poolHash) {
    if (lastPoolHash != "") {
      output = output " </tbody></table></body></html>"
      print output > ("pages/" epochNo "/" lastPoolHash ".html")
    }
    output = "<!DOCTYPE html><html><head><meta charset='utf-8'><link href='../view.css' type='text/css' rel='stylesheet'/><title>Epoch " epochNo " Staking for Pool ID " poolHash "</title></head><body><h1>Staking at Epoch " epochNo "</h1><h2>Pool ID: <code><a href='https://pooltool.io/pool/" poolHash "'>" poolHash "</a></code></h2><h2>Pool Address: <code>" poolAddress "</code></h2>" (poolTicker == "\"\"" ? "" : "<h2>Pool Ticker: " poolTicker "</h2>") "<table><thead><tr><th>Address Hash</th><th>Address</th><th>First Epoch<br/>in Pool</th><th>No. of Epochs<br/>in Pool</th><th>ADA in Epoch " epochNo "</th><th>PIGY Range</th></thead><tbody>"
    lastPoolHash = poolHash
  }

  output = output "<tr><td><a href='https://pooltool.io/address/" stakeHash "'>" stakeHash "</a></td><td>" stakeAddress "</td><td>" firstEpoch "</td><td>" noEpochs "</td><td>" stakedAda "</td><td>" pigyRange "</td></tr>"
}

END {
  output = output " </tbody></table></body></html"
  print output > ("pages/" epochNo "/" lastPoolHash ".html")
}

