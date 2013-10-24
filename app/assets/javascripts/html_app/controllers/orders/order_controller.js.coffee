class Shopelia.Controllers.OrderController extends Shopelia.Controllers.Controller

  show: (region,order) ->
    @view = new Shopelia.Views.OrdersIndex(model: order)
    region.show(@view)

  refresh: ->
    if @view
      @view.render()

  create: (order) ->
    console.log(@getSession())
    console.log(order)
    that = this
    order.save({}, {
               beforeSend : (xhr) ->
                 xhr.setRequestHeader("X-Shopelia-AuthToken",that.getSession().get("auth_token"))
               success: (resp) ->
                 #console.log(resp)
                 Shopelia.vent.trigger("modal_content#show_thank_you")
               error: (model, response) ->
                 console.log(JSON.stringify(response))
               })



  processOrder: (order) ->
    @view.onProcessOrder(order)