
requirejs ['src/casper/adblock', 'vendor/adblock/matcher', 'vendor/adblock/filterStorage'],
(AdBlock, Matcher, FilterStorage) ->
  casper = require('casper').create(
    verbose: true
  )
  utils = require('utils')
  fs = require('fs')
  
  defaultMatcher = Matcher.defaultMatcher
  INIParser = FilterStorage.INIParser

  startDate = Date.now()

  # AdBlock.addSubscriptionFile('./adblockplus_easylist.txt')
  AdBlock.loadFromDisk()
  console.log("init ! (en #{Date.now() - startDate} ms)")

  casper.echo AdBlock.isBlacklisted("http://www.amazon.com/Portal-Test-Candidate-Hoodie-Large/dp/B005EG4EXY")
  casper.echo AdBlock.isBlacklisted("http://www.amazon.com/sponsorbanners/nimportequoi", "http://www.amazon.com/Portal-Test-Candidate-Hoodie-Large/dp/B005EG4EXY")

  AdBlock.saveOnDisk()

  casper.exit()
