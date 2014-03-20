$(document).ready(function() {
 
  $(document).on("click", "#create-theme-link", function() {
    $("#new-theme-form").toggleClass("new-theme-form-show");
  });
  
  $(document).on("click", "div.theme-banner", function() {
    var themeID = $(this).data("theme-id");
    var url = "/admin/themes/" + themeID + "/edit";
    
    $(".theme-edit-overlay").load(url)
    .success(function(){
      $(".theme-edit-overlay").toggle();
      $(".overlay").toggle();
    });
  });
  
  $(document).on("click", "#close-overlay", function(){
    $(".theme-edit-overlay").toggle();
    $(".overlay").toggle();
  });
  
});