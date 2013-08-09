class Shopelia.Views.NotFound extends Shopelia.Views.ShopeliaView

  template: 'products/not_found'
  className: 'box product'
  templateHelpers: {
    model: (attr) ->
      console.log(@)
      @product[attr]
  }

  onRender: ->
    Tracker.onDisplay('Product Not Found');