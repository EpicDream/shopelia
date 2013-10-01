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

  $("#btn-download").tooltip({
                             'placement': 'right',
                             'trigger': 'click'
                             'html': true
                             'title': 'Ouvrez shopelia.com/download sur votre mobile ou <b> recevez le lien de téléchargement sur votre téléphone ou email</b> <div class="spacer10"></div><form class="form-inline" role="form"><div class="form-group"><input id="send-link-input" class="form-control" placeholder="Tél. ou Email"></input></div><button type="submit" id="send-link-btn" class="btn btn-default">Envoyer</button></form>'
                             })

  $('#btn-download').on('shown.bs.tooltip',  () ->
    $('button#send-link-btn').click (e) ->
      e.preventDefault()
      val = $("input#send-link-input").val()
      email = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i;
      phoneRegex = /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/;
      if not email.test(val) and not phoneRegex.test(val)
        console.log("fffffff")

  )


  $(window).resize ->
    $("#btn-download").tooltip('hide')








