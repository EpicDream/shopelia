class Shopelia.Controllers.SignUpController extends Shopelia.Controllers.Controller

  #TO DO REFACTO initialize with pierre to not call bindAll each time
  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.SignUp()
    region.show(@view)

  createUser: (sessionJson) ->
    console.log("trigger createUser")
    if sessionJson isnt undefined
      @view.lockView()
      session = @getSession()
      session.save(sessionJson,{
        success : (resp) ->
          console.log('success callback')
          console.log("response user save: " + JSON.stringify(resp))
          session.saveCookies(resp)
          Shopelia.vent.trigger("modal#on_user_authenticated")
        error : (model, response) ->
          #console.log(JSON.stringify(response))
          @view.unlockView()
          #TODO Display Errors
          #displayErrors($.parseJSON(response.responseText))
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
             Shopelia.vent.trigger("sign_in#show",email)
           error: (jqXHR,textStatus,errorThrown) ->
             #console.log("user dosn't exist")
             #console.log(JSON.stringify(errorThrown))
           });
