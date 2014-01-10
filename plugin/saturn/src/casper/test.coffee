
requirejs ['src/casper/adblock'],
(AdBlock) ->
  casper = require('casper').create(
    verbose: true
  )
  utils = require('utils')
  fs = require('fs')
  
  startDate = Date.now()

  if casper.cli.get("load")
    AdBlock.loadFromDisk()
  else
    AdBlock.addSubscriptionFile('./easylist.txt')
    AdBlock.addSubscriptionFile('./easylist_fr.txt')
  console.log("init ! (en #{Date.now() - startDate} ms)")

  casper.echo AdBlock.isBlacklisted("http://www.amazon.com/Portal-Test-Candidate-Hoodie-Large/dp/B005EG4EXY")
  casper.echo AdBlock.isBlacklisted("http://www.amazon.com/sponsorbanners/nimportequoi", "http://www.amazon.com/Portal-Test-Candidate-Hoodie-Large/dp/B005EG4EXY")

  AdBlock.saveOnDisk()

  casper.exit()
