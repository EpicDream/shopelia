class Shopelia.Views.PaymentCardsIndex extends Shopelia.Views.Form

  template: JST['payment_cards/index']
  className: 'paiement-view'

  events:
    "click #btn-register-payment": "registerPaymentCard"
    'keydown input[name="number"]':'addSpaceToCardNumber'
    'keyup input[name="exp_date"]': "formatExpDate"


  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    if @options.session is undefined
      console.log(@$('#btn-register-payment'))
      @$('#btn-register-payment').remove()
    @setCardFormVariables()
    Shopelia.Views.Form.prototype.render.call(this)
    this

  setPaymentCard: ->
    cardJson = @cardFormSerializer()
    card = new Shopelia.Models.PaymentCard()
    card.on("invalid", (model, errors) ->
      displayErrors(errors)
    )

    card.set(cardJson)
    console.log("card in setPaymentCard" + JSON.stringify(card))
    card


  registerPaymentCard: (e) ->
    console.log("trigger registerPaymentCard")
    if $('form').parsley( 'validate' )
      e.preventDefault()
      cardJson = @cardFormSerializer()
      that = this
      card = new Shopelia.Models.PaymentCard()
      card.on("invalid", (model, errors) ->
        displayErrors(errors)
      )

      card.save(cardJson,{
                          beforeSend : (xhr) ->
                            xhr.setRequestHeader("X-Shopelia-AuthToken",that.options.session.get("auth_token"))
                          success : (resp) ->
                            console.log('card success callback')
                            that.options.session.get("user").payment_cards.push(resp.disableWrapping().toJSON())
                            console.log(JSON.stringify(that.options))
                            goToOrdersIndex(that.options.session,that.options.product)
                          error : (model, response) ->
                            console.log('card error callback')
                            console.log(JSON.stringify(response))
                            displayErrors($.parseJSON(response.responseText))
      })

  setCardFormVariables: ->
    @cardNumber = @$('input[name="number"]')
    @date =  @$('input[name="exp_date"]')
    @cvv = @$('input[name="cvv"]')


  cardFormSerializer: ->
    cardFormObject = {};
    cardNumber = @cardNumber.val().replace(/\s+/g,'')
    date = @date.val()
    month = date.substr(0,date.indexOf('/'))
    year = date.substr(date.indexOf('/')+1)
    year = "20" + year
    cvv =  @cvv.val()

    cardFormObject = {
    "number":  cardNumber,
    "exp_month": month,
    "exp_year": year,
    "cvv": cvv
    }
    if @options.session isnt undefined
      userId = @options.session.get("user").id
      console.log("userId:" + userId )
      cardFormObject["user_id"] =  userId
    console.log cardFormObject
    cardFormObject

  addSpaceToCardNumber: ->
    newValue = @cardNumber.val()
    if (newValue.length is 4 or newValue.length is 9 or newValue.length is 14) and event.keyCode != 8
      newValue = newValue + " "
      @cardNumber.val(newValue)

  formatExpDate: (e) ->
    if @date.val().length == 2 && e.keyCode != 8
      newValue = @date.val()
      newValue = newValue + "/"
      @date.val(newValue)

