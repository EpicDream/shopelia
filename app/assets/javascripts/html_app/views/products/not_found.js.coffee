class Shopelia.Views.NotFound extends Backbone.View

  template: JST['products/not_found']
  className: 'product'


  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template(model: @model))
    this