class Shopelia.Views.ModalContent extends Shopelia.Views.Layout

  template: 'modal_content'
  regions: {
    left: "#modal-left",
    right: "#modal-right"
  }

  hide: ->
    $(@el).slideUp('slow')

  show :->
    $(@el).fadeIn('slow')
