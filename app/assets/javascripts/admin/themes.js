var Theme = {
  
  titleWithFontBlock:function(fontName, type, title){
    var title = title || '';
    var type = type || 'title-part';
    var span = "<span class='font-tag'>" + fontName + "</span>";
    var input = "<input class='" + type + "' data-font='" + fontName + "' type='text' value='" + title +"'>";
    
    return span + " " + input;
  },
  
  markupForTitle:function(type){
    var fontSize = $("#" + type + "-fontsize-select").val();
    var markup = "";
    var inputCount = $("." + type + "-block").children('input').length;
    
    $("." + type + "-block").children('input').each(function(index, input){
      var value = input.value;
      var fontName = input.dataset['font'];
      
      if (index < inputCount - 1) {
        value += " ";
      }
      
      markup += "<style font='" + fontName +"' size='" + fontSize + "'>" + value + "</style>";
    });
    
    return markup;
  },
  
  nodesFromTitle:function(title, type){
    var fontRegexp = /font='(.*?)'/g;
    var valueRegexp = />(.*?)<\/style>/g;
    var sizeRegexp = /size='(\d+)'/g;
    var fonts = [];
    var values = [];
    var size = sizeRegexp.exec(title);
    var match = fontRegexp.exec(title);
    var i = 0;
    
    while (match != null) {
      fonts[i] = match[1];
      values[i] = valueRegexp.exec(title)[1];
      i++;
      match = fontRegexp.exec(title);
    }
    
    for (var i = 0; i < fonts.length; i++) {
      $("p." + type + "-block").append(Theme.titleWithFontBlock(fonts[i], type, values[i]));
    }
    
    if (size) {
      $("#" + type + "-fontsize-select").val(size[1]);
    }
  },
  
  rebuildTitlesBlocks:function() {
    Theme.nodesFromTitle($("#theme_title").val(), 'title');
    Theme.nodesFromTitle($("#theme_subtitle").val(), 'subtitle');
  }
};

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
      Theme.rebuildTitlesBlocks();
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
    
    $("#theme_title").val(Theme.markupForTitle('title'));
    $("#theme_subtitle").val(Theme.markupForTitle('subtitle'));

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
  
  $(document).on("change", "#title-font-select", function(){
    $("p.title-block").append(Theme.titleWithFontBlock($(this).val()));
  });
  
  $(document).on("change", "#subtitle-font-select", function(){
    $("p.subtitle-block").append(Theme.titleWithFontBlock($(this).val(), 'subtitle-part'));
  });  
  
  $(document).on("click", "#title-reset", function(){
    $("p.title-block").children().remove();
  });
  
  $(document).on("click", "#subtitle-reset", function(){
    $("p.subtitle-block").children().remove();
  });
  
});