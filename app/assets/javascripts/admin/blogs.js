$(document).ready(function() {
  
  $("#select-blog-url").on("change", function () {
    var blogId = $(this).val();
    window.location = "/admin/blogs/" + blogId;
  })
  
  $(".fetch-post-link").on("click", function(event) {
    event.preventDefault();
    $.get($(this)[0].href)
    alert("Une tâche a été lançée pour scraper le blog...")
  })
  
});