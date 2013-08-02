class Shopelia.Controllers.ThankYouController extends Shopelia.Controllers.Controller

  show: (region) ->
    @view = new Shopelia.Views.ThankYou()
    region.show(@view)