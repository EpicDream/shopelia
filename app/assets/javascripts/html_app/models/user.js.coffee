class Shopelia.Models.User extends Backbone.Model
  name: "user"
  urlRoot: "/api/users"


  update: (attrs,callbacks) ->
    #console.log("In update login method")
    #console.log(@id)
    $.ajax({
           type: "PUT",
           url: 'api/users/' + @get('id'),
           data: {user: attrs},
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
             callbacks.beforeSend(xhr)
           success: callbacks.success
           error: callbacks.error
           })



