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
    Tracker.onDisplay('Add To Cart');
    $(@el).fadeIn('slow')
    @initializeForm()

  onShow: ->
    if window.Shopelia.AbbaShowSpam == false
      $("#spam").hide()
    $(@el).fadeIn('slow',() ->
      Shopelia.vent.trigger("modal#center")
    )

  onClose: ->
    $("#modal-top-wrapper").hide()
    $("#modal-bottom-wrapper").hide()

  onValidationClick: (e) ->
    e.preventDefault()
    Shopelia.vent.trigger("add_to_cart#add_product_to_cart", {
      "email": @ui.email.val(),
      "product_version_id": @model.get('product_version_id')
    })

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)