# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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

Connect =
  init: ->
    $("#signin-form").on "ajax:error", (data, xhr, response) ->
      $("#signin-error-text").html(xhr.responseText)
      $("#signin-error-box").show("fast")
    $("#signup-form").on "ajax:error", (data, xhr, response) ->
      $("#signup-error-text").html(xhr.responseText)
      $("#signup-error-box").show("fast")

$(document).ready ->
  if $("body.action-connect").length > 0
    Connect.init()