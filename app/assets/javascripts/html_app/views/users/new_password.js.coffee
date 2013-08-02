class Shopelia.Views.NewPassword extends Shopelia.Views.Form

  template: 'users/new_password'
  className: 'box new_password'
  ui: {
    password: 'input[name="password"]'
  }

  events:
    "click button": "setNewPassword"

  initialize: ->
    Shopelia.Views.Form.prototype.initialize.call(this)

  onRender: ->
    Tracker.onDisplay('Password');
    #Shopelia.Views.Form.prototype.render.call(this)

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
