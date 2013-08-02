class Shopelia.Views.ThankYou extends Shopelia.Views.ShopeliaView

  template: 'orders/thank_you'
  className: 'box'

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    Tracker.onDisplay('Thank You');
