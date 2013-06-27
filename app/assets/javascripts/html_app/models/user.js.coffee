class Shopelia.Models.User extends Backbone.Model
  name: "user"
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

    console.log(_.size(errors))
    if _.size(errors) > 0
      errors
