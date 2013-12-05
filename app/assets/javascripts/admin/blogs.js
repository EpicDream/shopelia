$(document).ready(function() {
      
  $("input[name='scope']").on("change", function () {
    var scope = $(this).val();
    $("#blogs-list").load("/admin/blogs?partial=true&scope=" + scope);
  });
  
  $(".fetch-post-link").on("click", function(event) {
    event.preventDefault();
    $.get($(this)[0].href);
    alert("Une tâche a été lançée pour scraper le blog...");
  });
  
  $("button[id^=integrate-blog]").on("click", function() {
    var button = $(this);
    var blogId = button.data('id');
    var offset = button.offset();
    var heart = $("#heart-overlay");
    
    $.get("/admin/blogs/" + blogId, {fetch:true});
    heart.addClass("heart-overlay-show");
    heart.offset({ top: offset.top, left: offset.left + 100 });
    heart.one('webkitAnimationEnd animationend', function() { 
      heart.removeClass("heart-overlay-show");
      button.toggle();
    }); 
    
  });
  
});