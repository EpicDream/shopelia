function monitorCartItems() {
  if (window.pusher === undefined) {
    window.pusher = new Pusher("654ffe989dceb4af5e03");
    window.channels = [];
  }
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
  if (window.pusher === undefined) {
    window.pusher = new Pusher("654ffe989dceb4af5e03");
    window.channels = [];
  }
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
  $('.spinner').html(new Spinner(opts).spin().el);
}