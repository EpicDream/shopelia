class Shopelia.Controllers.SignInController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.SignIn()
    region.show(@view)
    @view.setHeaderLink(region)

  login: (userJson) ->
    console.log("trigger login")
    that = this
    if userJson isnt undefined
      @view.lockView()
      session = @getSession()
      session.login(userJson,{
        success : (resp) ->
          #console.log('login success callback')
          #console.log("response login success: " + JSON.stringify(resp))
          session.set(resp)
          session.saveCookies(session)
          Shopelia.vent.trigger("modal#order")
        error : (response) ->
          #console.log("callback error login")
          that.view.unlockView()
          #TODO display errors
          #console.log(JSON.stringify(response.responseText))
      })
    else
      console.log("userJson is undefined in sign_in controller")

