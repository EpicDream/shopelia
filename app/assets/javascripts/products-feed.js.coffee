class @ProductsFeed
  constructor: (@indexName, dataCallback) ->
    @tags = []
    @page = 0
    @hitsPerPage = 100
    algolia = new AlgoliaSearch("JUFLKNI0PS", '03832face9510ee5a495b06855dfa38b')
    @index = algolia.initIndex(@indexName)
    window.dataCallback = dataCallback

  sendQuery: (query) ->
    @query = query
    @refreshData()

  setPage: (page) ->
    @page = page
    @refreshData()

  refreshData: ->
    @index.search @query, @_prepareResults, hitsPerPage: @hitsPerPage, page: @page

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
        tagsMerchant += "<span class='label label-warning'>" +
          tag.replace("merchant_name:", "") +
          "</span> "
      else if tag.match("^category")
        tagsCategory += "<span class='label label-default'>" +
          tag.replace("category:", "") +
          "</span> "
    window.dataCallback { "products":products, "tagsCategory": tagsCategory, "tagsMerchant": tagsMerchant }
