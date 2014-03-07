class Shopelia.Views.CardFields extends Shopelia.Views.Form

  template: 'payment_cards/card_fields'
  className: 'paiement-view box'
  ui: {
    cardNumber: 'input[name="number"]'
    date: 'input[name="exp_date"]'
    cvv: 'input[name="cvv"]'
    validation: "#btn-register-payment"
  }
  events:
    'keydown input[name="number"]':'addSpaceToCardNumber'
    'keyup input[name="number"]': 'addCardType'
    'keyup input[name="exp_date"]': "formatExpDate"
    "click #btn-register-payment": "onValidationClick"


  onRender: ->
    Tracker.onDisplay('Add Payment Card');
    $(@el).fadeIn('slow')
    @initializeForm({'security':true})

  getFormResult: ->
    cardFormObject = {};
    cardNumber = @ui.cardNumber.val().replace(/\s+/g,'')
    date = @ui.date.val()
    month = date.substr(0,date.indexOf('/'))
    year = date.substr(date.indexOf('/')+1)
    year = "20" + year
    cvv =  @ui.cvv.val()

    cardFormObject = {
      "number":  cardNumber,
      "exp_month": month,
      "exp_year": year,
      "cvv": cvv
    }
    #if @getSession().authenticated()
    #  userId = @getSession().get("user").id
    #  cardFormObject["user_id"] =  userId
    cardFormObject

  onValidationClick: (e) ->
    e.preventDefault()
    if $('form').parsley( 'validate' )
      e.preventDefault()
      disableButton($("#btn-register-payment"))
      card = new Shopelia.Models.PaymentCard(@getFormResult())
      card.on("invalid", (model, errors) ->
        displayErrors(errors)
      )
      Shopelia.vent.trigger("payment#create",card)

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)

  addCardType: ->
    #console.log(@ui.cardNumber.val().charAt(0))
    if @ui.cardNumber.val().length > 2
      if  @ui.cardNumber.val().charAt(0) == "3"
        @ui.cardNumber.removeClass("visa")
        @ui.cardNumber.addClass("amex")
        @ui.cardNumber.removeClass("mastercard")
      else if @ui.cardNumber.val().charAt(0) == "4"
        @ui.cardNumber.addClass("visa")
        @ui.cardNumber.removeClass("amex")
        @ui.cardNumber.removeClass("mastercard")
      else if @ui.cardNumber.val().charAt(0) == "5"
        @ui.cardNumber.removeClass("visa")
        @ui.cardNumber.removeClass("amex")
        @ui.cardNumber.addClass("mastercard")
    else
      @ui.cardNumber.removeClass("visa")
      @ui.cardNumber.removeClass("amex")
      @ui.cardNumber.removeClass("mastercard")


  addSpaceToCardNumber: ->
    newValue = @ui.cardNumber.val()
    if (newValue.length is 4 or newValue.length is 9 or newValue.length is 14) and event.keyCode != 8
      newValue = newValue + " "
      @ui.cardNumber.val(newValue)

  formatExpDate: (e) ->
    if @ui.date.val().length == 2 && e.keyCode != 8
      newValue = @ui.date.val()
      newValue = newValue + "/"
      @ui.date.val(newValue)

