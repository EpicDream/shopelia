class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: 'products/index'
  templateHelpers: {
    model: (attr) ->
      @product[attr]
  }
  className: 'product box'
  events:
    'click #full-description': 'onDescriptionClick'

  ui: {
    shipping: ".shipping"
    description: ".product-description"
    description_link: "#full-description"
    cashfront: ".cashfront"
    strikeout: ".price-strikeout"
  }

  initialize: ->
    @model.on('change', @render, @)

  onRender: ->
    $res = $('<p> frais de livraison </p>')
    value = @model.get("expected_price_shipping")
    unless isNaN(value)
      if parseFloat(value) isnt 0
        $res.append('<span class="green">'+@model.get("expected_price_shipping")+' € </span>')
      else
        $res.html('<span class="green">Livraison gratuite</span>')

    @ui.shipping.html($res)
    if @model.get('shipping_info')
      @ui.shipping.append('<p class="green bold clearfix">'+@model.get('shipping_info')+'</p>')

    if @model.get('expected_price_strikeout') > 0
      @ui.strikeout.show()

    if @model.get('expected_cashfront_value') > 0
      @ui.cashfront.show()

    unless @model.get('description')
      @ui.description.remove()
      @ui.description_link.remove()

  onDescriptionClick: ->
    Shopelia.vent.trigger("modal#show_product_description",@model)








