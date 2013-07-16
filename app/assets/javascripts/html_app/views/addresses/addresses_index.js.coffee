class Shopelia.Views.AddressesIndex extends Shopelia.Views.Form

  template: JST['addresses/index']

  events:
    "keypress input[name='address1']": "getLocation"
    "change input[name='address1']": "eraseAddressFields"

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template())
    @setFormVariables()
    @country.autocomplete({
                          source: _.values(countries),
                          });
    Shopelia.Views.Form.prototype.render.call(this)
    this

  setFormVariables: ->
    @address1 = @$('input[name="address1"]')
    @zip = @$('input[name="zip"]')
    @city = @$('input[name="city"]')
    @country = @$('input[name="country"]')
    @address2 = @$('input[name="address2"]')

  setAddress: ->
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
                first_name:  split($('input[name="full_name"]').val())[0],
                last_name:   split($('input[name="full_name"]').val())[1],
                phone: $('input[name="phone"]').val(),
                address1: @address1.val(),
                zip:@zip.val(),
                city: @city.val(),
                country: country_iso,
                address2: @address2.val()
                })
    address

  eraseAddressFields: ->
    console.log("eraseAddressFields")
    @zip.val("")
    @city.val("")
    @country.val("")

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
                 xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
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
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             console.log("second query for places:" +  JSON.stringify(data))
             that.populateAddressFields(data)
           error: (jqXHR,textStatus,errorThrown) ->
             console.log("error second query for places")
             console.log(JSON.stringify(errorThrown))
           });

  populateAddressFields: (address) ->
    @eraseAddressFields()
    @address1.val(address.address1).parsley( 'validate' )
    @zip.val(address.zip).parsley( 'validate' )
    @city.val(address.city).parsley( 'validate' )
    @country.val(countries[address.country]).parsley( 'validate' )

