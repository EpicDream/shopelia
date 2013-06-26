class Shopelia.Models.Address extends Backbone.Model

  validate: (attrs) ->
    errors = {}
    if(attrs.phone.length == 0)
      errors["phone"] = "phone required"
    if(attrs.address1.length == 0)
      errors["address1"] = "address is required"
    if(attrs.zip.length == 0)
      errors["zip"] = "zip is required"
    if(attrs.country == undefined || attrs.country.length == 0)
      errors["country"] = "country is required"
    if(attrs.city.length == 0)
      errors["city"] = "city is required"

    if _.size(errors) > 0
      console.log("Validation errors for Address : " + JSON.stringify(errors))
      errors