#   CasperAdBlock
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ['logger', "vendor/adblock/filterClasses", 'vendor/adblock/matcher'],
(logger, FilterClasses, Matcher) ->
  
  fs = require('fs')
  
  Filter = FilterClasses.Filter
  BlockingFilter = FilterClasses.BlockingFilter
  defaultMatcher = Matcher.defaultMatcher

  # Class implementing public Adblock Plus API
  # @class
  AdBlock = {
    filesList: ["easylist.txt", "easylist_fr.txt"]
    jsonBackup: "adblock.json"

    saveOnDisk: (filename) ->
      fs.write(filename || @jsonBackup, JSON.stringify(defaultMatcher))

    loadFromDisk: (filename) ->
      o = JSON.parse fs.read(filename || @jsonBackup)
      defaultMatcher.fromJSON(o);

    # addSubscriptionFile: function(/**String*/ filename)
    addSubscriptionFile: (filename) ->
      lines = fs.read(filename).split("\n")
      length = this.addPatterns(lines).length
      logger.verbose("Find #{length} filters.")
    
    # Adds user-defined filter to the list
    # addPattern: function(/**String*/ filter)
    addPattern: (filter) ->
      filter = Filter.fromText(Filter.normalize(filter))
      if filter
        filter.disabled = false
        defaultMatcher.add(filter)
      filter
    
    # Adds user-defined filters to the list
    # addPatterns: function(/**Array of String*/ filters)
    addPatterns: (filters) ->
      filters.map (filter) ->
        AdBlock.addPattern(filter)
      .filter (filter) ->
        filter != null

    isBlacklisted: (url, parentUrl) ->
      return null if ! url
      parentUrl = url if ! parentUrl
      # Ignore fragment identifier
      url = url.substring(0, index) if (index = url.indexOf("#")) >= 0

      return defaultMatcher.matchesAny(url, "DOCUMENT", getHostname(parentUrl), false) instanceof BlockingFilter
  }

  getHostname = (url) ->
    match = url.match(/:\/\/([\w-\.]+)\//)
    if match
      return match[1]
    else
      return null

  return AdBlock