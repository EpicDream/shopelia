class Shopelia.Views.ThankYou extends Shopelia.Views.Layout

  template: 'orders/thank_you'
  regions: {
    bottom: "#thank-you-bottom"
  }

  onRender: ->
    Tracker.onDisplay('Thank You');


