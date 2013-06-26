class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']

  events:
    "click button": "createUser"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    console.log(@options.product)
    @productView = new Shopelia.Views.ProductsIndex(model:@options.product)
    @addressView =  new Shopelia.Views.AddressesIndex()
    @paymentCardView =  new Shopelia.Views.PaymentCardsIndex()
    @$("form").before(@productView.render().el)
    @$("button").before(@addressView.render().el)
    $(@addressView.render().el).after(@paymentCardView.render().el)
    @setFormVariables()
    @country.autocomplete({
      source: _.values(countries),
    });
    this

  setFormVariables: ->
    @fullName = @$('input[name="full_name"]')
    @email = @$('input[name="email"]')
    @phone = @$('input[name="phone"]')
    @address1 = @$('input[name="address1"]')
    @zip = @$('input[name="zip"]')
    @city = @$('input[name="city"]')
    @country = @$('input[name="country"]')
    @address2 = @$('input[name="address2"]')

  createUser: (e) ->
    console.log("trigger createUser")
    eraseErrors()
    e.preventDefault()
    that = this
    session = new Shopelia.Models.Session()
    session.on("invalid", (model, errors) ->
       displayErrors(errors)
    )
    card = @paymentCardView.setPaymentCard()
    address = @addressView.setAddress()
    sessionJson = @formSerializer(address,card)
    session.set(sessionJson)
    sessionIsValid = session.isValid()
    addressIsValid = address.isValid()
    cardIsValid = card.isValid()
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
    view = new Shopelia.Views.OrdersIndex(session: @session)
    $('#container').html(view.render().el)

  goToPaymentCardStep: (user) ->
    view = new Shopelia.Views.PaymentCardsIndex(product:@options.product,user: user )
    $('#container').html(view.render().el)

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
        "payment_cards_attributes": [card.disableWrapping()]
      }
    }

    console.log loginFormObject
    loginFormObject


