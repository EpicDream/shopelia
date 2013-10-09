if navigator.userAgent.indexOf("iPhone") != -1
  iWebkit = undefined
  unless iWebkit
    iWebkit = window.onload = ->
      hideURLbar = ->
        window.scrollTo 0, 0.9
      iWebkit.init = ->
        hideURLbar()
      iWebkit.init()

window.shopeliaFastClick = (buttonArray) ->
  _.each(buttonArray, (button) ->
    new FastClick(button)
  )

$(document).ready ->
  if $("body.action-connect").length > 0
    Connect.init()
  else if $("body.action-index").length > 0
    Index.init()

Connect =
  init: ->
    $("#signin-form").on "ajax:error", (data, xhr, response) ->
      $("#signin-error-text").html(xhr.responseText)
      $("#signin-error-box").show("fast")
    $("#signup-form").on "ajax:error", (data, xhr, response) ->
      $("#signup-error-text").html(xhr.responseText)
      $("#signup-error-box").show("fast")

Index =
  init: ->
    $(window).resize ->
      $btnDownload.tooltip('hide');
    $btnDownload = $(".btn-download")
    $btnDownload.tooltip({
      'animation': true,
      'placement': 'right',
      'trigger': 'click',
      'html': true,
      'title': $("#downloadTooltip").html()
    })
    $btnDownload.on 'shown.bs.tooltip', () ->
      $("#send-link-input").focus()
      $('#send-link-btn').click (e) ->
        $('#send-link-btn').button("loading")