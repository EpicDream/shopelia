class Shopelia.Controllers.PaymentController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.CardFields()
    region.show(@view)


  create: (card) ->
    @view.lockView()
    card.save(cardJson,{
      beforeSend : (xhr) ->
        xhr.setRequestHeader("X-Shopelia-AuthToken",that.getSession().get("auth_token"))
      success : (resp) ->
        #console.log('card success callback')
        that.getSession().get("user").payment_cards.push(resp.disableWrapping().toJSON())
        that.parent.setContentView(new Shopelia.Views.OrdersIndex())
      error : (model, response) ->
        #console.log('card error callback')
        that.view.unlockView()
        Shopelia.Notification.Error({ text: $.parseJSON(response.responseText)['error'] })
        console.log(response.responseText)
        displayErrors($.parseJSON(response.responseText))

      })


