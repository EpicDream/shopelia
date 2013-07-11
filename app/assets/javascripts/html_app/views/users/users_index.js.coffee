class Shopelia.Views.UsersIndex extends Shopelia.Views.Form

  template: JST['users/index']
  events:
    "click #btn-register-user": "createUser"

  initialize: ->
    _.bindAll this



  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Sign Up');
    console.log(@options.product)
    @addressView =  new Shopelia.Views.AddressesIndex()
    @$("#btn-register-user").before(@addressView.render().el)
    @randomBool = true #!! Math.round(Math.random() * 1)
    if @randomBool
      @paymentCardView =  new Shopelia.Views.PaymentCardsIndex()
      $(@addressView.render().el).after(@paymentCardView.render().el)
    @setFormVariables()
    Shopelia.Views.Form.prototype.render.call(this)
    this

  setFormVariables: ->
    @fullName = @$('input[name="full_name"]')
    @email = @$('input[name="email"]')


  createUser: (e) ->
    console.log("trigger createUser")
    if $('form').parsley( 'validate' )
      @$("#btn-register-user").attr('disabled', 'disabled');
      eraseErrors()
      e.preventDefault()
      that = this
      session = new Shopelia.Models.Session()
      session.on("invalid", (model, errors) ->
         displayErrors(errors)
      )

      address = @addressView.setAddress()
      card = null
      if @randomBool
        card = @paymentCardView.setPaymentCard()
        sessionJson = @formSerializer(address,card.disableWrapping())
      else
        sessionJson = @formSerializer(address,card)

      session.set(sessionJson)

      console.log("Addresss MAAAAAN" + JSON.stringify(address))
      session.save(sessionJson,{
                                success : (resp) ->
                                  console.log('success callback')
                                  console.log("response user save: " + JSON.stringify(resp))
                                  session.saveCookies(resp)
                                  if that.randomBool
                                    goToOrdersIndex(resp,that.options.product)
                                  else
                                    goToPaymentCardStep(resp,that.options.product)
                                error : (model, response) ->
                                  console.log(JSON.stringify(response))
                                  displayErrors($.parseJSON(response.responseText))

      })




  formSerializer: (address,card)->
    loginFormObject = {};
    fullName = @fullName.val()
    firstName =  split(fullName)[0]
    lastName =  split(fullName)[1]
    email = @email.val()
    console.log("CARDDDDDDDDDDDD")
    console.log(card)
    loginFormObject = {
      "user":{
        "first_name": firstName,
        "last_name":  lastName,
        "email": email,
        "addresses_attributes": [address]
        "payment_cards_attributes": [card]
      }
    }

    console.log loginFormObject
    loginFormObject

  InitializeActionButton: (element) ->
    element.text("Déjà membre ?")

  onActionClick: (e) ->
    @parent.setContentView(new Shopelia.Views.SignIn(product: @options.product))

