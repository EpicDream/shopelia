// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require fastclick
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require lib/spin
//= require lib/pusher.min
//= require lib/algoliasearch.min
//= require lib/bootstrap-paginator.min
//= require monitor
//= require products-feed

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
  $(".fade-area").hover(
    function() {
      $(this).find("a").each(function() {
        $(this).fadeIn(100);
      })
    },
    function() {
      $(this).find("a").each(function() {
        $(this).fadeOut(100);
      })
    } 
  );
  //showSpinners();
  //monitorCartItems();
});

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
        console.log("Channel " + pid);
        console.log(data);
        el = $("[data-uuid=" + uuid + "]");
        el.find(".cart-item-spinner").addClass("hidden");
        el.find(".cart-item-img").attr("src", data.image_url);
        el.find(".cart-item-title").html(data.name);
        el.find(".cart-item-price").html(Math.round(data.price * 100) / 100 + " €");
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