$(document).ready(function() {
  
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
  
  $(document).on("click", "#remove-look", function(e){
    e.preventDefault();
    var url = $(this).attr('href');
    
    $.post(url, {_method:'delete'})
    .success(function(html){
      $("#looks-index-container").replaceWith(html);
    })
    .error(function(){
      alert("Erreur");
    });
  });
  
});