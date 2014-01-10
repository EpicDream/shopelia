#   CasperAdBlock
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ['logger', "vendor/adblock/filterStorage", "vendor/adblock/filterClasses", 'vendor/adblock/matcher'],
(logger, FilterStorage, FilterClasses, Matcher) ->
  
  fs = require('fs')
  
  Filter = FilterClasses.Filter
  FilterStorage = FilterStorage.FilterStorage
  BlockingFilter = FilterClasses.BlockingFilter
  defaultMatcher = Matcher.defaultMatcher

  externalPrefix = "~external~"

   # Class implementing public Adblock Plus API
   # @class
  AdBlock = {
    filesList: ["easylist.txt", "easylist_fr.txt"]
    jsonBackup: "adblock.json"

    saveOnDisk: (filename) ->
      fs.write(filename || @jsonBackup, defaultMatcher.toJSON(true))

    loadFromDisk: (filename) ->
      o = JSON.parse fs.read(filename || @jsonBackup)
      defaultMatcher.fromJSON(o);
      # for key, value in o
      #   defaultMatcher[key] = value

    # addSubscriptionFile: function(/**String*/ filename)
    addSubscriptionFile: (filename) ->
      data = fs.read(filename)
      lines = data.split("\n")

      filters = (filter for filter in this.addPatterns(lines) when filter isnt null)
      logger.verbose("Find #{filters.length} filters.")

      for filter in filters
        defaultMatcher.add(filter)
    
    # Adds user-defined filter to the list
    # addPattern: function(/**String*/ filter)
    addPattern: (filter) ->
      filter = Filter.fromText(Filter.normalize(filter))
      if filter
        filter.disabled = false
        FilterStorage.addFilter(filter)
      filter
    
    # Adds user-defined filters to the list
    # addPatterns: function(/**Array of String*/ filters)
    addPatterns: (filters) ->
      filters.map (filter) ->
        AdBlock.addPattern(filter)

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