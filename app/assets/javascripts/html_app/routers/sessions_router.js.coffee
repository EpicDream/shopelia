class Shopelia.Routers.Sessions extends Backbone.Router
  routes: {
  'checkout': 'checkSession'
  }

  initialize: ->
    _.bindAll this
    $(window).on('resize.modal',() ->
      center($("#modal"))
    )
    $(window).on('load',() ->
      center($("#modal"))
    )

  checkSession: (params) ->
    @product = new Shopelia.Models.Product(params)
    @session = new Shopelia.Models.Session()
    @modal = @showModal(params)
    console.log("check")
    if @session.authenticated()
      console.log("authenticated")
      console.log(@session)
      userId = @session.get("user").id
      authToken = @session.get("auth_token")
      console.log(userId)
      @user = new Shopelia.Models.User(id:userId)
      that = this
      @user.fetch({
                    beforeSend: (xhr) ->
                      xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                    success : (resp) ->
                      console.log("fetched user success callback: " + JSON.stringify(resp.disableWrapping()))
                      that.session.updateCookies(resp.disableWrapping())
                      that.modal.setContentView(new Shopelia.Views.SignIn(session: that.session ,product: that.product, email: that.session.get("user").email))
                      center($("#modal"))
                    error : (model, response) ->
                        that.session.deleteCookies()
                    })
    else
      @modal.setContentView(new Shopelia.Views.UsersIndex(session: @session,product: @product))
      center($("#modal"))

  showModal: (params)  ->
    @product = new Shopelia.Models.Product(params)
    view = new Shopelia.Views.Modal(product: @product)
    $('#container').append(view.render().el)
    center($("#modal"))
    view
