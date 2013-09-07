class Shopelia.Models.Product extends Backbone.RelationalModel
  name: "product"

  setQuantity: (data) ->
    console.log("Quantity " + data)
    @set("quantity", data)

  setProduct: (data) ->
    console.log("setData")
    console.log(data)
    @set({
      name: data.name,
      image_url: data.image_url,
      description: data.description,
      available: data.versions.length > 0
      merchant_name: data.merchant.name,
      merchant_logo: data.merchant.logo,
      allow_iframe: data.merchant.allow_iframe,
      allow_quantities: data.merchant.allow_quantities,
      quantity: 1,
      ready: data.ready
    })
    if @get('available')
      @set({
        product_version_id:data.versions[0].id,
        expected_price_shipping: data.versions[0].price_shipping,
        expected_price_product_original: data.versions[0].price,
        expected_price_product: data.versions[0].price,
        shipping_info: data.versions[0].shipping_info,
        availability_info: data.versions[0].availability_info,
      })    
      if data.versions[0].cashfront_value > 0
        @set({
          expected_price_strikeout: data.versions[0].price
          expected_cashfront_value: data.versions[0].cashfront_value
        })
      else
        @set({
          expected_cashfront_value: 0
        })
      r = @get('shipping_info') 
      if @get('availability_info') && @get('availability_info') != r
        r += "<br><small>" + @get('availability_info') + "</small>"
      @set({shipping_info_full: r})
    console.log(@)

  getExpectedTotalPrice: ->
    @get('expected_price_product') * @get('quantity') + @get('expected_price_shipping')
