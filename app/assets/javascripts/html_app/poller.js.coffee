class Shopelia.Poller extends Backbone.Wreqr.EventAggregator

  constructor:(config) ->
    _.bindAll(this)
    @intervalTime =  config.intervalTime or 500
    @method = config.method or 'GET'
    @url = config.url
    @userData = config.userData
    @expiry = config.expiry or 150000
    @optionsExpiry = config.optionsExpiry or 180000
    @isRunning = false

  start: ->
    unless @isRunning
      @isRunning = true
      @trigger("start")
      @redirectTime = 0
      @begin_time_request = new Date().getTime();
      @callStart()

  callStart: ->
    that = this
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
        success: (data,textStatus,jqXHR) ->
          jsonData = JSON.stringify(data)
          if that.isRunning && (window.lastPollerData == null || window.lastPollerData != jsonData)
            that.trigger("data_available",data)
            window.lastPollerData = jsonData
            window.productReady = data.ready
        error: (jqXHR,textStatus,errorThrown) ->
        complete: (jqXHR, textStatus) ->
          if that.isRunning
            requestTime  = new Date().getTime() - that.begin_time_request
            that.begin_time_request = new Date().getTime()
            that.redirectTime += requestTime
            if window.productReady == 1
              that.isRunning = that.redirectTime < that.optionsExpiry
            else
              that.isRunning = that.redirectTime < that.expiry
            if that.isRunning
              setTimeout(that.callStart, that.intervalTime)
            else
              that.trigger("expired")
              that.stop()
      });

  stop: ->
    if @isRunning
      @isRunning = false
      @trigger("stop")