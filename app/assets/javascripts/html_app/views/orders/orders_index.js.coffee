class Shopelia.Views.OrdersIndex extends Backbone.View

  template: JST['orders/index']
  events:
    "click #process-order": "processOrder"

  initialize: ->
    _.bindAll this
    @user = @options.session.get("user") #{"id":136,"email":"kf@glb.com","first_name":"lef","last_name":"pefh","addresses":[{"id":111,"address1":"4 Rue Chapon","address2":"","zip":"75003","city":"Paris","country":"FR","is_default":1,"phone":"0675198943"}],"payment_cards":[{"id":51,"number":"12XXXXXXXXXX3452","name":null,"exp_month":"11","exp_year":"2013"}],"has_pincode":0,"has_password":0}
    @authToken = @options.session.get("auth_token")
    console.log("initialize processOrder View: ")
    console.log(@options)
    @product = @options.product
    total_price = parseFloat(@product.get('expected_price_product')) + parseFloat(@product.get('expected_price_shipping'))
    @expected_price_total = Math.ceil(total_price * 100) / 100;

  render: ->
    console.log(@options)
    $(@el).html(@template(user: @user, product: @product, expected_price_total: @expected_price_total))
    Tracker.onDisplay('Confirmation');
    this


  processOrder: (e) ->
    e.preventDefault()
    @$("#process-order").attr('disabled', 'disabled');
    that = this
    console.log("processOrder")
    order = new Shopelia.Models.Order()
    order.save({
               "expected_price_total":that.expected_price_total,
               "address_id": that.user.addresses[0].id ,
               "products":[that.product.disableWrapping()],
               "payment_card_id": that.user.payment_cards[0].id,
               }, {
               beforeSend : (xhr) ->
                 xhr.setRequestHeader("X-Shopelia-AuthToken",that.authToken)
               success: (resp) ->
                 console.log(resp)
                 Tracker.custom("Order Completed")
                 view = new Shopelia.Views.Greetings()
                 $('#modal-right').html(view.render().el)
               error: (model, response) ->
                 console.log(JSON.stringify(response))
    })


