class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click button": "createUser"
    "keypress input[name='address1']": "getLocation"

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    @$('input[name="country"]').autocomplete({
      source: _.values(countries),
      select: ( event, ui ) ->
        _.each(countries, (value,key) ->
          if(value.toLowerCase()  == ui.item.label.toLowerCase())
            @$('input[name="country"]').attr("country_code",key)
        )
    });
    console.log(@collection)
    this

  createUser: (e) ->
    console.log("trigger createUser")
    e.preventDefault()
    userJson = @formSerializer()
    that = this
    user = new Shopelia.Models.User()
    user.on("invalid", (model, errors) ->
       that.displayErrors(errors)
    )

    user.save({"user": userJson},{
                              success : (resp) ->
                                console.log('success callback')
                                console.log(resp)
                                that.goToPaymentCardStep(model:user)
                              error : (model, response) ->
                                that.displayErrors($.parseJSON(response.responseText))

    })


  displayErrors: (errors) ->
    @eraseErrors()
    keys = _.keys(errors)
    console.log(errors)
    that = this
    _.each(keys,(key) ->
      if (key == "base")
        errorField =  that.$("input[name=address1]")
      else if  (key == "first_name" || key == "last_name")
        errorField =  that.$("input[name=full_name]")
      else
        errorField =  that.$("input[name=" + key + "]")

      errorField.parents(".control-group").addClass('error')
      errorField.popover({
                         'trigger' : 'focus',
                         'placement': 'top',
                         'content': errors[key]
                         })
    )

  eraseErrors: ->
    $(".control-group").removeClass('error')
    $('.help-inline').remove()



  goToPaymentCardStep: (user) ->
    view = new Shopelia.Views.PaymentCardsIndex(model:user )
    $('#container').html(view.render().el)

  getLocation: ->
    if (navigator.geolocation)
      navigator.geolocation.getCurrentPosition(@showPosition)
    else
      x.innerHTML="Geolocation is not supported by this browser."

  showPosition: (position) ->
    lat = position.coords.latitude.toString()
    lng = position.coords.longitude.toString()
    input = @$('input[name="address1"]')
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
        $.ajax({
               url: 'api/places/details/' + selectedPlace["reference"],
               dataType: 'json',
               contentType: 'application/json'
               beforeSend: (xhr) ->
                 xhr.setRequestHeader("Accept","application/json")
                 xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
                 xhr.setRequestHeader("X-Shopelia-ApiKey","52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4")
               success: (data,textStatus,jqXHR) ->
                 console.log("second query for places:" +  JSON.stringify(data))
                 placesData = data
               error: (jqXHR,textStatus,errorThrown) ->
                 console.log("error second query for places")
                 console.log(JSON.stringify(errorThrown))
               });
        selection

    );

  formSerializer: ->
    loginFormObject = {};
    fullName = @$('input[name="full_name"]').val()
    firstName =  @split(fullName)[0]
    lastName =  @split(fullName)[1]
    email = @$('input[name="email"]').val()
    phone = @$('input[name="phone"]').val()
    address1 = @$('input[name="address1"]').val()
    zip = @$('input[name="zip"]').val()
    city = @$('input[name="city"]').val()
    country = @$('input[name="country"]').attr("country_code")
    address2 = @$('input[name="address2"]').val()

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
