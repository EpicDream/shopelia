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
    #console.log('Initializing Product with params')
    _.bindAll(this)
    @on("change:expected_price_product",@formatPrice,"expected_price_product")
    @on("change:expected_price_shipping",@formatPrice,"expected_price_shipping")


  addMerchantInfosToProduct: (data) ->
    console.log('in add merchant')
    console.log(data)
    @set({
          merchant_name:data.merchant.name,
          allow_iframe: data.merchant.allow_iframe,
          })


  setProduct: (data) ->
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


  customParseFloat: (float) ->
    parseFloat(Math.round(float * 100) / 100).toFixed(2)

  formatPrice: (model,value) ->
    result =  model.customParseFloat(value)
    model.set(this.toString(),result)

  getExpectedTotalPrice: ->
    @customParseFloat(parseFloat(@get('expected_price_product')) + parseFloat(@get('expected_price_shipping')))

