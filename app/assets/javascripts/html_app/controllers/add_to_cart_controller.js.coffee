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
             #Abba('SPAM information').complete();
             Abba("Product sign-up position").complete();
             Shopelia.Notification.Success({
                                           center: true
                                           title: "Suivi du produit activé !",
                                           text: "Vous allez recevoir un email pour pouvoir retrouver ce produit facilement"
                                           after_close: () ->
                                             if window.Shopelia.AbbaCartPosition == 'popup'
                                               Shopelia.vent.trigger("modal#close")
                                             else
                                               Shopelia.vent.trigger("add_to_cart#close")
                                           })
           error: (jqXHR,textStatus,errorThrown) ->
             Shopelia.Notification.Error({
                                           center: true,
                                           title: "Erreur",
                                           text: "Nous ne sommes pas parvenu à suivre ce produit. Vérifiez votre email ou veuillez essayer ultérieurement."})
           })