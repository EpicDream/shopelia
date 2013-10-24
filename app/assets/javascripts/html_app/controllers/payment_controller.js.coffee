class Shopelia.Controllers.PaymentController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.CardFields()
    region.show(@view)


  create: (card) ->
    @view.lockView()
    that = this
    card.save({},{
      beforeSend : (xhr) ->
        xhr.setRequestHeader("X-Shopelia-AuthToken",that.getSession().get("auth_token"))
      success : (resp) ->
        that.getSession().get("user").get('payment_cards').add(resp.disableWrapping().toJSON())
        console.log(that.getSession().get("user").get('payment_cards'))

      error : (model, response) ->
        #console.log('card error callback')
        that.view.unlockView()
        Shopelia.Notification.Error({ text: $.parseJSON(response.responseText)['error'] })
        console.log(response.responseText)
        displayErrors($.parseJSON(response.responseText))

      })


