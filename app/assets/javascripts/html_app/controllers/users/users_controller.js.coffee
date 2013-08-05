class Shopelia.Controllers.UsersController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  update: (params) ->
    console.log("updating user")
    session = @getSession()
    authToken = session.get("auth_token")
    user = session.get("user")
    console.log(user)
    that = this
    user.update(params,{
                beforeSend: (xhr) ->
                  xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                success : (resp) ->
                  Shopelia.vent.trigger("thank_you#password_updated")
                error : (model, response) ->
                  console.log("deleting cookies")
                  session.deleteCookies()
                })