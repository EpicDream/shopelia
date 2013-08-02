class Shopelia.Models.Session extends Backbone.RelationalModel
  urlRoot: "/api/users"
  relations: [{
              type: Backbone.HasOne,
              key: 'user',
              relatedModel: 'Shopelia.Models.User'
              }]
  defaults:
    auth_token: null,
    user: null

  initialize: ->
    @load()

  authenticated: ->
    Boolean(@get("auth_token"))

  # Saves session information to cookie
  saveCookies:(session) ->
    if session isnt undefined
      if session.user isnt undefined
        @user = new Shopelia.Models.User(session.user)
      if session.auth_token isnt undefined
        @auth_token = session.auth_token
    #console.log("save cookies")
    #console.log(this)
    $.cookie.json = true;
    $.cookie('session', this)

  updateUserCookies: (user) ->
    #console.log("updating cookies")
    $.cookie.json = true;
    @user = new Shopelia.Models.User(user)
    @saveCookies()

  deleteCookies: ->
    #console.log("deleting cookies")
    $.removeCookie('session')

  # Loads session information from cookie
  load: ->
    #console.log("load")
    $.cookie.json = true;
    session = $.cookie('session')
    unless session is undefined
      #console.log(session.user)
      @set
        user: new Shopelia.Models.User(session.user)
        auth_token: session.auth_token

    #console.log("load finished")
    #console.log(session)

  login: (session,callbacks) ->
    #console.log("In session login method")
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