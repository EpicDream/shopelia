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

$(document).ready ->
  ShopeliaCheckout.init
    developer: "e35c8cbbcfd7f83e4bb09eddb5a3f4c461c8d30a71dc498a9fdefe217e0fcd44"
    tracker: "shopelia-web"

  $("#product-bar").on "input", ->
    $(this).popover "hide"

  $("#shopelia-form").submit (e) ->
    e.preventDefault()
    $button = $("#btn-order")
    url = $("[name='url']").val()
    if url.match(/amazon.fr/)
      $button.attr "data-shopelia-url", url
      ShopeliaCheckout.update()
      $button.click()
      $button.unbind "click"
    else
      $("#product-bar").popover "show"

