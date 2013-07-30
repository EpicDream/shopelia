class Shopelia.Views.NotFound extends Shopelia.Views.ShopeliaView

  template: JST['products/not_found']
  className: 'product'


  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  render: ->
    $(@el).html(@template(model: @model))
    this