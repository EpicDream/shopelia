class Shopelia.Controllers.ThankYouController extends Shopelia.Controllers.Controller

  show: (region) ->
    @view = new Shopelia.Views.ThankYou()
    region.show(@view)
    has_password = @getSession().get('user').get('has_password')
    if has_password is undefined or has_password is 0
      @passwordView = new Shopelia.Views.NewPassword()
      @view.bottom.show(@passwordView)
    window.Shopelia.AbbaCartPosition = 'none'

  passwordUpdated: ->
    temp = JST['users/password_updated']
    $(@view.el).html(temp())


