$(document).ready(function() {
  
  $(document).on("click", "#close-overlay", function(e){
    $("div.theme-edit-overlay").toggle();
    $("div.overlay").toggle();
    window.location.reload();
  });
  
  $(document).on("click", ".overlay", function(e){
    $("div.theme-edit-overlay").css('display', 'none');
    $("div.theme-looks-images-overlay").css('display', 'none');
    $("div.overlay").css('display', 'none');
  });
  
  $(document).on("click", ".see-theme-images", function(e){
    e.preventDefault();
    $(".theme-looks-images-overlay").load($(this).attr('href'), function(){
      $(".theme-looks-images-overlay").toggle();
      $(".overlay").toggle();
    });
  });
  
  $(document).on("click", ".theme-banner-cover", function(e) {
    e.preventDefault();
    $(".theme-edit-overlay").load($(this).attr('href'), function(){
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
  
  $(document).on("click", "#remove-flinker", function(e){
    e.preventDefault();
    var url = $(this).attr('href');
    
    $.post(url, {_method:'delete'})
    .success(function(html){
      var themeID = $(".edit_theme").data("theme-id");
      $("#flinkers-index-container").replaceWith(html);
      $("#looks-index-container").load("/admin/themes/" + themeID + "/flinkers");
      $('html, body').animate({ scrollTop:0 }, 'slow');
    })
    .error(function(){
      alert("Erreur");
    });
  });
  
  
  $(document).on("submit", ".edit_theme", function(e, data) {
    e.preventDefault();
 
    var form = $(this);
    var themeID = $(this).data('theme-id');

    $.ajax({
        url: form.attr("action"),
        type: "post",
        contentType: false,
        processData: false,
        data: function() {
          var data = new FormData(form.get(0));
          var fileData = $("#theme_theme_cover_attributes_picture").get(0).files[0];
          if (fileData) {
            data.append("theme[theme_cover_attributes][picture]", fileData);
          }
          return data;
        }(),
        error: function(_, textStatus, errorThrown) {
          alert("Erreur");
        },
        success: function(response, textStatus) {
          var url = "/admin/themes/" + themeID + "/edit";
          $(".theme-edit-overlay").load(url, function(){});
        }
    });
  });
  
});