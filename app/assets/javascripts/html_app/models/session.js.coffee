class Shopelia.Models.Session extends Backbone.Model
  urlRoot: "/api/users"
  defaults:
    authToken: null,
    user: null

  initialize: ->
    @load()

  authenticated: ->
    Boolean(@get("authToken"))

  # Saves session information to cookie
  saveCookies: (session)->
    console.log("save cookies")
    console.log(session)
    $.cookie.json = true;
    $.cookie('authToken', session.get("auth_token"))
    $.cookie('user', session.get("user"))

  updateCookies: (user) ->
    console.log("updating cookies")
    $.cookie.json = true;
    $.cookie('user', user)

  deleteCookies: ->
    console.log("deleting cookies")
    $.removeCookie('authToken')
    $.removeCookie('user')
    $.removeCookie('_shopelia_session')

  # Loads session information from cookie
  load: ->
    console.log("load")
    unless $.cookie('user') is undefined
      @set
        user: JSON.parse($.cookie('user'))
        authToken: $.cookie('authToken')

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
             xhr.setRequestHeader("X-Shopelia-ApiKey","52953f1868a7545011d979a8c1d0acbc310dcb5a262981bd1a75c1c6f071ffb4")
           success: callbacks.success
           error: callbacks.error
           })