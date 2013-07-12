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
    console.log(@password)
    unless @options.email is undefined
      @email.val(@options.email)

  loginUser: (e) ->
    console.log("trigger loginUser")
    console.log(@options.session)
    if $('form').parsley( 'validate' )
      disableButton($("#btn-login-user"))
      eraseErrors()
      e.preventDefault()
      that = this
      session = @options.session
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
          that.parent.setContentView(new Shopelia.Views.OrdersIndex(session: that.options.session,product: that.options.product))
        error : (response) ->
          console.log("callback error login")
          enableButton($("#btn-login-user"))
          console.log(JSON.stringify(response.responseText))
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

  InitializeActionButton: (element) ->
    element.text("Première Commande ?")

  onActionClick: (e) ->
    @parent.setContentView(new Shopelia.Views.UsersIndex(session: @options.session,product: @options.product))
