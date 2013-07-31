class Shopelia.Controllers.AppController extends Backbone.Marionette.Controller

  initialize: ->
    _.bindAll this
    $(window).on('resize.modal',() ->
      center($(window),$("#modal"))
    )
    $(window).on('load',() ->
      center($(window),$("#modal"))
    )

  checkSession: (params) ->
    if params.developer isnt undefined
      Shopelia.developerKey = params.developer
    @product = new Shopelia.Models.Product(params)
    @session = new Shopelia.Models.Session()
    @modal = @showModal()
    #console.log("check")
    if @session.authenticated()
      #console.log("authenticated")
      #console.log(@session)
      authToken = @session.get("auth_token")
      @user = @session.get("user")
      that = this
      @user.fetch({
                  beforeSend: (xhr) ->
                    xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                  success : (resp) ->
                    #console.log("fetched user success callback: " + JSON.stringify(resp.disableWrapping()))
                    that.session.updateUserCookies(resp.disableWrapping())
                    that.modal.setContentView(new Shopelia.Views.SignIn(email: that.session.get("user").get('email')))
                    center($(window),$("#modal"))
                  error : (model, response) ->
                    that.session.deleteCookies()
                  })
    else
      @modal.setContentView(new Shopelia.Views.UsersIndex())
      center($(window),$("#modal"))

  showModal: ->
    view = new Shopelia.Views.Modal(session: @session,product: @product)
    $('#container').append(view.render().el)
    center($(window),$("#modal"))
    view

