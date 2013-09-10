class Shopelia.Controllers.ModalContentController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show:(region) ->
    if @view is undefined
      @view = new Shopelia.Views.ModalContent()
      region.show(@view)
      @showProduct(@getProduct())
      @showUserForm()
      if window.Shopelia.AbbaCartPosition == 'top'
        @showCartFormTop()
      else if window.Shopelia.AbbaCartPosition == 'bottom'
        @showCartFormBottom()
    else
      @view.show()

  hide: ->
    @view.hide()

  showCartFormTop: ->
    $("#modal-top-wrapper").show()
    Shopelia.vent.trigger('add_to_cart#show',@view.top)

  showCartFormBottom: ->
    $("#modal-bottom-wrapper").show()
    Shopelia.vent.trigger('add_to_cart#show',@view.bottom)

  showProduct: (product) ->
    Shopelia.vent.trigger("products#show",@view.left,product)

  showSignUp: ->
    Shopelia.vent.trigger("sign_up#show",@view.right)

  showSignIn: ->
    Shopelia.vent.trigger("sign_in#show",@view.right)

  showUserForm: ->
    @session = @getSession()
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
                    console.log(resp)
                    that.session.updateUserCookies(resp)
                    that.showSignIn()
                  error : (model, response) ->
                    that.session.deleteCookies()
                  })
    else
      @showSignUp()

  order: ->
    session = @getSession().clone()
    order = new Shopelia.Models.Order({
                                      session: session
                                      product: @getProduct()
                                      })
    Shopelia.vent.trigger("sign_up#close")
    Shopelia.vent.trigger("sign_in#close")
    Shopelia.vent.trigger("order#show",@view.right,order)

  showThankYou: ->
    Shopelia.vent.trigger("thank_you#show",@view.right)

  onBeforeClose: ->
    Shopelia.vent.trigger("sign_up#close")
    Shopelia.vent.trigger("sign_in#close")
    Shopelia.vent.trigger("products#close")
