$(document).ready(function() {
  $(".modal-button").on('click', function(event) {
    event.preventDefault();
    id = $(this).attr('target-modal');
    $('#' + id).find('.modal-content').load($(this).attr('target-url'));
    $('#' + id).modal('show').on('shown', function() {
      $(ClientSideValidations.selectors.forms).validate();
      $(this).unbind('shown');
    });
  });
});
var Callback = {
  success: function(type) {
    if (type == 'address') {
      $("#mainContent").load('home?no_layout=1');
      $("#addressModal").modal('hide');
    } else if (type == 'card') {
      $("#mainContent").load('home?no_layout=1');
      $("#cardModal").modal('hide');
    }
  }
}

