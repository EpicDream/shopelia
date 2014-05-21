$(document).ready(function() {
  $(".reply-link").on("click", function() {
    var offset = $(this).offset();
    var username = $(this).data('username');
    var commentId = $(this).data('comment-id');

    $("#reply").css("display", "block");
    $("#reply").offset({top:offset.top + 35, left:offset.left - 600});
    $("#reply form textarea").text("@" + username + " ");
    $("#reply form").attr("action", "/admin/comments/" + commentId + "/reply");
  });
  
  $("#new_comment").submit(function(e){
    e.preventDefault();
    
    $.post($(this).attr("action"), $(this).serialize())
    .success(function(){
      window.location.reload();
    })
    .error(function(){
      alert("Erreur");
    });
  });
  
  $("#close-reply").on("click", function(){
    $("#reply").css("display", "none");
  });
});