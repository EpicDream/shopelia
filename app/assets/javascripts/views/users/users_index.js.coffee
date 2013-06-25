class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']

  events:
    "click button": "createUser"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    console.log(@options.product)
    productView = new Shopelia.Views.ProductsIndex(model:@options.product)
    @$("form").before(productView.render().el)
    addressView =  new Shopelia.Views.AddressesIndex()
    @$("button").before(addressView.render().el)
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
    user = new Shopelia.Models.User()
    user.on("invalid", (model, errors) ->
       displayErrors(errors)
    )

    country_iso =  @country.val()
    _.each(countries, (value,key) ->
      if(value.toLowerCase()  == country_iso.toLowerCase())
        country_iso = key
    )

    address = new Shopelia.Models.Address()
    address.on("invalid", (model, errors) ->
      console.log("displaying address Errors" + JSON.stringify(errors))
      displayErrors(errors)
    )
    address.set({
                 first_name:  @split(@fullName.val())[0],
                 last_name:   @split(@fullName.val())[1],
                 phone: @phone.val(),
                 address1: @address1.val(),
                 zip:@zip.val(),
                 city: @city.val(),
                 country: country_iso,
                 address2: @address2.val()
                 })
    userJson = @formSerializer(address)
    user.set({user: userJson})
    userIsValid = user.isValid()
    console.log("Addresss MAAAAAN" + JSON.stringify(address))
    if address.isValid() && userIsValid
      user.save({user: userJson},{
                                success : (resp) ->
                                  console.log('success callback')
                                  console.log("response user save:" + JSON.stringify(resp))
                                  that.goToPaymentCardStep(resp)
                                error : (model, response) ->
                                  console.log(JSON.stringify(response))
                                  displayErrors($.parseJSON(response.responseText))

      })

  goToPaymentCardStep: (user) ->
    view = new Shopelia.Views.PaymentCardsIndex(product:@options.product,user: user )
    $('#container').html(view.render().el)

  formSerializer: (address)->
    loginFormObject = {};
    fullName = @fullName.val()
    firstName =  @split(fullName)[0]
    lastName =  @split(fullName)[1]
    email = @email.val()

    loginFormObject = {
    "first_name": firstName,
    "last_name":  lastName,
    "email": email,
    "addresses_attributes": [address]
    }

    console.log loginFormObject
    loginFormObject

  split: (fullName) ->
    firstName =  fullName.substr(0,fullName.indexOf(' '))
    lastName =  fullName.substr(fullName.indexOf(' ')+1)
    if firstName == ''
      [lastName,'']
    else
      [firstName,lastName]
