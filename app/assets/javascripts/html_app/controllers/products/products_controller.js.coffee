class Shopelia.Controllers.ProductsController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.ProductsIndex(model: product)
    @region = region
    @product = product
    if product.isValid()
      Shopelia.vent.on("change:merchant",product.addMerchantInfosToProduct)
      Shopelia.vent.trigger("merchants#create",product.get("url"))
    else
      Shopelia.vent.trigger("products#create",product.get("url"))
    if @product.isValid()
      @region.show(@view)
    else
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
    if @product.isValid()
      @poller.stop()
      @region.show(@view)

  onPollerExpired: ->
    that = this
    unless @product.get('merchant') is undefined
      @showNotFound()
    else
      Shopelia.vent.once("change:merchant",(data) ->
        that.product.set("merchant_name",data.merchant.name)
        that.showNotFound()
      )
      Shopelia.vent.trigger("merchants#create",@product.get('url'))


  showNotFound: ->
    Shopelia.vent.trigger("modal#show_not_found",@product)
