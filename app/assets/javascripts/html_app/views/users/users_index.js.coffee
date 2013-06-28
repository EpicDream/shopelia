class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click #btn-register-user": "createUser"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    console.log(@options.product)
    @addressView =  new Shopelia.Views.AddressesIndex()
    @$("#btn-register-user").before(@addressView.render().el)
    @randomBool = !! Math.round(Math.random() * 1)
    if @randomBool
      @paymentCardView =  new Shopelia.Views.PaymentCardsIndex()
      $(@addressView.render().el).after(@paymentCardView.render().el)
    @setFormVariables()
    this

  setFormVariables: ->
    @fullName = @$('input[name="full_name"]')
    @email = @$('input[name="email"]')


  createUser: (e) ->
    console.log("trigger createUser")
    eraseErrors()
    e.preventDefault()
    that = this
    session = new Shopelia.Models.Session()
    session.on("invalid", (model, errors) ->
       displayErrors(errors)
    )

    address = @addressView.setAddress()
    card = null
    if @randomBool
      card = @paymentCardView.setPaymentCard()
      cardIsValid = card.isValid()
      sessionJson = @formSerializer(address,card.disableWrapping())
    else
      cardIsValid = true
      sessionJson = @formSerializer(address,card)


    session.set(sessionJson)
    sessionIsValid = session.isValid()
    addressIsValid = address.isValid()

    console.log("Addresss MAAAAAN" + JSON.stringify(address))
    if cardIsValid && addressIsValid && sessionIsValid
      session.save(sessionJson,{
                                success : (resp) ->
                                  console.log('success callback')
                                  console.log("response user save: " + JSON.stringify(resp))
                                  if that.randomBool
                                    goToOrdersIndex(resp,that.options.product)
                                  else
                                    goToPaymentCardStep(resp,that.options.product)
                                error : (model, response) ->
                                  console.log(JSON.stringify(response))
                                  displayErrors($.parseJSON(response.responseText))

      })




  formSerializer: (address,card)->
    loginFormObject = {};
    fullName = @fullName.val()
    firstName =  split(fullName)[0]
    lastName =  split(fullName)[1]
    email = @email.val()
    console.log("CARDDDDDDDDDDDD")
    console.log(card)
    loginFormObject = {
      "user":{
        "first_name": firstName,
        "last_name":  lastName,
        "email": email,
        "addresses_attributes": [address]
        "payment_cards_attributes": [card]
      }
    }

    console.log loginFormObject
    loginFormObject


