class Shopelia.Controllers.SignUpController extends Shopelia.Controllers.Controller

  #TO DO REFACTO initialize with pierre to not call bindAll each time
  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.SignUp()
    @region = region
    @region.show(@view)
    @pushHeaderLink("sign_in#show","Déjà membre?",region)

  create: (user) ->
    console.log("trigger createUser")
    that = this
    if user isnt undefined
      @view.lockView()
      session = @getSession()
      session.set('user',user)
      session.save({},{
        success : (resp) ->
          console.log('success callback')
          console.log("response user save: " + JSON.stringify(resp))
          session.saveCookies(resp)
          Shopelia.vent.trigger("modal_content#order")

          #Shopelia.vent.trigger("modal_content#showPaymentFields")
        error : (model, response) ->
          that.view.unlockView()
          Shopelia.Notification.Error({ text: $.parseJSON(response.responseText)['error'] })
          console.log(response.responseText)
          displayErrors($.parseJSON(response.responseText))
      })
    else
      console.log("session is undefined in sign_up controller")


  verifyEmail: (email) ->
    that = this
    $.ajax({
           type: 'POST'
           url: 'api/users/exists',
           data: {'email': email},
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
           success: (data,textStatus,jqXHR) ->
             Shopelia.vent.trigger("sign_in#show",that.region,email)
             Shopelia.Notification.Info({center:true,text: "Cet email existe déjà. Veuillez vous connectez ou récupérer votre mot de passe."})
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log("user dosn't exist")
             #console.log(JSON.stringify(errorThrown))
           });


