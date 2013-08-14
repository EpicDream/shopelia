class Shopelia.Views.NewPassword extends Shopelia.Views.Form

  template: 'users/new_password'
  className: 'box new_password'
  ui: {
    password: 'input[name="password"]'
    validation: "button"
  }

  events:
    "click button": "onValidationClick"


  onRender: ->
    Tracker.onDisplay('Password');

  onValidationClick: (e) ->
    e.preventDefault()
    Shopelia.vent.trigger("users#update",@getFormResult())

  getFormResult : ->
    console.log(@ui.password)
    {
      "password": @ui.password.val(),
      "password_confirmation":  @ui.password.val()
    }

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)


