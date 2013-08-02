class Shopelia.Views.UserFields extends Shopelia.Views.Form

  template: 'users/user_fields'
  className: "box"
  ui: {
    email: 'input[name="email"]'
    phone: 'input[name="phone"]'
  }
  events:
    "click #btn-register-user": "createUser"

  initialize: ->
    Shopelia.Views.Form.prototype.initialize.call(this)

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

  setFormVariables: ->
    @email = @$('input[name="email"]')
    that = this
    @email.focusout(() ->
      if that.email.parsley("validate")
        that.verifyEmail(that.email.val())
    )
    unless @options.email is undefined
      @email.val(@options.email)

  createUser: (e) ->
    #console.log("trigger createUser")
    if $('form').parsley( 'validate' )
      disableButton($("#btn-register-user"))
      eraseErrors()
      e.preventDefault()
      that = this
      session = @getSession()
      session.on("invalid", (model, errors) ->
        displayErrors(errors)
      )

      address = @addressView.setAddress()
      card = null
      card = @paymentCardView.setPaymentCard()
      sessionJson = @formSerializer(address,card.disableWrapping())

      session.set(sessionJson)

      #console.log("Addresss MAAAAAN" + JSON.stringify(address))
      session.save(sessionJson,{
      success : (resp) ->
        #console.log('success callback')
        #console.log("response user save: " + JSON.stringify(resp))
        session.saveCookies(resp)
        that.parent.addPasswordView()
        that.parent.setContentView(new Shopelia.Views.OrdersIndex(parent: that))
      error : (model, response) ->
        #console.log(JSON.stringify(response))
        enableButton($("#btn-register-user"))
        displayErrors($.parseJSON(response.responseText))

      })




  formSerializer: (address,card)->
    loginFormObject = {};
    fullName = @fullName.val()
    firstName =  split(fullName)[0]
    lastName =  split(fullName)[1]
    email = @email.val()
    #console.log("CARDDDDDDDDDDDD")
    #console.log(card)
    loginFormObject = {
    "user":{
    "first_name": firstName,
    "last_name":  lastName,
    "email": email,
    "addresses_attributes": [address]
    "payment_cards_attributes": [card]
    }
    }

    #console.log loginFormObject
    loginFormObject

  onActionClick: (e) ->
    #console.log("users index action click")
    @parent.setContentView(new Shopelia.Views.SignIn(email: @email.val()))

