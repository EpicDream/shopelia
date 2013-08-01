class Shopelia.Views.Form extends Shopelia.Views.ShopeliaView

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)

  onRender: ->
    that = this
    @$('form :input').each(() ->
      $(this).focusout(() ->
        if $(this).attr('tracker-name') != undefined &&  $(this).parsley('validate')
          Tracker.onValidate($(this).attr('tracker-name'))
          $(this).unbind('focusout')
      )

      $(this).focusin(() ->
        if $(this).attr('tracker-name') != undefined
          Tracker.onFocusIn($(this).attr('tracker-name'))
          $(this).unbind('focusin')
      )
    )


    @$( 'form' ).parsley
      showErrors: false


    @$('form' ).parsley('addListener',{
      onFieldValidate: ( elem, ParsleyField ) ->
        return
      onFieldError: (elem, constraints, ParsleyField) ->
        $(elem).popover('destroy')
        $errorMessage = $('<ul class="unstyled"></ul>')
        hasError = false
        _.each(constraints, (constraint,key) ->
          unless constraint.valid or hasError
            $(elem).parents(".control-group").removeClass('success')
            $(elem).parents(".control-group").addClass('error')
            $errorMessage.append('<li>'+ getMessageFromValidator(ParsleyField.Validator,constraint) + '</li>')
            $(elem).popover({
                            'trigger' : 'focus',
                            'placement': 'top',
                            'html': true,
                            'content': $errorMessage
                            })
            hasError = true

        )

      onFieldSuccess:  ( elem, constraints, ParsleyField ) ->
        isValid = true
        _.each(constraints, (constraint,key) ->
           isValid = isValid && constraint.valid
        )
        if isValid
          $(elem).popover('destroy')
          $(elem).parents(".control-group").removeClass('error')
          $(elem).parents(".control-group").addClass('success')

      })

    @$('form :button').after(
      () ->
        securityView = new Shopelia.Views.Security(parent: that)
        $(securityView.render().el)
    )
