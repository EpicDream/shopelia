class Shopelia.Views.UserFields extends Shopelia.Views.ShopeliaView

  template: 'users/user_fields'
  ui: {
    email: 'input[name="email"]'
    phone: 'input[name="phone"]'
  }
  events:
    "click #btn-register-user": "createUser"

  onRender: ->
    that = this
    @ui.email.focusout(() ->
      if that.ui.email.parsley("validate")
        Shopelia.vent.trigger("sign_up#verify_email",that.ui.email.val())
    )
    #unless @options.email is undefined
    #  @email.val(@options.email)

  getFormResult: ->
    {
      email: @ui.email.val()
      phone: @ui.phone.val()
    }



