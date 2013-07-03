class Shopelia.Views.Form extends Backbone.View


  render: ->
    console.log('fbffhrhofgho')
    @$( 'form' ).parsley
      showErrors: false


    @$('form' ).parsley('addListener',{
      onFieldValidate: ( elem, ParsleyField ) ->
        return
      onFieldError: (elem, constraints, ParsleyField) ->
        $(elem).popover('destroy')
        console.log(constraints)
        $errorMessage = $('<ul class="unstyled"></ul>')
        _.each(constraints, (constraint,key) ->
          console.log(constraint)
          unless constraint.valid
            console.log(constraint.requirements + "" + constraint.valid + "  " + constraint.name)
            $(elem).parents(".control-group").removeClass('success')
            $(elem).parents(".control-group").addClass('error')
            $errorMessage.append('<li>'+ getMessageFromConstraint(ParsleyField.Validator.messages,constraint) + '</li>')
            $(elem).popover({
                            'trigger' : 'click',
                            'placement': 'top',
                            'html': true,
                            'content': $errorMessage
                            })
            return
        )
      onFieldSuccess:  ( elem, constraints, ParsleyField ) ->
        $(elem).popover('destroy')
        $(elem).parents(".control-group").removeClass('error')
        $(elem).parents(".control-group").addClass('success')
      })
    this