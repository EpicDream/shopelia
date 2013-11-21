class Shopelia.Views.SignUp extends Shopelia.Views.Form

  template: 'users/sign_up'
  className: "box"
  regions: {
    userFields: "#user-fields",
    addressFields: "#address-fields",
  }

  ui: {
    validation: "#btn-register-user"
    form: 'form'
  }

  events:
    "click #btn-register-user": "onValidationClick"

  onRender: ->
    Tracker.onDisplay('Sign Up');
    #console.log(@getProduct())
    $(@el).fadeIn('slow')
    @userFieldsView = new Shopelia.Views.UserFields()
    @addressFieldsView = new Shopelia.Views.AddressFields()

    @userFields.show(@userFieldsView)
    @addressFields.show(@addressFieldsView)
    @initializeForm({'security':true})

  getUserFromForm: ->
    if @ui.form.parsley( 'validate' )
      userJson = @userFieldsView.getFormResult()
      address = new Shopelia.Models.Address(@addressFieldsView.getFormResult())
      address.set("phone",userJson.phone)


      user = new Shopelia.Models.User({
                                      "email": userJson.email,
                                      "first_name": address.get("first_name"),
                                      "last_name":  address.get("last_name"),
                                      })
      user.get('addresses').add(address)
      user
    else
      undefined


  onValidationClick: (e) ->
    e.preventDefault()
    user = @getUserFromForm()
    unless user is undefined
      Shopelia.vent.trigger("sign_up#create",user)

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)

  onClose: ->
    $(@el).fadeOut('slow')