var Index = {
  init: function() {
    $('#addProducts').on("click", function(event) {
      $('#addProductsModal').modal('show');
      $('#productsFormConfirm').on('click', function() {
        $('#productsForm').submit();
      });
    });
    $('.link-delete').on("click", function(event) {
      var url = $(this).attr('data-url');
      $('#deleteProductModal').off();
      $('#deleteProductConfirm').on("click", function(event){
        $.ajax({
          url: url,
          dataType: "json",
          type : "delete",
          contentType: "application/json",
          error: function(data) {
            window.location.reload();
            $('#deleteProductModal').modal('hide');
          },
          success: function(data) {
            window.location.reload();
            $('#deleteProductModal').modal('hide');
          }
        });
      });
      $('#deleteProductModal').modal('show');
    });

  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  }
});
