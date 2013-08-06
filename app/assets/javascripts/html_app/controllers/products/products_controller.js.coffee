class Shopelia.Controllers.ProductsController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.ProductsIndex(model: product)
    if product.isValid()
      Shopelia.vent.on("change:merchant",product.addMerchantInfosToProduct)
      Shopelia.vent.trigger("merchants#create",product.get("url"))
    else
      Shopelia.vent.on("change:product",product.setProduct)
      Shopelia.vent.trigger("products#create",product.get("url"))
    region.show(@view)

  create: (url) ->
    $.ajax({
           type: "GET",
           url: "api/products",
           data: { url: url }
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             Shopelia.vent.trigger("change:product",data)
           error: (jqXHR,textStatus,errorThrown) ->
           });



