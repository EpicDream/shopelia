class Shopelia.Views.ThankYou extends Shopelia.Views.ShopeliaView

  template: JST['orders/thank_you']
  className: 'box'

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)


  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Thank You');
    unless $(".new_password").length == 0
      $(".new_password").fadeIn(500)
    this