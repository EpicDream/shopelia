class Shopelia.Controllers.MerchantsController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  #Get merchant from specific url
  create: (url) ->
    $.ajax({
           type: "POST",
           url: "api/merchants",
           data: { url: url}
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             Shopelia.vent.trigger("change:merchant",data)
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log('error merchant callback')
             #console.log(JSON.stringify(errorThrown))
           });