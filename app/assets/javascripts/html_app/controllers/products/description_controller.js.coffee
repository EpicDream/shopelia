class Shopelia.Controllers.DescriptionController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.Description(model: product)
    region.show(@view)
    @pushHeaderLink("description#close",'Retour')

  #showDescription: (product) ->
  #console.log("Show Product Infos")
  #Tracker.onClick('Product Description')
  #$("#modal-header").after(@description)
  #that = this
  #@description.animate({height:'100%'}, "slow")
  #$("#modal-content").animate({height:'65px',opacity:0},"slow", () ->
  #  $(this).hide()
  #  $("#btn-hide-product-infos").click ->
  #    that.close(that.description)
  #)




