class Shopelia.Views.UsersIndex extends Backbone.View

  template: JST['users/index']
  events:
    "click button": "createUser"

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template())
    view = new Shopelia.Views.AddressesIndex(collection: @collection)
    @$('button').before(view.render().el)
    this

  createUser: (e) ->
    e.preventDefault()
    loginFormObject = {};
    $.each($('form').serializeArray(),
           (i, v) ->
              loginFormObject[v.name] = v.value
    )

    @collection.create({"user": loginFormObject},{
                              wait : true,
                              success : (resp) ->
                                console.log('success callback')
                                console.log(resp)
                              error : (model,response,json) ->

                                console.log('error callback'+ json + JSON.stringify(response))
    })


