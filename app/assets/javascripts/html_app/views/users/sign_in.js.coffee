class Shopelia.Views.SignIn extends Shopelia.Views.Form

  template: JST['users/sign_in']
  className: "box"
  events:
    "click #btn-login-user": "loginUser"

  initialize: ->
    Shopelia.Views.Form.prototype.initialize.call(this)


  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Sign In');
    @setFormVariables()
    @parent.setHeaderLink("Première Commande ?",@onActionClick)
    Shopelia.Views.Form.prototype.render.call(this)
    this

  setFormVariables: ->
    @email = @$('input[name="email"]')
    @password = @$('input[name="password"]')
    unless @options.email is undefined
      @email.val(@options.email)

  loginUser: (e) ->
    #console.log("trigger loginUser")
    #console.log(@options.session)
    if $('form').parsley( 'validate' )
      disableButton($("#btn-login-user"))
      eraseErrors()
      e.preventDefault()
      that = this
      session = @getSession()
      session.on("invalid", (model, errors) ->
        displayErrors(errors)
      )
      sessionJson = @formSerializer()
      session.login(sessionJson,{
        success : (resp) ->
          #console.log('login success callback')
          #console.log("response login success: " + JSON.stringify(resp))
          session.set(resp)
          session.saveCookies(session)
          that.parent.setContentView(new Shopelia.Views.OrdersIndex(parent:that))
        error : (response) ->
          #console.log("callback error login")
          enableButton($("#btn-login-user"))
          #console.log(JSON.stringify(response.responseText))
          displayErrors($.parseJSON(response.responseText))

      })


  formSerializer: ->
    email = @email.val()
    password = @password.val()
    loginFormObject = {
      "email": email,
      "password": password
    }
    #console.log loginFormObject
    loginFormObject

  onActionClick: (e) ->
    #console.log("sign in action click")
    #console.log(@parent)
    @parent.setContentView(new Shopelia.Views.UsersIndex(email:@email.val()))
