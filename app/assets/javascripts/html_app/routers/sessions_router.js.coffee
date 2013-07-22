class Shopelia.Routers.Sessions extends Backbone.Router
  routes: {
  'checkout': 'checkSession'
  }

  initialize: ->
    _.bindAll this
    $(window).on('resize.modal',() ->
      center($(window),$("#modal"))
    )
    $(window).on('load',() ->
      center($(window),$("#modal"))
    )

  checkSession: (params) ->
    @product = new Shopelia.Models.Product(params)
    @session = new Shopelia.Models.Session()
    @modal = @showModal()
    console.log("check")
    if @session.authenticated()
      console.log("authenticated")
      console.log(@session)
      authToken = @session.get("auth_token")
      @user = @session.get("user")
      that = this
      @user.fetch({
                    beforeSend: (xhr) ->
                      xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                    success : (resp) ->
                      console.log("fetched user success callback: " + JSON.stringify(resp.disableWrapping()))
                      that.session.updateUserCookies(resp.disableWrapping())
                      that.modal.setContentView(new Shopelia.Views.SignIn(session: that.session ,product: that.product, email: that.session.get("user").get('email')))
                      center($(window),$("#modal"))
                    error : (model, response) ->
                        that.session.deleteCookies()
                    })
    else
      @modal.setContentView(new Shopelia.Views.UsersIndex(session: @session,product: @product))
      center($(window),$("#modal"))

  showModal: ->
    view = new Shopelia.Views.Modal(product: @product)
    $('#container').append(view.render().el)
    center($(window),$("#modal"))
    view
