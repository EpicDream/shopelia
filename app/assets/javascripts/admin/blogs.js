$(document).ready(function() {
  $("#select-blog-url").on("change", function () {
    var blogId = $(this).val()
    window.location = "/admin/blogs/" + blogId
  })
});