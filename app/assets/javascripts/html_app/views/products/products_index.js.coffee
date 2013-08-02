class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: 'products/index'
  templateHelpers: {
    model: (attr) ->
      @product[attr]
  }
  className: 'product box'

  events:
    "click #product-infos": "showProductInfos"
    "click #full-description": "showDescription"

  initialize: ->
    that = this
    @model.on('change', @render, @)



