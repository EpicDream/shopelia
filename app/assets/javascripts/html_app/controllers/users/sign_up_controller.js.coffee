class Shopelia.Controllers.SignUpController extends Shopelia.Controllers.Controller

  #TO DO REFACTO initialize with pierre to not call bindAll each time
  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.SignUp()
    region.show(@view)
