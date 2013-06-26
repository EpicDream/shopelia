class Shopelia.Models.Session extends Backbone.Model
  urlRoot: "/api/users"

  validate: (attrs) ->
    user = new Shopelia.Models.User()
    errors = user.validate(attrs.user)
    errors