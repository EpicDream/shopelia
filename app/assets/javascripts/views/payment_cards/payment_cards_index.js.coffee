class Shopelia.Views.PaymentCardsIndex extends Backbone.View

  template: JST['payment_cards/index']

  events:
    "click button": "registerPaymentCard"
    'keydown input[name="number"]':'isNumberKey'


  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    console.log(@options)
    console.log("Product is passed to card View" + @options.product)
    @setCardFormVariables()
    this


  registerPaymentCard: (e) ->
    console.log("trigger registerPaymentCard")
    e.preventDefault()
    cardJson = @cardFormSerializer()
    that = this
    card = new Shopelia.Models.PaymentCard()
    card.on("invalid", (model, errors) ->
      displayErrors(errors)
    )

    card.save({payment_card: cardJson},{
                        beforeSend : (xhr) ->
                          xhr.setRequestHeader("X-Shopelia-AuthToken",that.options.user.get("auth_token"))
                        success : (resp) ->
                          console.log('card success callback')
                          console.log(resp.get("payment_card"))
                          console.log(that.options.user.get("user").payment_cards)
                          that.options.user.get("user").payment_cards.push(resp.get("payment_card"))
                          console.log(JSON.stringify(that.options))
                        error : (model, response) ->
                          console.log('card error callback')
                          console.log(JSON.stringify(response))
                          displayErrors($.parseJSON(response.responseText))
    })

  setCardFormVariables: ->
    @cardNumber = @$('input[name="number"]')
    @month = @$('input[name="exp_month"]')
    @year = @$('input[name="exp_year"]')
    @cvv = @$('input[name="cvv"]')


  cardFormSerializer: ->
    cardFormObject = {};
    cardNumber = @cardNumber.val().replace(/\s+/g,'')
    month = @month.val()
    year = "20" + @year.val()
    cvv =  @cvv.val()
    userId = @options.user.get("user").id
    console.log("userId:" + userId )

    cardFormObject = {
    "user_id": userId,
    "number":  cardNumber,
    "exp_month": month,
    "exp_year": year,
    "cvv": cvv
    }

    console.log cardFormObject
    cardFormObject

  isNumberKey: (evt) ->
    charCode = (if (evt.which) then evt.which else event.keyCode)
    return false  if charCode > 31 and (charCode < 48 or charCode > 57)
    @addSpaceToCardNumber()
    @cardNumber.popover({
                        'trigger': 'manual'
                        'placement': 'top',
                        'content': 'Please enter a valid Credit Card Number'
                        })
    if @cardNumber.val().length == 19
        if @checkLuhn()
          @cardNumber.parents(".control-group").addClass('success')
          @cardNumber.popover('hide')
        else
          @cardNumber.parents(".control-group").addClass('error')
          @cardNumber.popover('show')
    else
      @cardNumber.parents(".control-group").removeClass('success')
      @cardNumber.parents(".control-group").removeClass('error')
    true

  addSpaceToCardNumber: ->
    newValue = @cardNumber.val()
    if newValue.length is 4 or newValue.length is 9 or newValue.length is 14
      newValue = newValue + " "
    @cardNumber.val(newValue)

  checkLuhn: ->
    input = @cardNumber.val()
    input = input.replace(/[^\d]/g, '')
    console.log("checkLuhn")
    sum = 0
    numdigits = input.length
    parity = numdigits % 2
    i = 0

    while i < numdigits
      digit = parseInt(input.charAt(i),10)
      console.log(digit)
      digit *= 2  if i % 2 is parity
      digit -= 9  if digit > 9
      sum += digit
      i++
    console.log(sum)
    (sum % 10) is 0
