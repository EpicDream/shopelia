class Shopelia.Views.Description extends Shopelia.Views.ShopeliaView

  template: 'products/description'
  className: 'full-description'
  templateHelpers: {
    model: (attr) ->
      console.log(this)
      @product[attr]
  }

  onRender: ->
    Tracker.onDisplay('Product Description');
    $(@el).fadeIn('slow')

  close: ->
    $(@el).slideUp('slow',@superClose)
