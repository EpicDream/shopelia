class Shopelia.Models.User extends Backbone.Model
  urlRoot: "/api/users",

  validate: (attrs) ->
    email_filter = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

    errors = {}
    if(!email_filter.test(attrs.user.email))
      errors["email"] = "email invalid"

    if(attrs.user.email.length == 0)
      console.log("email required")
      errors["email"] = "email required"

    if(attrs.user.first_name.length == 0)
      console.log("first name required")
      errors["first_name"] = "first name required"

    if(attrs.user.last_name.length == 0)
      console.log("last name required")
      errors["last_name"] ="last name required"

    if(attrs.user.addresses_attributes[0].phone.length == 0)
      console.log("phone required")
      errors["phone"] = "phone required"

    if(attrs.user.addresses_attributes[0].reference == undefined || attrs.user.addresses_attributes[0].reference.length == 0)
      console.log("reference required")
      errors["reference"] = "address is required"

    console.log(_.size(errors))
    if _.size(errors) > 0
      console.log(errors)
      errors
