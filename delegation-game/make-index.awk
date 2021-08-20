#!/usr/bin/env -S gawk -f


BEGIN {
  FS = ","
  lastPoolHash = ""
  print "<!DOCTYPE html>"
  print "<html>"
  print "  <head>"
  print "    <meta charset='utf-8'>"
  print "    <link href='view.css' type='text/css' rel='stylesheet'/>"
  print "    <title>Staking at PIGY Pools</title>"
  print "  </head>"
  print "  <body>"
  print "    <h1>Staking at PIGY Pools</h1>"
  print "    <table>"
  print "      <thead>"
  print "        <tr>"
  print "          <th>Pool ID</th>"
  print "          <th>Pool Address</th>"
  print "          <th>Ticker</th>"
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
  firstEpoch = $7
  noEpochs = $8
  stakedAda = $9
  pigyRange = $10

  if (lastPoolHash != poolHash) {
    print "<tr><td><a href='" epochNo "/" poolHash ".html'><code>" poolHash "</code></a></td><td><code>" poolAddress "</code></td><td>" poolTicker "</td></tr>"
    lastPoolHash = poolHash
  }

}

END {
  system("mkdir pages/" epochNo)
  print "      </tbody>"
  print "    </table>"
  print "  </body>"
  print "</html>"
}

