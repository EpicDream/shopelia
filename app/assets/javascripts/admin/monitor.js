function monitorCartItems() {
  $(".cart-item-monitor").each(function() {
    var pid = $(this).data('pid');
    var uuid = $(this).data('uuid');
    if (window.channels["product-version-" + pid] === undefined) {
      window.channels["product-version-" + pid] = window.pusher.subscribe("product-version-" + pid)
      window.channels["product-version-" + pid].bind("update", function(data) {
        el = $("[data-uuid=" + uuid + "]");
        el.find(".cart-item-spinner").addClass("hidden");
        el.find(".cart-item-img").attr("src", data.image_url);
        el.find(".cart-item-title").html(data.name);
        el.find(".cart-item-price").html(Math.round(data.price * 100) / 100 + " €");
      });
    }
  });
}

function monitorCollectionItems() {
  $(".admin-collection-item-span").off("click");
  $(".admin-collection-item-span").on("click", function() {
    var id = $(this).data('ciid');
    $.ajax({
      url: "/admin/collection_items/" + id,
      dataType: "script",
      type: "delete"
    });
  });
  $(".collection-item-monitor").each(function() {
    var pid = $(this).data('pid');
    if (window.channels["product-" + pid] === undefined) {
      window.channels["product-" + pid] = window.pusher.subscribe("product-" + pid)
      window.channels["product-" + pid].bind("update", function(data) {
        el = $("[data-pid=" + pid + "]");
        el.find(".collection-item-spinner").addClass("hidden");
        el.find(".collection-item-img").attr("src", data.image_url);
        el.find(".collection-item-title").html(data.name);
        el.find(".collection-item-price").html(Math.round(data.price * 100) / 100 + " €");
      });
    }
  });
}

function monitorLookProducts() {
  $(".look-product-delete").off("click");
  $(".look-product-delete").on("click", function() {
    var id = $(this).data('lpid');
    $.ajax({
      url: "/admin/look_products/" + id,
      dataType: "script",
      type: "delete"
    });
  });
  $(".look-product-details").off("click");
  $(".look-product-details").on("click", function() {
    var id = $(this).data('lpid');
    window.location = "/admin/look_products/" + id;
  });
  $(".look-product-update").off("click");
  $(".look-product-update").on("click", function() {
    var id = $(this).data('lpid');
    $("#look-update-code-form").attr('action', '/admin/look_products/' + id);
    showUpdateCodeModal();
  });
  $(".look-product-monitor").each(function() {
    var pid = $(this).data('pid');
    if (window.channels["product-" + pid] === undefined) {
      window.channels["product-" + pid] = window.pusher.subscribe("product-" + pid)
      window.channels["product-" + pid].bind("update", function(data) {
        el = $("[data-pid=" + pid + "]");
        el.find(".look-product-spinner").addClass("hidden");
        el.find(".look-product-img").attr("src", data.image_url);
        el.find(".look-product-title").html(data.name);
        el.find(".look-product-merchant").html(data.merchant.name);
        el.find(".look-product-price").html(Math.round(data.price) + " €");
      });
    }
  });
  function showUpdateCodeModal() {
    $("#look-update-code-modal").removeClass('hidden');
    $("#look-update-code-modal").modal('show');
    $('#look-update-code-confirm').on('click', function() {
      $('#look-update-code-confirm').button('loading')
      $('#look-update-code-form').submit();
    });
  }
}

function showSpinners() {
  var opts = {
    lines: 13,
    // The number of lines to draw
    length: 5,
    // The length of each line
    width: 2,
    // The line thickness
    radius: 6,
    // The radius of the inner circle
    corners: 1,
    // Corner roundness (0..1)
    rotate: 0,
    // The rotation offset
    color: '#000',
    // #rgb or #rrggbb
    speed: 1,
    // Rounds per second
    trail: 60,
    // Afterglow percentage
    shadow: false,
    // Whether to render a shadow
    hwaccel: false,
    // Whether to use hardware acceleration
    className: 'spinner',
    // The CSS class to assign to the spinner
    zIndex: 2e9,
    // The z-index (defaults to 2000000000)
    top: '15px',
    // Top position relative to parent in px
    left: '15px',
    // Left position relative to parent in px
    visibility: true
  };
  // $('.spinner').html(new Spinner(opts).spin().el);
}