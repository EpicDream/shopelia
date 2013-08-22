class Shopelia.Controllers.AddToCartController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show:(region) ->
    product = @getProduct()
    @view = new Shopelia.Views.AddToCart(model: product)
    region.show(@view)


  addProductToCart: (data) ->
    $.ajax({
           type: "POST",
           url: 'api/cart_items',
           data: data,
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             Shopelia.Notification.Success({
                                           center: true
                                           title: "Ce produit a bien été rajouté !",
                                           text: "Vous allez recevoir un email pour pouvoir retrouver ce produit ultérieurement et l'acheter. Merci d'avoir utilisé shopelia à très bientôt !"
                                           after_close: () ->
                                             Shopelia.vent.trigger("modal#close")
                                           })
           error: (jqXHR,textStatus,errorThrown) ->
             Shopelia.Notification.Error({
                                           center: true,
                                           title: "Erreur",
                                           text: "Nous ne sommes pas parvenu à rajouter ce produit veuillez essayer ultérieurement."})
           })



