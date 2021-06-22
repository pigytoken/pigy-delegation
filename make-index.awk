#!/usr/bin/env -S gawk -f


BEGIN {
  FS = ","
  lastPoolHash = ""
  print "<!DOCTYPE html>"
  print "<html>"
  print "  <head>"
  print "    <meta charset='utf-8'>"
  print "    <link href='view.css' type='text/css' rel='stylesheet'/>"
  print "    <title>Continuous Staking from Epochs 270 through 273</title>"
  print "  </head>"
  print "  <body>"
  print "    <h1>Continuous Staking from Epochs 270 through 273</h1>"
  print "    <table>"
  print "      <thead>"
  print "        <tr>"
  print "          <th>Pool ID</th>"
  print "          <th>Pool Address</th>"
  print "          <th>Ticker</th>"
  print "          <th>PIGY Pool?</th>"
  print "        </tr>"
  print "      </thead>"
  print "      <tbody>"
}

FNR > 1 {

  gsub(">", "\\&gt;")

  poolHash = $1
  poolAddress = $2
  poolTicker = $3
  epochNo = $4
  stakeHash = $5
  stakeAddress = $6
  stakeEpochNo = $7
  stakedAda = $8
  pigyRange = $9
  pigyPool = $10

  if (lastPoolHash != poolHash) {
    print "<tr><td><a href='" epochNo "/" poolHash ".html'><code>" poolHash "</code></a></td><td><code>" poolAddress "</code></td><td>" poolTicker "</td><td>" (pigyPool == "t" ? "✓" : "") "</td></tr>"
    lastPoolHash = poolHash
  }

}

END {
  print "      </tbody>"
  print "    </table>"
  print "  </body>"
  print "</html>"
}

