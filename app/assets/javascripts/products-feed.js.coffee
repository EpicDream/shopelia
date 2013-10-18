class @ProductsFeed
  constructor: (@indexName, @dataCallback, @tagsCallback) ->
    @tags = []
    @page = 0
    @hitsPerPage = 20
    @hitsForTags = 100
    algolia = new AlgoliaSearch("JUFLKNI0PS", '03832face9510ee5a495b06855dfa38b')
    @index = algolia.initIndex(@indexName)

  sendQuery: (query) ->
    @query = query
    @refreshData()
    if @page == 0
      @refreshTags()

  setPage: (page) ->
    @page = page
    @refreshData()

  refreshData: ->
    @index.search @query, @dataCallback, hitsPerPage: @hitsPerPage, page: @page

  refreshTags: ->
    @index.search @query, @tagsCallback, hitsPerPage: @hitsForTags

  parseTags: (content) ->
    tags = {}
    for i of content.hits
      result = content.hits[i]
      for j of result["_tags"]
        tag = result["_tags"][j]
        tags[tag] = (tags[tag] or 0) + 1  unless tag.match("^ean")
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
    "tagsCategory": tagsCategory, "tagsMerchant": tagsMerchant