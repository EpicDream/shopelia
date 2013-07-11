class Shopelia.Routers.Sessions extends Backbone.Router
  routes: {
  'checkout': 'checkSession'
  }

  initialize: ->
    _.bindAll this


  checkSession: (params) ->
    @productRouter = new Shopelia.Routers.Products()
    @product = new Shopelia.Models.Product(params)
    @session = new Shopelia.Models.Session()
    @productRouter.showModal(params)
    console.log("check")
    if @session.authenticated()
      console.log(@session)
      userId = @session.get("user").id
      authToken = @session.get("authToken")
      console.log(authToken)
      @user = new Shopelia.Models.User(id:userId)
      that = this
      @user.fetch({
                    beforeSend: (xhr) ->
                      xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                    success : (resp) ->
                      console.log("fetched user success callback: " + JSON.stringify(resp))
                      that.session.updateCookies(resp)
                      console.log(that.session)
                      goToOrdersIndex(that.session,that.product)
                      that.productRouter.center()
                  error : (model, response) ->
                      that.session.deleteCookies()
                    })
    else
      goToSignIn(@product)

