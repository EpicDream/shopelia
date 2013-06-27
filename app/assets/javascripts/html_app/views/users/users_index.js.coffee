class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click button": "createUser"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    console.log(@options.product)
    @addressView =  new Shopelia.Views.AddressesIndex()
    #@paymentCardView =  new Shopelia.Views.PaymentCardsIndex()
    @$("button").before(@addressView.render().el)
    #$(@addressView.render().el).after(@paymentCardView.render().el)
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
    if @paymentCardView == undefined
      cardIsValid = true
      sessionJson = @formSerializer(address,card)
    else
      card = @paymentCardView.setPaymentCard()
      cardIsValid = card.isValid()
      sessionJson = @formSerializer(address,card.disableWrapping())

    session.set(sessionJson)
    sessionIsValid = session.isValid()
    addressIsValid = address.isValid()

    console.log("Addresss MAAAAAN" + JSON.stringify(address))
    if cardIsValid && addressIsValid && sessionIsValid
      session.save(sessionJson,{
                                success : (resp) ->
                                  console.log('success callback')
                                  console.log("response user save: " + JSON.stringify(resp))
                                  that.goToOrdersIndex(resp)
                                error : (model, response) ->
                                  console.log(JSON.stringify(response))
                                  displayErrors($.parseJSON(response.responseText))

      })

  goToOrdersIndex: (session) ->
    view = new Shopelia.Views.OrdersIndex(session: session, product: @options.product)
    $('#modal-right').html(view.render().el)

  goToPaymentCardStep: (session) ->
    view = new Shopelia.Views.PaymentCardsIndex(product:@options.product,user: session )
    $('#modal-right').html(view.render().el)

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


