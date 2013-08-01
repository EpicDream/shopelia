class Shopelia.Views.SignUp extends Shopelia.Views.Layout

  template: 'users/sign_up'
  className: "box"
  regions: {
    userFields: "#user-fields",
    addressFields: "#address-fields",
    cardFields: "#card-fields"
  }

  events:
    "click #btn-register-user": "createUser"

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



  setFormVariables: ->
    @fullName = @$('input[name="full_name"]')
    @email = @$('input[name="email"]')
    that = this
    @email.focusout(() ->
      if that.email.parsley("validate")
        that.verifyEmail(that.email.val())
    )
    unless @options.email is undefined
      @email.val(@options.email)

  verifyEmail: (email) ->
    that = this
    $.ajax({
           type: 'POST'
           url: 'api/users/exists',
           data: {'email': email},
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             that.parent.setContentView(new Shopelia.Views.SignIn(email:email))
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log("user dosn't exist")
             #console.log(JSON.stringify(errorThrown))
           });


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

