$(document).ready(function() {
 
  $(document).on("click", "#create-theme-link", function() {
    $("#new-theme-form").toggleClass("new-theme-form-show");
  });
  
  $(document).on("click", "#close-overlay", function(e){
    $("div.theme-edit-overlay").toggle();
    $("div.overlay").toggle();
  });
  
  $(document).on("click", "div.theme-banner", function() {
    var themeID = $(this).data("theme-id");
    var url = "/admin/themes/" + themeID + "/edit";
    
    $(".theme-edit-overlay").load(url, function(){
      $(".theme-edit-overlay").toggle();
      $(".overlay").toggle();
    });
  });
  
});