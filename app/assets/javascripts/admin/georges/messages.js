$(document).ready(function() {
  $checkbox = $("#data-checkbox");
  if($checkbox.is(':checked')) {
    $('#message_products_urls').show();
    $('#checkurls').show();
  } else {
    $('#message_products_urls').hide();
    $('#checkurls').hide();
  }
  $checkbox.on('click', function() {
    var checked = $checkbox.attr('checked');
    $('#message_products_urls').toggle();
    $('#checkurls').toggle();
    $checkbox.attr('checked', !checked)
  });
});

function monitorProducts() {
  if (window.pusher === undefined) {
    window.pusher = new Pusher("654ffe989dceb4af5e03");
    window.channels = [];
  }
  $(".product-monitor").each(function() {
    var pid = $(this).data('pid');
    if (window.channels["product-" + pid] === undefined) {
      window.channels["product-" + pid] = window.pusher.subscribe("product-" + pid)
      window.channels["product-" + pid].bind("update", function(data) {
        console.log("Channel " + pid);
        console.log(data);
        el = $("[data-pid=" + pid + "]");
        el.find(".product-spinner").addClass("hidden");
        el.find(".product-img").attr("src", data.image_url);
        el.find(".product-title").html(data.name);
        el.find(".product-price").html(Math.round(data.versions[0]["price"] * 100) / 100 + " €");
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
  $('.spinner').after(new Spinner(opts).spin().el);
}