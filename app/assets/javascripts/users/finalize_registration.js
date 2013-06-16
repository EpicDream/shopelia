$(document).ready(function() {
  $("#addressButton").on('click', function(event) {
    $('#addressModal').modal('show');
    $('#address_first_name').focus();
  });
});
