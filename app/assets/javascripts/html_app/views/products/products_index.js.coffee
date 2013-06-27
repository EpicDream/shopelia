class Shopelia.Views.ProductsIndex extends Backbone.View

  template: JST['products/index']
  className: 'product'

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template(model: @model))
    this