class Shopelia.Views.NotAvailable extends Shopelia.Views.ShopeliaView

  template: 'products/not_available'
  templateHelpers: {
    model: (attr) ->
      console.log(@)
      @product[attr]
  }

  onRender: ->
    Tracker.onDisplay('Product Not Available');

  onShow: ->
    Shopelia.vent.trigger("modal#center")