Monitor =
  init: ->
    @pusher = new Pusher("654ffe989dceb4af5e03")
  cart_item: (uuid, product_id) ->
    @init if !@pusher
    channel =  @pusher.subscribe("product-" + product_id)
    channel.bind "update", (data) ->
      $("#product-" + product_id).load("/cart_items/" + uuid)
  collection_item: (item_id, product_id) ->
    @init if !@pusher
    channel =  @pusher.subscribe("product-" + product_id)
    channel.bind "update", (data) ->
      $("#product-" + product_id).load("/collection_items/" + item_id)