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
      $('button#send-link-btn').click (e) ->
        e.preventDefault()
        val = $("input#send-link-input").val()
        email = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
        phoneRegex = /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/
        if email.test(val)
          data = {email: val}
        else if phoneRegex.test(val)
          if val.substr(0,1) is "+" or val.substr(0,2) is "00"
            data = {phone_number: val}
          else if val.substr(0,2) is "06" or val.substr(0,2) is "07"
            val = "0033" + val.substr(1)
            data = {phone_number: val}
        else
          $("#sendAppInvalidEntryModal").modal()

        unless data is undefined
          $("#send-link-btn").button("loading")
          $.ajax({
            type: "GET",
            url: 'send_text_message',
            data: data,
            dataType: 'json',
            success: ->
              $btnDownload.tooltip('hide')
              $("#send-link-btn").button("reset")
              $("#sendAppSuccessModal").modal()
              setTimeout(() ->
                $(window).trigger('resize');
              , 3000)
            error: ->
              $("#sendAppErrorModal").modal()
              $("#send-link-btn").button("reset")
          })










