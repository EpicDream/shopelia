class Shopelia.Views.OrdersIndex extends Backbone.View

  template: JST['orders/index']

  initialize: ->
    _.bindAll this

  render: ->
    console.log(@options)
    $(@el).html(@template(session: @options.session))
    this