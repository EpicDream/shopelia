class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: 'products/index'
  templateHelpers: {
    model: (attr) ->
      @product[attr]
    format: (v) ->
      window.formatCurrency(v)
    formatShipping: (v) ->
      window.formatShipping(v)
  }
  className: 'product box'
  events:
    'click #full-description': 'onDescriptionClick'

  ui: {
    shipping: ".shipping"
    shipping_info: "#shipping-info"
    description: ".product-description"
    description_link: "#full-description"
    cashfront: ".cashfront"
    strikeout: ".price-strikeout"
  }

  initialize: ->
    @model.on('change', @render, @)

  onRender: ->
    if @model.get('shipping_info')
      @ui.shipping_info.show()

    if @model.get('expected_price_strikeout') > 0
      @ui.strikeout.show()

    if @model.get('expected_cashfront_value') > 0
      @ui.cashfront.show()

    unless @model.get('description')
      @ui.description.remove()
      @ui.description_link.remove()

  onDescriptionClick: ->
    Shopelia.vent.trigger("modal#show_product_description",@model)





