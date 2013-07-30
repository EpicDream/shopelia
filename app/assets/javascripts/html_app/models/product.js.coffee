class Shopelia.Models.Product extends Backbone.Model
  name: "product"

  longPolling: false
  intervalSeconds: 0.1

  validate: (attrs, options) ->
    if attrs.shipping_info is undefined or attrs.shipping_info == ""
      "Invalid Product: Missing Attrs"
    if attrs.expected_price_product is undefined or attrs.expected_price_product == ""
      "Invalid Product: Missing Attrs"
    if isNaN(attrs.expected_price_shipping) or  attrs.expected_price_shipping == ""
      "Invalid Product: Missing Attrs"
    if attrs.name is undefined or attrs.name == ""
      "Invalid Product: Missing Attrs"
    if attrs.image_url is undefined or attrs.image_url == ""
      "Invalid Product: Missing Attrs"



  initialize: (params) ->
    console.log('Initializing Product with params')
    _.bindAll(this, "startLongPolling", "stopLongPolling","onComplete")
    if this.isValid()
      @getMerchant()
    else
      @startLongPolling()


  startLongPolling: (intervalSeconds) ->
    @redirectTime = 0
    @longPolling = true
    @intervalSeconds = intervalSeconds  if intervalSeconds
    @getProduct()

  stopLongPolling: ->
    console.log("stop polling")
    @longPolling = false

  onComplete: ->
    setTimeout @getProduct(), 1000 * @intervalSeconds  if @longPolling # in order to update the view each N minutes


  getMerchant: ->
    that = this
    $.ajax({
           type: "POST",
           url: "api/merchants",
           data: { url: that.get("url") }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             that.set({
                      merchant_name:data.merchant.name,
                      allow_iframe: data.merchant.allow_iframe,
                      })
             console.log(that.description)
             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log('error merchant callback')
             #console.log(JSON.stringify(errorThrown))
           });

  getProduct: ->
    that = this
    @begin_time_request = 0
    $.ajax({
           type: "GET",
           url: "api/products",
           data: { url: that.get("url") }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
             that.begin_time_request = new Date().getTime();
           success: (data,textStatus,jqXHR) ->
             console.log("success retrieving product")
             console.log(data)
             that.set({
                      name: data.name,
                      image_url: data.image_url,
                      description: data.description,
                      expected_price_product: data.versions[0].price,
                      expected_price_shipping: data.versions[0].price_shipping,
                      shipping_info: data.versions[0].shipping_info
                      merchant_name: data.merchant.name,
                      allow_iframe: data.merchant.allow_iframe
                      },{validate : true})
             that.foundProduct()
             #console.log(that.redirectTime)

             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log('error callback getting Product ')
             #console.log(JSON.stringify(errorThrown))
    });


  foundProduct: ->
    if @redirectTime < 1000 * @intervalSeconds
      console.log("found" +  this.isValid())
      if @isValid()
        @stopLongPolling()
        @set({
             found: true
            })
      else
        requestTime  = new Date().getTime() - @begin_time_request
        @redirectTime += requestTime
        @onComplete()
    else
      console.log("redirect")
      @set({
            found: false
          })