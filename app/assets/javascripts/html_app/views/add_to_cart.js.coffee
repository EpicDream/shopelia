class Shopelia.Views.AddToCart extends Shopelia.Views.Form

  template: 'add_to_cart'
  className: "box"
  templateHelpers: {
    model: (attr) ->
      @product[attr]
  }

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
    data =  @getFormResult()
    if data
      Shopelia.vent.trigger("add_to_cart#add_product_to_cart",data)

  getFormResult: ->
    if $('form').parsley( 'validate' )
       {
        "email": @ui.email.val(),
        "product_version_id": @model.get('product_version_id')
       }
    else
      undefined

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)





