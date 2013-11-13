class @Catalogue
  constructor: (itemsPerPage, collectionId) ->
    @feed = new ProductsFeed("products-feed-fr", @dataCallback)
    window.collectionId = collectionId
    window.catalogueItemsPerPage = itemsPerPage
    window.cataloguePage = 0
    window.catalogueShowCurrentPage = @showCurrentPage
    window.catalogueHasPreviousPage = @hasPreviousPage
    window.catalogueHasNextPage = @hasNextPage
    that = this
    $("#catalogue-search").on "keyup", ->
      query = $(this).val()
      if query.length > 2
        that.feed.sendQuery query
      else
        that.clean()
    $("#catalogue-next-page").on "click", ->
      that.pageUp()
    $("#catalogue-previous-page").on "click", ->
      that.pageDown()
    $(".catalogue-box").on "click", ->
      if $(@).data("saturn") == "1"
        that.addToCollection $(@).data("product-url")
      else
        that.addToCollectionByFeed $(@).data("feed-json")

  dataCallback: (result) ->
    window.cataloguePage = 0
    window.catalogueProducts = result["products"]
    window.catalogueShowCurrentPage()
    $("#search-info").html result["products"].length + " local results"
    $("#tags-merchant").html result["tagsMerchant"]
    $("#tags-category").html result["tagsCategory"]

  pageUp: ->
    if @hasNextPage
      window.cataloguePage++
      @showCurrentPage()

  pageDown: ->
    if @hasPreviousPage
      window.cataloguePage--
      @showCurrentPage()

  hasNextPage: ->
    (window.cataloguePage + 1) * window.catalogueItemsPerPage < window.catalogueProducts.length

  hasPreviousPage: ->
    window.cataloguePage > 0

  showCurrentPage: ->
    productIndex = window.cataloguePage * window.catalogueItemsPerPage
    for i in [0..window.catalogueItemsPerPage] by 1
      if productIndex < window.catalogueProducts.length
        product = window.catalogueProducts[productIndex]
        $("#catalogue-box-" + i).removeClass "display-none"
        $("#catalogue-box-img-" + i).attr "src", product["image_url"]
        $("#catalogue-box-price-" + i).html Math.round(product["price"] / 100) + " €"
        $("#catalogue-box-name-" + i).html product["name"]
        $("#catalogue-box-merchant-" + i).html product["merchant"]["name"]
        $("#catalogue-box-" + i).data('product-url', product["product_url"])
        $("#catalogue-box-" + i).data('saturn', product["saturn"])
        $("#catalogue-box-" + i).data('feed-json', JSON.stringify([product]))
      else
        $("#catalogue-box-" + i).removeClass "display-none"
        $("#catalogue-box-" + i).addClass "display-none"

      productIndex++
    if window.catalogueHasPreviousPage()
      $("#catalogue-previous-page").show()
    else
      $("#catalogue-previous-page").hide()
    if window.catalogueHasNextPage()
      $("#catalogue-next-page").show()
    else
      $("#catalogue-next-page").hide()

  clean: ->
    $("#tags-merchant").html ""
    $("#tags-category").html ""
    $("#search-info").html ""
    i = 0
    while i < window.catalogueItemsPerPage
      $("#catalogue-box-" + i).removeClass "display-none"
      $("#catalogue-box-" + i).addClass "display-none"
      i++

  addToCollection: (url) ->
    $.ajax
      url: "/admin/collection_items"
      dataType: "script"
      type: "post"
      contentType: "application/json"
      data: JSON.stringify(collection_item:{collection_id: window.collectionId,url: url})

  addToCollectionByFeed: (product) ->
    $.ajax
      url: "/admin/collection_items"
      dataType: "script"
      type: "post"
      data: {collection_id: window.collectionId,feed: product}

  shuffle: (size) ->
    items = []
    max_size = window.catalogueProducts.length
    if size > max_size
      size = max_size
    added = {}
    i = 0
    while i < size
      item = window.catalogueProducts[Math.floor(Math.random() * max_size)]
      if added[item["product_url"]] == undefined
        added[item["product_url"]] = 1
        items.push item
        i++
    items

  top: (size) ->
    items = []
    max_size = window.catalogueProducts.length
    if size > max_size
      size = max_size
    for i in [0..size] by 1
      items.push window.catalogueProducts[i]
    items