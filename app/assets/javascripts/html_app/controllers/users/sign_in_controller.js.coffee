class Shopelia.Controllers.SignInController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show: (region,email) ->
    if email
      user = new Shopelia.Models.User(email: email)
    else
      user = @getSession().get('user')
    @view = new Shopelia.Views.SignIn(model: user)
    region.show(@view)
    @pushHeaderLink("sign_up#show","Première Commande ?",region)


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
          Shopelia.vent.trigger("modal_content#order")
        error : (response) ->
          #console.log("callback error login")
          that.view.unlockView()
          displayErrors($.parseJSON(response.responseText))
          #Shopelia.Notification.Error({ text: $.parseJSON(response.responseText)['error'] })
      })
    else
      console.log("userJson is undefined in sign_in controller")

