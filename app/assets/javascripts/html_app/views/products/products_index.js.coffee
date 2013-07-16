class Shopelia.Views.ProductsIndex extends Backbone.View

  template: JST['products/index']
  className: 'product'

  initialize: ->
    _.bindAll this
    @getMerchant()


  render: ->
    console.log(@model)
    expected_price_product = customParseFloat(@model.get('expected_price_product'))
    @model.set('expected_price_product',expected_price_product)
    expected_price_shipping  = customParseFloat(@model.get('expected_price_shipping'))
    @model.set('expected_price_shipping',expected_price_shipping)
    $(@el).html(@template(model: @model, merchant: @merchant))
    this

  getMerchant: ->
    that = this
    $.ajax({
           type: "POST",
           url: "api/merchants",
           data: { url: that.model.get("url") }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",window.Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
           error: (jqXHR,textStatus,errorThrown) ->
             console.log('error merchant callback')
             console.log(JSON.stringify(errorThrown))
           });