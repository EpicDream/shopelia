class Shopelia.Controllers.ThankYouController extends Shopelia.Controllers.Controller

  show: (region) ->
    @view = new Shopelia.Views.ThankYou()
    region.show(@view)
    if @getSession().get('user').has_password is undefined or @getSession().get('user').has_password is 0
      @passwordView = new Shopelia.Views.NewPassword()
      @view.bottom.show(@passwordView)


