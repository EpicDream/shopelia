$(document).ready(function() {

  $(document).on("click", "td.staff-hashtag-delete", function(){
    var td = $(this);
    var hashtagID = td.data("id");
    
    $.post("/admin/staff_hashtags/" + hashtagID, {_method:'delete'})
    .success(function(){
      td.parents('tr').remove();
    })
    .error(function(){
      alert("Une erreur s'est produite");
    });
  });
});
