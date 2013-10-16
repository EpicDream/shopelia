var Index = {
  init: function() {
    $('#addProducts').on("click", function(event) {
      $('#addProductsModal').modal('show');
      $('#productsFormConfirm').on('click', function() {
        $('#productsForm').submit();
      });
    });
  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  }
});
