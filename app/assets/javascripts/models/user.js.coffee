class Shopelia.Models.User extends Backbone.Model
  paramRoot: "user",
  urlRoot: "/api/users"

  validate: (attrs) ->
    email_filter = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

    errors = {}
    if(!email_filter.test(attrs.email))
      errors["email"] = "email invalid"

    if(attrs.email.length == 0)
      errors["email"] = "email required"

    if(attrs.first_name.length == 0)
      errors["first_name"] = "first name required"

    if(attrs.last_name.length == 0)
      errors["last_name"] ="last name required"

    if(attrs.addresses_attributes[0].phone.length == 0)
      errors["phone"] = "phone required"

    if(attrs.addresses_attributes[0].address1.length == 0)
       errors["address1"] = "address is required"
    if(attrs.addresses_attributes[0].zip.length == 0)
      errors["zip"] = "zip is required"
    if(attrs.addresses_attributes[0].country == undefined || attrs.addresses_attributes[0].country.length == 0)
      errors["country"] = "country is required"
    if(attrs.addresses_attributes[0].city.length == 0)
      errors["city"] = "city is required"


    console.log(_.size(errors))
    if _.size(errors) > 0
      console.log(errors)
      errors
