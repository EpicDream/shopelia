class Shopelia.Controllers.DescriptionController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.Description(model: product)
    region.show(@view)
