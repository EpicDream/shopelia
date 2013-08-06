class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: 'products/index'
  templateHelpers: {
    model: (attr) ->
      @product[attr]
  }
  className: 'product box'
  events:
    'click #full-description': 'onDescriptionClick'

  initialize: ->
    @model.on('change', @render, @)

  onDescriptionClick: ->
    Shopelia.vent.trigger("modal#show_product_description",@model)








