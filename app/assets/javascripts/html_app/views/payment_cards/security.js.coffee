class Shopelia.Views.Security extends Shopelia.Views.ShopeliaView

  template: JST['payment_cards/security']
  className: 'security'

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)


  render: ->
    $(@el).html(@template())
    this