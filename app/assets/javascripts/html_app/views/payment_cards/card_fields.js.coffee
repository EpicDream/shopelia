class Shopelia.Views.CardFields extends Shopelia.Views.Form

  template: 'payment_cards/card_fields'
  className: 'paiement-view'

  events:
    "click #btn-register-payment": "registerPaymentCard"
    'keydown input[name="number"]':'addSpaceToCardNumber'
    'keyup input[name="number"]': 'addCardType'
    'keyup input[name="exp_date"]': "formatExpDate"


  initialize: ->
    Shopelia.Views.Form.prototype.initialize.call(this)


  onRender: ->
    #Shopelia.Views.Form.prototype.render.call(this)

  setPaymentCard: ->
    cardJson = @cardFormSerializer()
    card = new Shopelia.Models.PaymentCard()
    card.on("invalid", (model, errors) ->
      displayErrors(errors)
    )

    card.set(cardJson)
    card


  registerPaymentCard: (e) ->
    #console.log("trigger registerPaymentCard")
    if $('form').parsley( 'validate' )
      e.preventDefault()
      disableButton($("#btn-register-payment"))
      cardJson = @cardFormSerializer()
      that = this
      card = new Shopelia.Models.PaymentCard()
      card.on("invalid", (model, errors) ->
        displayErrors(errors)
      )

      card.save(cardJson,{
                          beforeSend : (xhr) ->
                            xhr.setRequestHeader("X-Shopelia-AuthToken",that.getSession().get("auth_token"))
                          success : (resp) ->
                            #console.log('card success callback')
                            that.getSession().get("user").payment_cards.push(resp.disableWrapping().toJSON())
                            that.parent.setContentView(new Shopelia.Views.OrdersIndex())
                          error : (model, response) ->
                            #console.log('card error callback')
                            enableButton($("#btn-register-payment"))
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
    if @getSession().authenticated()
      userId = @getSession().get("user").id
      cardFormObject["user_id"] =  userId
    cardFormObject

  addCardType: ->
    #console.log(@cardNumber.val().charAt(0))
    if @cardNumber.val().length > 2
      if  @cardNumber.val().charAt(0) == "3"
        @cardNumber.removeClass("visa")
        @cardNumber.addClass("amex")
        @cardNumber.removeClass("mastercard")
      else if @cardNumber.val().charAt(0) == "4"
        @cardNumber.addClass("visa")
        @cardNumber.removeClass("amex")
        @cardNumber.removeClass("mastercard")
      else if @cardNumber.val().charAt(0) == "5"
        @cardNumber.removeClass("visa")
        @cardNumber.removeClass("amex")
        @cardNumber.addClass("mastercard")
    else
      @cardNumber.removeClass("visa")
      @cardNumber.removeClass("amex")
      @cardNumber.removeClass("mastercard")


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

