class Shopelia.Routers.Sessions extends Backbone.Router
  routes: {
  'checkout': 'checkSession'
  }

  initialize: ->
    _.bindAll this
    $(window).on('resize.modal',@center)
    $(window).on('load',@center)


  checkSession: (params) ->
    @product = new Shopelia.Models.Product(params)
    @session = new Shopelia.Models.Session()
    @modal = @showModal(params)
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
                      that.modal.setContentView(new Shopelia.Views.SignIn(product: @product))
                      that.center()
                    error : (model, response) ->
                        that.session.deleteCookies()
                    })

    @modal.setContentView(new Shopelia.Views.UsersIndex(product: @product))


  showModal: (params)  ->
    @product = new Shopelia.Models.Product(params)
    view = new Shopelia.Views.Modal(product: @product)
    $('#container').append(view.render().el)
    @center()
    view

  center: ->
    top =undefined
    left = undefined
    top = Math.max($(window).height() - $('#modal').height(), 0) / 2
    left = Math.max($(window).width() - $('#modal').outerWidth(), 0) / 2

    $('#modal').css
      top: top
      left: left
