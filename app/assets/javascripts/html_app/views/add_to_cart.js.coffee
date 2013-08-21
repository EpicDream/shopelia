class Shopelia.Views.AddToCart extends Shopelia.Views.Layout

  template: 'add_to_cart'
  className: "box"
  ui: {
    email: 'input[name="email"]'
    validation: '#btn-add'
  }
  events:
    "click #btn-add": "onValidationClick"

  onRender: ->
    Tracker.onDisplay('AddToCart');
    $(@el).fadeIn('slow')
    @initializeForm()

  onShow: ->
    $(@el).fadeIn('slow',() ->
      Shopelia.vent.trigger("modal#center")
    )

  onValidationClick: (e) ->
    e.preventDefault()
    Shopelia.vent.trigger("add_to_cart#close",userJson)

  getFormResult: ->
    if $('form').parsley( 'validate' )
       {
        "email": @ui.email.val(),
        "password": @ui.password.val()
       }
    else
      undefined

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)





