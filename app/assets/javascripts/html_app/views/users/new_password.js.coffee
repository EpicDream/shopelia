class Shopelia.Views.NewPassword extends Shopelia.Views.Form

  template: JST['users/new_password']
  className: 'box new_password'

  events:
    "click button": "setNewPassword"

  initialize: ->
    Shopelia.Views.Form.prototype.initialize.call(this)

  render: ->
    $(@el).html(@template())
    Tracker.onDisplay('Password');
    @setFormVariables()
    Shopelia.Views.Form.prototype.render.call(this)
    #console.log()
    this

  setFormVariables: ->
    @password = @$('input[name="password"]')

  setNewPassword:(e) ->
    e.preventDefault()
    disableButton($(e.currentTarget))
    session = new Shopelia.Models.Session()
    authToken = session.get("auth_token")
    user = session.get("user")
    #console.log(user)
    that = this
    user.update({
               password: @password.val(),
               password_confirmation:  @password.val()
               },{
                beforeSend: (xhr) ->
                  xhr.setRequestHeader("X-Shopelia-AuthToken",authToken)
                success : (resp) ->
                  $(that.el).html("<h5 class='text-center'>Votre Mot de passe a bien été enregistré ! Nous espérons vous revoir bientôt sur Shopelia. Bonne journée !</h5>")
                error : (model, response) ->
                  session.deleteCookies()
                })
