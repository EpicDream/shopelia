class Shopelia.Controllers.OrderController extends Shopelia.Controllers.Controller

  show: (region,order) ->
    @view = new Shopelia.Views.OrdersIndex(model: order)
    region.show(@view)


  processOrder: (orderJson) ->
    @view.lockView()
    console.log(@getSession())
    that = this
    order = new Shopelia.Models.Order()
    order.save(orderJson, {
               beforeSend : (xhr) ->
                 xhr.setRequestHeader("X-Shopelia-AuthToken",that.getSession().get("auth_token"))
               success: (resp) ->
                 #console.log(resp)
                 Shopelia.vent.trigger("modal#show_thank_you")
               error: (model, response) ->
                 that.view.unlockView()
                 console.log(JSON.stringify(response))
               })


