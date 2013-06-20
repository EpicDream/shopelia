class Shopelia.Views.PaymentCardsIndex extends Backbone.View

  template: JST['payment_cards/index']

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template(model: @model))
    console.log(@model)
    this
