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
  }

  initialize: ->
    @model.on('change', @render, @)

  onRender: ->
    $res = $('<p> frais de livraison </p>')
    if @model.get('expected_price_shipping') == "Livraison gratuite"
      $res.html('<span class="green">Livraison gratuite</span>')
    else
      $res.append('<span class="green">'+@model.get("expected_price_shipping")+'</span>')

    $res.after('<p class="green bold clearfix">'+@model.get('shipping_info')+'</p>')
    @ui.shipping.append($res)
    unless @model.get('description')
      @ui.description.remove()
      @ui.description_link.remove()


  onDescriptionClick: ->
    Shopelia.vent.trigger("modal#show_product_description",@model)








