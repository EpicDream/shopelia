class Shopelia.Views.ThankYou extends Backbone.View

  template: JST['orders/thank_you']
  className: 'box'

  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Thank You');
    unless $(".new_password").length == 0
      $(".new_password").fadeIn(500)
    this