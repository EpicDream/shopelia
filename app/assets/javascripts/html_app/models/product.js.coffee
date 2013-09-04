class Shopelia.Models.Product extends Backbone.RelationalModel
  name: "product"

  validate: (attrs, options) ->
    if attrs.shipping_info is undefined or attrs.shipping_info == ""
      "Invalid Product: Missing Attrs"
    if attrs.expected_price_product is undefined or attrs.expected_price_product == ""
      "Invalid Product: Missing Attrs"
    if isNaN(attrs.expected_price_shipping) or attrs.expected_price_shipping == ""
      "Invalid Product: Missing Attrs"
    if attrs.name is undefined or attrs.name == ""
      "Invalid Product: Missing Attrs"
    if attrs.image_url is undefined or attrs.image_url == ""
      "Invalid Product: Missing Attrs"

  addMerchantInfosToProduct: (data) ->
    console.log('in add merchant')
    console.log(data)
    @set({
      merchant_name: data.merchant.name,
      merchant_logo: data.merchant.logo,
      allow_iframe: data.merchant.allow_iframe,
      allow_quantities: data.merchant.allow_quantities
    })

  setQuantity: (data) ->
    console.log("Quantity " + data)
    @set("quantity", data)

  setProduct: (data) ->
    console.log("setData")
    console.log(data)
    try
      @set({
        product_version_id:data.versions[0].id,
        name: data.name,
        image_url: data.image_url,
        description: data.description,
        expected_price_shipping: data.versions[0].price_shipping,
        expected_price_product_original: data.versions[0].price,
        shipping_info: data.versions[0].shipping_info
        merchant_name: data.merchant.name,
        merchant_logo: data.merchant.logo,
        allow_iframe: data.merchant.allow_iframe,
        allow_quantities: data.merchant.allow_quantities,
        quantity: 1
      })
      if data.versions[0].cashfront_value > 0
        @set({
          expected_price_strikeout: data.versions[0].price
          expected_price_product: data.versions[0].price - data.versions[0].cashfront_value,
          expected_cashfront_value: data.versions[0].cashfront_value
        })
      else
        @set({
          expected_price_product: data.versions[0].price,
          expected_cashfront_value: 0
        })
    catch error
      console.log(error)

  getExpectedTotalPrice: ->
    @get('expected_price_product') * @get('quantity') + @get('expected_price_shipping')