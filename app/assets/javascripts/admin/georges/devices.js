$(document).ready(function() {
  $(".user-row").click(function() {
    $(".user-row").removeClass('user-row-select');
    $(this).toggleClass('user-row-select');
  });

  // Georges sync using Pusher lib
  if (window.pusher === undefined) {
    window.pusher = new Pusher("654ffe989dceb4af5e03");
    window.channels = [];
  }
  lobby = window.pusher.subscribe("georges-lobby")
  lobby.bind("refresh", function(data) {
    setTimeout(function() {
      $.ajax({
        url: "/admin/georges/devices/lobby",
        dataType: "script"
      });      
    }, 2000);
  });
});