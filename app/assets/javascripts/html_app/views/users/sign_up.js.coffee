class Shopelia.Views.SignUp extends Shopelia.Views.Layout

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
    @userFieldsView = new Shopelia.Views.UserFields()
    @addressFieldsView = new Shopelia.Views.AddressFields()
    @cardFieldsView = new Shopelia.Views.CardFields()
    console.log(@userFieldsView)
    @userFields.show(@userFieldsView)
    @addressFields.show(@addressFieldsView)
    @cardFields.show(@cardFieldsView)


  getFormResult: ->
    if @ui.form.parsley( 'validate' )
      user = @userFieldsView.getFormResult()
      address = new Shopelia.Models.Address(@addressFieldsView.getFormResult())
      address.set("phone",user.phone)
      card = new Shopelia.Models.PaymentCard(@cardFieldsView.getFormResult())
      {
        "user":{
          "first_name": address.get("first_name"),
          "last_name":  address.get("last_name"),
          "email": user.email,
          "addresses_attributes": [address]
          "payment_cards_attributes": [card.disableWrapping()]
        }
      }
    else
      undefined


  onValidationClick: (e) ->
    e.preventDefault()
    session = @getFormResult()
    unless session is undefined
      Shopelia.vent.trigger("sign_up#create_user",session)


  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)