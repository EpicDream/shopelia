class Shopelia.Controllers.RecapController extends Shopelia.Controllers.Controller

  show: (region,order) ->
    @view = new Shopelia.Views.Recap(model: order)
    region.show(@view)



