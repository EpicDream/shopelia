class Shopelia.Views.OrdersIndex extends Backbone.View

  template: JST['orders/index']
  events:
    "click button": "processOrder"

  initialize: ->
    _.bindAll this
    @user = @options.session.get("user")
    @authToken = @options.session.get("auth_token")
    console.log(@authToken)
    @product = @options.product

  render: ->
    console.log(@options)
    $(@el).html(@template(user: @user, product: @product))
    this


  processOrder: (e) ->
    e.preventDefault()
    that = this
    console.log("processOrder")
    expected_price_total = parseFloat(@product.get('expected_price_product')) + parseFloat(@product.get('expected_price_shipping'))
    order = new Shopelia.Models.Order()
    order.save({
               "expected_price_total":expected_price_total,
               "address_id": @user.addresses[0].id ,
               "products":[@product.disableWrapping()],
               "payment_card_id": @user.payment_cards[0].id,
               }, {
               beforeSend : (xhr) ->
                 xhr.setRequestHeader("X-Shopelia-AuthToken",that.authToken)
               success: (resp) ->
                 console.log(resp)
                 alert('congrats order processed MAN')
               error: (model, response) ->
                 console.log(JSON.stringify(response))
    })


