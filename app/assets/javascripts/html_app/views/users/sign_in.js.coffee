class Shopelia.Views.SignIn extends Shopelia.Views.Form

  template: JST['users/sign_in']
  events:
    "click #btn-login-user": "loginUser"

  initialize: ->
    _.bindAll this



  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Sign In');
    @setFormVariables()
    Shopelia.Views.Form.prototype.render.call(this)
    this

  setFormVariables: ->
    @email = @$('input[name="email"]')
    @password = @$('input[name="password"]')

  loginUser: (e) ->
    console.log("trigger loginUser")
    if $('form').parsley( 'validate' )
      #@$("#btn-login-user").attr('disabled', 'disabled');
      eraseErrors()
      e.preventDefault()
      that = this
      session = new Shopelia.Models.Session()
      session.on("invalid", (model, errors) ->
        displayErrors(errors)
      )
      sessionJson = @formSerializer()
      session.login(sessionJson,{
        success : (resp) ->
          console.log('login success callback')
          console.log("response login success: " + JSON.stringify(resp))
          session.set(resp)
          session.saveCookies(session)
          goToOrdersIndex(session,that.options.product)
        error : (model, response) ->
          console.log("callback error login")
          console.log(JSON.stringify(response))
          displayErrors($.parseJSON(response.responseText))

      })




  formSerializer: ->
    email = @email.val()
    password = @password.val()
    loginFormObject = {
      "email": email,
      "password": password
    }
    console.log loginFormObject
    loginFormObject