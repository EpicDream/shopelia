$(document).ready(function() {
  $(document).on("change", "#assign-to-theme", function(){
    var themeID = $(this).val();
    var lookID = $(this).data("look-id");
    var url = "/admin/themes/" + themeID + "/looks";
  
    if (themeID) {
      $.post(url, { look_id: lookID, contentType:"application/json; charset=utf-8" })
      .error(function() {
        alert("Erreur");
      });
    }
  });
});
