class Shopelia.Views.SignUp extends Shopelia.Views.Form

  template: 'users/sign_up'
  className: "box"
  regions: {
    userFields: "#user-fields",
    addressFields: "#address-fields",
    cardFields: "#card-fields"
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
    @cardFieldsView = new Shopelia.Views.CardFields()

    @userFields.show(@userFieldsView)
    @addressFields.show(@addressFieldsView)
    @cardFields.show(@cardFieldsView)
    @initializeForm()


  getUserFromForm: ->
    if @ui.form.parsley( 'validate' )
      userJson = @userFieldsView.getFormResult()
      address = new Shopelia.Models.Address(@addressFieldsView.getFormResult())
      address.set("phone",userJson.phone)
      card = new Shopelia.Models.PaymentCard(@cardFieldsView.getFormResult())

      user = new Shopelia.Models.User({
                                      "email": userJson.email,
                                      "first_name": address.get("first_name"),
                                      "last_name":  address.get("last_name"),
                                      })
      user.get('addresses').add(address)
      user.get("payment_cards").add(card.disableWrapping())
      console.log(user)
      user
    else
      undefined


  onValidationClick: (e) ->
    e.preventDefault()
    user = @getUserFromForm()
    unless user is undefined
      Shopelia.vent.trigger("sign_up#create",user)

  setHeaderLink: (region) ->
    Shopelia.vent.trigger("header#set_header_link","Déjà membre?","sign_in#show",region)

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)

  onClose: ->
    $(@el).fadeOut('slow')