class @ProductsFeed
  constructor: (@indexName, dataCallback) ->
    @tags = []
    @page = 0
    @hitsPerPage = 500
    @priceMin = 0
    @priceMax = 0
    algolia = new AlgoliaSearch("JUFLKNI0PS", '03832face9510ee5a495b06855dfa38b')
    @index = algolia.initIndex(@indexName)
    window.dataCallback = dataCallback

  sendQuery: (query, tags, priceMin, priceMax) ->
    @query = query
    @tags = tags
    @priceMin = priceMin
    @priceMax = priceMax
    @refreshData()

  setPage: (page) ->
    @page = page
    @refreshData()

  refreshData: ->
    params = { hitsPerPage: @hitsPerPage, page: @page }
    if @tags.length > 0
      params["tags"] = @tags.join(",")
    numericFilters = ""
    if @priceMin > 0 
      numericFilters = "price>" + (@priceMin * 100) + ","
    if @priceMax > 0 
      numericFilters += "price<" + (@priceMax * 100)
    if numericFilters.length > 0
      params["numericFilters"] = numericFilters
    @index.search @query, @_prepareResults, params

  _prepareResults: (success, content) ->
    eans = {}
    tags = {}
    products = []
    for i of content.hits
      eanFound = false
      result = content.hits[i]
      for j of result["_tags"]
        tag = result["_tags"][j]
        if tag.match("^ean") 
          eanFound = true
          if eans[tag] == undefined
            eans[tag] = 1
            products.push result
        else
          tags[tag] = (tags[tag] or 0) + 1
      if !eanFound
        products.push result
    tuples = []
    for key of tags
      tuples.push [key, tags[key]]
    tuples.sort (a, b) ->
      a = a[1]
      b = b[1]
      (if a < b then 1 else ((if a > b then -1 else 0)))
    tagsCategory = ""
    tagsMerchant = ""
    for i in [0..tuples.length-1] by 1
      tag = tuples[i][0]
      if tag.match("^merchant_name")
        tagsMerchant += "<span id='" + tag + "' class='label label-warning label-tag'>" +
          tag.replace("merchant_name:", "") +
          "</span> "
      else if tag.match("^category") && tuples[i][1] > 10
        tagsCategory += "<span id='" + tag + "' class='label label-default label-tag'>" +
          tag.replace("category:", "") +
          "</span> "
    window.dataCallback { "products":products, "tagsCategory": tagsCategory, "tagsMerchant": tagsMerchant }
