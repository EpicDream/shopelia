class Shopelia.Views.ModalContent extends Shopelia.Views.Layout

  template: 'modal_content'
  className: "row-fluid"
  regions: {
    left: "#modal-left",
    right: "#modal-right"
    top: "#modal-top-bar"
    bottom: "#modal-bottom-bar"
  }

  hide: ->
    $(@el).fadeOut('slow')

  show :->
    $(@el).fadeIn('slow')
