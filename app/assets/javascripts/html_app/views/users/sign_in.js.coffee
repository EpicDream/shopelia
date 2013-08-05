class Shopelia.Views.SignIn extends Shopelia.Views.Form

  template: 'users/sign_in'
  className: "box"
  ui: {
    email: 'input[name="email"]'
    password: 'input[name="password"]'
    validation: '#btn-login-user'
  }
  events:
    "click #btn-login-user": "onValidationClick"

  onRender: ->
    Tracker.onDisplay('Sign In');
    $(@el).fadeIn('slow')
    @initializeForm()

  onValidationClick: (e) ->
    e.preventDefault()
    userJson = @getFormResult()
    unless userJson is undefined
      Shopelia.vent.trigger("sign_in#login",userJson)

  getFormResult: ->
    if $('form').parsley( 'validate' )
       {
        "email": @ui.email.val(),
        "password": @ui.password.val()
       }
    else
      undefined

  setHeaderLink: (region) ->
    Shopelia.vent.trigger("header#set_header_link","Première Commande ?","sign_up#show",region)

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)

  onClose: ->
    $(@el).fadeOut('slow')
