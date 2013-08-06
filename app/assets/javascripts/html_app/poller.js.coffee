class Shopelia.Poller extends Backbone.Wreqr.EventAggregator

  constructor:(config) ->
    console.log("initialize poller")
    console.log(config)
    @intervalTime =  config.intervalTime or 200
    @method = config.method or 'GET'
    @url = config.url
    @userData = config.userData
    @expiry = config.expiry or 10000
    @isRunning = false

  start: ->
    unless @isRunning
      @isRunning = true
      @trigger("start")
      @redirectTime = 0
      @callStart()


  callStart: ->
    that = this
    @begin_time_request = 0
    if @isRunning
      $.ajax({
             type: that.method,
             url: that.url,
             data: that.userData
             dataType: 'json',
             beforeSend: (xhr) ->
               xhr.setRequestHeader("Accept","application/json")
               xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
               xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
               that.begin_time_request = new Date().getTime();
             success: (data,textStatus,jqXHR) ->
               that.trigger("data_available",data)
             error: (jqXHR,textStatus,errorThrown) ->
             complete: (jqXHR, textStatus) ->
                requestTime  = new Date().getTime() - that.begin_time_request
                that.redirectTime += requestTime
                that.isRunning =  that.redirectTime < that.expiry
                if that.isRunning
                  setTimeout that.callStart, that.intervalTime
                else
                  that.trigger("expired")
             });


  stop: ->
    if @isRunning
      @isRunning = false
      @trigger("stop")

