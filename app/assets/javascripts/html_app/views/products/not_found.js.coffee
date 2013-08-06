class Shopelia.Views.NotFound extends Shopelia.Views.ShopeliaView

  template: 'products/not_found'
  className: 'product'
  templateHelpers: {
    model: (attr) ->
      console.log(@)
      @product[attr]
  }

  onRender: ->
    Tracker.onDisplay('Product Not Found');