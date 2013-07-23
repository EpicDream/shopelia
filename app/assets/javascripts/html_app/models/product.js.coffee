class Shopelia.Models.Product extends Backbone.Model
  name: "product"

  validate: (attrs, options) ->
    if attrs.shipping_info is undefined or attrs.shipping_info == ""
      "Invalid Product: Missing Attrs"
    if attrs.expected_price_product is undefined or attrs.expected_price_product == ""
      "Invalid Product: Missing Attrs"
    if attrs.expected_price_shipping is undefined or  attrs.expected_price_shipping == ""
      "Invalid Product: Missing Attrs"
    if attrs.name is undefined or attrs.name == ""
      "Invalid Product: Missing Attrs"
    if attrs.image_url is undefined or attrs.image_url == ""
      "Invalid Product: Missing Attrs"



  initialize: (params) ->
    console.log('Initializing Product with params')
    if this.isValid()
      @getMerchant()
    else
      @getProduct()


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
             that.set({merchant_name:data.merchant.name})
             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
           error: (jqXHR,textStatus,errorThrown) ->
             console.log('error merchant callback')
             console.log(JSON.stringify(errorThrown))
           });

  getProduct: ->
    that = this
    $.ajax({
           type: "GET",
           url: "api/products",
           data: { url: that.get("url") }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             console.log("success retrieving product")
             console.log(data)
             console.log(data.name)
             console.log(data.image_url)
             console.log(data.merchant.name)
             console.log(data.versions[0].price)
             console.log(data.versions[0].price_shipping)
             console.log(data.versions[0].shipping_info)
             that.set({
                      name: data.name,
                      image_url: data.image_url,
                      expected_price_product: data.versions[0].price,
                      expected_price_shipping: data.versions[0].price_shipping,
                      shipping_info: data.versions[0].shipping_info
                      merchant_name: data.merchant.name
                      })
             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
           error: (jqXHR,textStatus,errorThrown) ->
             console.log('error callback getting Product ')
             console.log(JSON.stringify(errorThrown))
           });
