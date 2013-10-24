class Shopelia.Views.Recap extends Shopelia.Views.Layout

  template: 'orders/recap'

  templateHelpers: {
    user:(attr) ->
      console.log("ORDER RECAP HELPER" + JSON.stringify(@))
      @order.session.get('user').get(attr)
    product:(attr) ->
      @order.product.get(attr)
    address:(attr) ->
      @order.session.get('user').get('addresses').getDefaultAddress().get(attr)
    total_price:() ->
      @order.product.getExpectedTotalPrice()
    format:(value) ->
      window.formatCurrency(value)
    }

  className: 'box'
  ui: {
    cashfront: '#order-cashfront'
    quantity: '#quantity'
    order_test: '#order-test-box'
  }

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    console.log("Render order recap")
    Tracker.onDisplay('Recap')
    @ui.quantity.val(@model.get("product").get("quantity"))
    if @model.get("product").get('expected_cashfront_value') > 0
      @ui.cashfront.show()
    if @model.get("product").get('allow_quantities') == 0
      @ui.quantity.hide()
    if @model.get("session").get("user").get("email").match(/shopelia/)
      @ui.order_test.show()



