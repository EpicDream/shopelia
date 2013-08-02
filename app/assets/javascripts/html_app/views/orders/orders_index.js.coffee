class Shopelia.Views.OrdersIndex extends Shopelia.Views.ShopeliaView

  template: 'orders/index'
  templateHelpers: {
    user:(attr) ->
      console.log(@)
      @order.user[attr]
    product:(attr) ->
      console.log(@order.product)
      @order.product[attr]

    #TODO Check which address to retrieve
    address:() ->
      console.log(@order.user)
      @order.user.addresses[0]

    card: ->
      @order.user.payment_cards[0]

    total_price:() ->
      #TODO add method to_price in Float.prototype
      customParseFloat(parseFloat(@order.product.expected_price_product) + parseFloat(@order.product.expected_price_shipping))
  }
  className: 'box'
  ui: {
    validation: '#process-order'
  }
  events:
    "click #process-order": "onProcessOrder"

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)
    #@user = {"id":136,"email":"kf@glb.com","first_name":"lef","last_name":"pefh","addresses":[{"id":111,"address1":"4 Rue Chapon","address2":"","zip":"75003","city":"Paris","country":"FR","is_default":1,"phone":"0675198943"}],"payment_cards":[{"id":51,"number":"12XXXXXXXXXX3452","name":null,"exp_month":"11","exp_year":"2013"}],"has_pincode":0,"has_password":0}
    #@authToken = "34456666"
    @user = @getSession().get("user")
    @authToken = @getSession().get("auth_token")
    #console.log("initialize processOrder View: ")
    @product = @getProduct()


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
    {
      "expected_price_shipping": @model.get("expected_price_shipping")
      "expected_price_product":  @model.get("expected_price_product")
      "expected_price_total":@model.get("expected_price_total"),
      "address_id": @model.get("user").addresses[0].id ,
      "products":[@model.get("product")],
      "payment_card_id": @model.get("user").payment_cards[0].id,
    }

  lockView: ->
    disableButton(@ui.validation)

  unlockView: ->
    enableButton(@ui.validation)



