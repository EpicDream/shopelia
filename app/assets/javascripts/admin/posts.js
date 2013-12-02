var Show = {
  init: function() {
    sortable();
    monitorCollectionItems();
    postId = $("#post").data("id");
    $("#look-add-urls").on("click", function() {
      showAddUrlsModal();
    });
    $("#look-add-custom").on("click", function() {
      showAddCustomModal();
    });
    $(".img-delete").on("click", function() {
      $(this).parent().hide();
      $(this).parent().html("");
    });
    $(".update-post").on("click", function() {
      $(this).button('loading')
      updatePost(postId, $(this).data('status'));
    });
  }
}

$(document).ready(function() {
  if ($('body.action-show').length > 0) {
    Show.init();
  }
});

function sortable() {
  $('#grid').sortable({
    placeholder: 'placeholder',
    items: '.sort',
    revert: 150,
  });
};
function showAddUrlsModal() {
  $("#look-add-urls-modal").removeClass('hidden');
  $("#look-add-urls-modal").modal('show');
  $('#look-add-urls-confirm').on('click', function() {
    $('#look-add-urls-confirm').button('loading')
    $('#look-add-urls-form').submit();
  });
}
function showAddCustomModal() {
  $("#look-add-custom-modal").removeClass('hidden');
  $("#look-add-custom-modal").modal('show');
  $('#look-add-custom-confirm').on('click', function() {
    $('#look-add-custom-confirm').button('loading')
      lookId = $("#look").data("id");
      feed = {};
      feed["product_url"] = $("#custom-url").val();
      feed["image_url"] = $("#custom-image-url").val();
      feed["name"] = $("#custom-name").val();
      feed["brand"] = $("#custom-brand").val();
      feed["description"] = $("#custom-description").val();
      feed["price"] = $("#custom-price").val();
      feed["price_shipping"] = $("#custom-price-shipping").val();
      feed["shipping_info"] = $("#custom-shipping-info").val();
      feed["saturn"] = "0"
      $.ajax({
        url: "/admin/look_products",
        dataType: "script",
        data: {feed:JSON.stringify([feed]), look_id:lookId},
        type: "post",
        error: function() {
          $('#look-add-custom-confirm').button('reset');
          $("#look-add-custom-modal").modal('hide');
        },
        success: function(data) {
          $('#look-add-custom-confirm').button('reset');
          $("#look-add-custom-modal").modal('hide');
        }
      });        
  });
}
function updatePost(id, status) {
  images = $.map($(".thumb"), function(i) { return i.src })
  $.ajax({
    url: "/admin/posts/" + id,
    dataType: "script",
    data: {status:status, images:images},
    type: "put"
  });
}