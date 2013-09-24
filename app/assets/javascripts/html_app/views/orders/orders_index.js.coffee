class Shopelia.Views.OrdersIndex extends Shopelia.Views.ShopeliaView

  template: 'orders/index'
  templateHelpers: {
    user:(attr) ->
      console.log(@)
      @order.session.get('user').get(attr)
    product:(attr) ->
      @order.product.get(attr)
    address:(attr) ->
      @order.session.get('user').get('addresses').getDefaultAddress().get(attr)
    card:(attr) ->
      @order.session.get('user').get('payment_cards').getDefaultPaymentCard().get(attr)
    total_price:() ->
      @order.product.getExpectedTotalPrice()
    format:(value) ->
      window.formatCurrency(value)
  }
  className: 'box'
  ui: {
    validation: '#process-order'
    cashfront: '#order-cashfront'
    quantity: '#quantity'
    order_test: '#order-test-box'
  }
  events:
    "click #process-order": "onProcessOrder"
    "change #quantity": "onChangeQuantity"

  initialize: ->
    @model.get("product").on('change', @render, @)
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    console.log("Render order form")
    Tracker.onDisplay('Confirmation')
    @ui.quantity.val(@model.get("product").get("quantity"))
    if @model.get("product").get('expected_cashfront_value') > 0
      @ui.cashfront.show()
    if @model.get("product").get('allow_quantities') == 0
      @ui.quantity.hide()
    if @model.get("session").get("user").get("email").match(/shopelia/)
      @ui.order_test.show()

  onProcessOrder: (e) ->
    e.preventDefault()
    order = @preparedOrder()
    Shopelia.vent.trigger("order#create",order)

  onChangeQuantity: ->
    @model.get("product").setQuantity(@ui.quantity.val())
    @render()

  preparedOrder: ->
    product = @model.get("product")
    user = @model.get("session").get("user")
    if $("#order-test").is(':checked')
      expected_prices = {
        "expected_price_shipping": 0
        "expected_price_product": 0
        "expected_price_total": 0
      }
    else
      expected_prices = {
        "expected_price_shipping": product.get('expected_price_shipping')
        "expected_price_product": product.get('expected_price_product') * product.get('quantity')
        "expected_price_total": product.getExpectedTotalPrice()
      }
    new Shopelia.Models.Order($.extend(expected_prices, {
        "expected_cashfront_value": product.get('expected_cashfront_value') * product.get('quantity')
        "address_id": user.get('addresses').getDefaultAddress().get('id')
        "payment_card_id": user.get('payment_cards').getDefaultPaymentCard().get('id')
        "products":[{"product_version_id":product.get('product_version_id'),"quantity":product.get('quantity'),"price":product.get('expected_price_product')}]
    }))

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)



