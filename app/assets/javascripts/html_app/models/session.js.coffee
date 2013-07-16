class Shopelia.Models.Session extends Backbone.Model
  urlRoot: "/api/users"
  defaults:
    auth_token: null,
    user: null

  initialize: ->
    @load()

  authenticated: ->
    Boolean(@get("auth_token"))

  # Saves session information to cookie
  saveCookies: (session)->
    console.log("save cookies")
    console.log(session)
    $.cookie.json = true;
    $.cookie('auth_token', session.get("auth_token"))
    $.cookie('user', session.get("user"))

  updateCookies: (user) ->
    console.log("updating cookies")
    $.cookie.json = true;
    $.cookie('user', user)

  deleteCookies: ->
    console.log("deleting cookies")
    $.removeCookie('auth_token')
    $.removeCookie('user')
    $.removeCookie('_shopelia_session')

  # Loads session information from cookie
  load: ->
    console.log("load")
    unless $.cookie('user') is undefined
      @set
        user: JSON.parse($.cookie('user'))
        auth_token: $.cookie('auth_token')

  login: (session,callbacks) ->
    console.log("In session login method")
    $.ajax({
           type: "POST",
           url: 'api/users/sign_in',
           data: session,
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: callbacks.success
           error: callbacks.error
           })