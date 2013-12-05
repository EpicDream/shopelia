function reloadWithScope(url) {
  $("#blogs-list").load(url, function() {
    ajaxPaginationEvent();
  });
}

function ajaxPaginationEvent() {
  $("div.pagination").on("click", "a", function(event) {
    event.preventDefault();
    var url = $(this).attr('href');
    reloadWithScope(url);
  });
}

$(document).ready(function() {
  ajaxPaginationEvent();
  
  $("input[name='scope']").on("change", function() {
    var scope = $(this).val();
    var url = "/admin/blogs?partial=true&scope=" + scope;
    reloadWithScope(url);
  });
  
  $(".fetch-post-link").on("click", function(event) {
    event.preventDefault();
    $.get($(this)[0].href);
    alert("Une tâche a été lançée pour scraper le blog...");
  });
  
  $("button[id^=blog-posts]").on("click", function() {
    var button = $(this);
    var url = "/admin/blogs/" + button.data('id');
    window.location = url;
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