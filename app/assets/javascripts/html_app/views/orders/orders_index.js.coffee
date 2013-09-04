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
  }
  events:
    "click #process-order": "onProcessOrder"
    "change #quantity": "onChangeQuantity"

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    Tracker.onDisplay('Confirmation')
    @ui.quantity.val(@model.get("product").get("quantity"))
    if @model.get("product").get('expected_cashfront_value') > 0
      @ui.cashfront.show()
    if @model.get("product").get('allow_quantities') == 0
      @ui.quantity.hide()

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
    order = new Shopelia.Models.Order({
      "expected_price_shipping": product.get('expected_price_shipping')
      "expected_price_product": product.get('expected_price_product') * product.get('quantity')
      "expected_cashfront_value": product.get('expected_cashfront_value') * product.get('quantity')
      "expected_price_total": product.getExpectedTotalPrice()
      "address_id": user.get('addresses').getDefaultAddress().get('id')
      "products":[product.disableWrapping()]
      "payment_card_id": user.get('payment_cards').getDefaultPaymentCard().get('id')
    })
    order

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)



