class Shopelia.Views.AddressFields extends Shopelia.Views.ShopeliaView

  template: 'addresses/address_fields'
  ui: {
    fullName: 'input[name="full_name"]'
    address1: 'input[name="address1"]'
    address2: 'input[name="address2"]'
    zip: 'input[name="zip"]'
    city: 'input[name="city"]'
    country: 'input[name="country"]'
  }

  events:
    "keypress input[name='address1']": "getLocation"

  onRender: ->
    @ui.country.autocomplete({
      source: _.values(countries),
    })
    @ui.country.data("inlist", _.values(countries).join(",").toLowerCase())

  getFormResult: ->
    {
      first_name:  split(@ui.fullName.val())[0],
      last_name:   split(@ui.fullName.val())[1],
      address1: @ui.address1.val(),
      address2: @ui.address2.val(),
      zip: @ui.zip.val(),
      city: @ui.city.val(),
      country_iso: @getCountryIso(@ui.country.val()),
    }

  getCountryIso : (country) ->
    country_iso = "XX"
    _.each(countries, (value,key) ->
      if(value.toLowerCase() == country.toLowerCase())
        country_iso = key
    )
    country_iso

  eraseAddressFields: ->
    @ui.zip.val("")
    @ui.city.val("")
    @ui.country.val("")

  getLocation: ->
    if (navigator.geolocation)
      navigator.geolocation.getCurrentPosition(@showPosition)
    else
      x.innerHTML="Geolocation is not supported by this browser."

  showPosition: (position) ->
    lat = position.coords.latitude.toString()
    lng = position.coords.longitude.toString()
    input = @ui.address1
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
                 #console.log(data)
                 placesData = data
                 places = _.pluck(data, "description")
                 process(places)
               error: (jqXHR,textStatus,errorThrown) ->
                 #console.log('error places callback')
                 #console.log(JSON.stringify(errorThrown))
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
             #console.log("second query for places:" +  JSON.stringify(data))
             that.populateAddressFields(data)
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log("error second query for places")
             #console.log(JSON.stringify(errorThrown))
           });

  populateAddressFields: (address) ->
    @eraseAddressFields()
    @ui.address1.val(address.address1).parsley( 'validate' )
    @ui.zip.val(address.zip).parsley( 'validate' )
    @ui.city.val(address.city).parsley( 'validate' )
    @ui.country.val(countries[address.country]).parsley( 'validate' )

