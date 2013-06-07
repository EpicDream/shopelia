class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click button": "createUser"

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template())
    this

  createUser: (e) ->
    e.preventDefault()
    loginFormObject = {};
    $.each($('form').serializeArray(),
           (i, v) ->
              loginFormObject[v.name] = v.value
    )

    user = @collection.create({"user": loginFormObject},{
                              wait : true,
                              success : (resp) ->
                                console.log('success callback')
                                console.log(resp)
                              error : (model,response,json) ->

                                console.log('error callback'+ json + JSON.stringify(response))
    })

    if (model.validationError)
      alert model.validationError
