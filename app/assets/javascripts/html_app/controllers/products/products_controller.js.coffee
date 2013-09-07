class Shopelia.Controllers.ProductsController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.ProductsIndex(model: product)
    @region = region
    @product = product
    Shopelia.vent.trigger("products#create",product.get("url"))
    loaderView = new Shopelia.Views.Loading()
    @region.show(loaderView)

  create: (url) ->
    @poller = new Shopelia.Poller({url: "api/products",userData: { url: url }})
    @poller.on('data_available',@onPollerDataAvailable,this)
    @poller.on('expired',@onPollerExpired,this)
    @poller.start()

  onPollerDataAvailable: (data) ->
    console.log('data')
    console.log(data)
    @product.setProduct(data)
    if @product.get('ready') == 1
      @poller.stop()
      if @product.get('available')    
        @region.show(@view)
      else
        @onPollerExpired()

  onPollerExpired: ->
    Shopelia.vent.trigger("modal#show_product_not_available",@product)