class Shopelia.Views.ProductsIndex extends Backbone.View

  template: JST['products/index']
  className: 'product'

  initialize: ->
    _.bindAll this
    @getProvider()


  render: ->
    console.log(@merchant)
    $(@el).html(@template(model: @model, merchant: @merchant))
    this

  getProvider: ->
    that = this
    $.ajax({
           type: "POST",
           url: "api/merchants",
           data: { url: that.model.get("url") }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey","52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4")
           success: (data,textStatus,jqXHR) ->
             $(".merchant-infos").append("Proposé par <br> <b>" +  data.merchant.name + "</b>")
             console.log(data.merchant)
           error: (jqXHR,textStatus,errorThrown) ->
             console.log('error merchant callback')
             console.log(JSON.stringify(errorThrown))
           });