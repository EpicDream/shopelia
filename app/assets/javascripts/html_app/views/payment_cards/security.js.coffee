class Shopelia.Views.Security extends Backbone.View

  template: JST['payment_cards/security']
  className: 'security'

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    this