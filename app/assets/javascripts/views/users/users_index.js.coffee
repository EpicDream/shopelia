class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click button": "createUser"
    "keypress input[name='address1']": "getLocation"
    "keydown input[name='address1']": "eraseAddressFields"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    @setFormVariables()
    @country.autocomplete({
      source: _.values(countries),
    });
    console.log(@collection.fetch())
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
    e.preventDefault()
    userJson = @formSerializer()
    that = this
    user = new Shopelia.Models.User()
    user.on("invalid", (model, errors) ->
       displayErrors(errors)
    )

    user.save(userJson,{
                              success : (resp) ->
                                console.log('success callback')
                                console.log("response user save:" + JSON.stringify(resp))
                                that.goToPaymentCardStep(resp)
                              error : (model, response) ->
                                console.log(JSON.stringify(response))
                                displayErrors($.parseJSON(response.responseText))

    })

  eraseAddressFields: ->
    console.log("je v enlver le gras")
    @zip.val("")
    @city.val("")
    @country.val("")



  goToPaymentCardStep: (user) ->
    view = new Shopelia.Views.PaymentCardsIndex(user: user )
    $('#container').html(view.render().el)

  getLocation: ->
    if (navigator.geolocation)
      navigator.geolocation.getCurrentPosition(@showPosition)
    else
      x.innerHTML="Geolocation is not supported by this browser."

  showPosition: (position) ->
    lat = position.coords.latitude.toString()
    lng = position.coords.longitude.toString()
    input = @address1
    that = this
    placesData = {}
    input.typeahead(
      source: (query, process) ->
        $.ajax({
               url: 'api/places/autocomplete',
               data: "query=" + query + "&lat=" + lat + "&lng=" + lng,
               dataType: 'json',
               contentType: 'application/json'
               beforeSend: (xhr) ->
                 xhr.setRequestHeader("Accept","application/json")
                 xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
                 xhr.setRequestHeader("X-Shopelia-ApiKey","52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4")
               success: (data,textStatus,jqXHR) ->
                 console.log(data)
                 placesData = data
                 places = _.pluck(data, "description")
                 process(places)
               error: (jqXHR,textStatus,errorThrown) ->
                 console.log('error places callback')
                 console.log(JSON.stringify(errorThrown))
               });
      updater: (selection) ->
        selectedPlace = _.first(_.where(placesData, { description : selection}))
        that.getFullAddress(selectedPlace["reference"])
        selection

    );

  getFullAddress: (reference) ->
    that = this
    $.ajax({
           url: 'api/places/details/' + reference,
           dataType: 'json',
           contentType: 'application/json'
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey","52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4")
           success: (data,textStatus,jqXHR) ->
             console.log("second query for places:" +  JSON.stringify(data))
             that.populateAddressFields(data)
           error: (jqXHR,textStatus,errorThrown) ->
             console.log("error second query for places")
             console.log(JSON.stringify(errorThrown))
           });

  populateAddressFields: (address) ->
    console.log("lalal" + address)
    @address1.val(address.address1)
    @zip.val(address.zip)
    @city.val(address.city)
    @country.val(countries[address.country])

  formSerializer: ->
    loginFormObject = {};
    fullName = @fullName.val()
    firstName =  @split(fullName)[0]
    lastName =  @split(fullName)[1]
    email = @email.val()
    phone = @phone.val()
    address1 = @address1.val()
    zip = @zip.val()
    city = @city.val()
    country = @country.val()
    address2 = @address2.val()

    _.each(countries, (value,key) ->
      if(value.toLowerCase()  == country.toLowerCase())
        country = key
    )

    loginFormObject = {
    "first_name": firstName,
    "last_name":  lastName,
    "email": email,
    "addresses_attributes":
      [{
       "first_name": firstName,
       "last_name":  lastName,
       "phone": phone,
       "address1": address1,
       "zip":zip,
       "city": city,
       "country": country,
       "address2": address2
       }]
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
