class Shopelia.Models.Product extends Backbone.RelationalModel
  name: "product"

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
    _.bindAll(this)
    @on("change:expected_price_product",@setExpectedPrice)
    @on("change:expected_price_shipping",@setExpectedShipping)


  addMerchantInfosToProduct: (data) ->
    console.log('in add merchant')
    console.log(data)
    @set({
          merchant_name:data.merchant.name,
          allow_iframe: data.merchant.allow_iframe,
          })


  setProduct: (data) ->
    try
      @set({
           name: data.name,
           image_url: data.image_url,
           description: data.description,
           expected_price_product: data.versions[0].price,
           expected_price_shipping: data.versions[0].price_shipping,
           shipping_info: data.versions[0].shipping_info
           merchant_name: data.merchant.name,
           allow_iframe: data.merchant.allow_iframe
           })
    catch error
      console.log(error)




  customParseFloat: (float) ->
    parseFloat(Math.round(float * 100) / 100).toFixed(2)


  setExpectedPrice: (model,value) ->
    model.set("expected_price_product",model.customParseFloat(value))

  setExpectedShipping: (model,value) ->
    console.log(value)
    unless isNaN(value)
      if parseFloat(value) isnt 0
        model.set("expected_price_shipping",model.customParseFloat(value))
      else
        model.set("expected_price_shipping","Livraison gratuite")

  getExpectedTotalPrice: ->
    if isNaN(@get('expected_price_shipping'))
      @customParseFloat(parseFloat(@get('expected_price_product')))
    else
      @customParseFloat(parseFloat(@get('expected_price_product')) + parseFloat(@get('expected_price_shipping')))


