class Shopelia.Views.Form extends Backbone.View


  render: ->
    @$( 'form' ).parsley
      showErrors: false


    @$('form' ).parsley('addListener',{
      onFieldValidate: ( elem, ParsleyField ) ->
        return
      onFieldError: (elem, constraints, ParsleyField) ->
        $(elem).popover('destroy')
        console.log(constraints)
        $errorMessage = $('<ul class="unstyled"></ul>')
        hasError = false
        _.each(constraints, (constraint,key) ->
          console.log(constraint)
          unless constraint.valid or hasError
            console.log(constraint.requirements + "" + constraint.valid + "  " + constraint.name)
            $(elem).parents(".control-group").removeClass('success')
            $(elem).parents(".control-group").addClass('error')
            $errorMessage.append('<li>'+ getMessageFromConstraint(ParsleyField.Validator.messages,constraint) + '</li>')
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
    this