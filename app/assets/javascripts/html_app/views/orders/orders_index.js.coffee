class Shopelia.Views.OrdersIndex extends Shopelia.Views.ShopeliaView

  template: 'orders/index'
  templateHelpers: {
    user:(attr) ->
      console.log(@)
      @order.session.get('user').get(attr)
    product:(attr) ->
      console.log(@order.product)
      @order.product.get(attr)

    address:() ->
      @order.session.get('user').get('addresses')[0]

    card: ->
      @order.session.get('user').get('payment_cards')[0]

    total_price:() ->
      @order.product.getExpectedTotalPrice()
  }
  className: 'box'
  ui: {
    validation: '#process-order'
  }
  events:
    "click #process-order": "onProcessOrder"

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    @$("#process-order").after(
      () ->
        #securityView = new Shopelia.Views.Security()
        #$(securityView.render().el)
    )
    Tracker.onDisplay('Confirmation');

  onProcessOrder: (e) ->
    e.preventDefault()
    Shopelia.vent.trigger("order#process_order",@getOrderJson())

  getOrderJson: ->
    product = @model.get("product")
    user = @model.get("session").get("user")
    {
      "expected_price_shipping": product.get('expected_price_shipping')
      "expected_price_product":  product.get('expected_price_product')
      "expected_price_total": product.getExpectedTotalPrice()
      "address_id": user.get('addresses')[0].id
      "products":[product.disableWrapping()]
      "payment_card_id": user.get('payment_cards')[0].id
    }

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)



