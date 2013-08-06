class Shopelia.Controllers.ProductsController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.ProductsIndex(model: product)
    @product = product
    if product.isValid()
      Shopelia.vent.on("change:merchant",product.addMerchantInfosToProduct)
      Shopelia.vent.trigger("merchants#create",product.get("url"))
    else
      Shopelia.vent.trigger("products#create",product.get("url"))
    region.show(@view)

  create: (url) ->
    @poller = new Shopelia.Poller({url: "api/products",userData: { url: url }})
    @poller.on('data_available',@onPollerDataAvailable,this)
    @poller.on('expired',@onPollerExpired,this)
    @poller.start()

  onPollerDataAvailable: (data) ->
    @product.setProduct(data)
    if @product.isValid()
      @poller.stop()

  onPollerExpired: ->
    Shopelia.vent.trigger("modal#not_found")

