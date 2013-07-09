class Shopelia.Views.Greetings extends Backbone.View

  template: JST['orders/greetings']


  initialize: ->
    _.bindAll this


  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Greetings');
    this