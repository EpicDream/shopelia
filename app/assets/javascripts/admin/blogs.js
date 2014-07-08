var Heart = {
  box:function(){
    return $("#heart-overlay");
  },
  
  animate:function(offset, callback){
    var box = this.box();
    box.addClass("heart-overlay-show");
    box.offset(offset);
    box.one('webkitAnimationEnd animationend', function() { 
      box.removeClass("heart-overlay-show");
      callback();
    });
  }
};

$(document).ready(function() {

  $(document).on("click", "button[id^=blog-posts]", function() {
    var button = $(this);
    var url = "/admin/blogs/" + button.data('id');
    window.location = url;
  });
  
  $(document).on("click", "button[id^=skip-blog]", function() {
    var button = $(this);
    var blogId = button.data('id');
    $.post("/admin/blogs/" + blogId + '.json', {_method:'put', blog:{skipped:true}})
    .success(function() {
      button.parents("tr").toggle();
    });
  });
  
  $(document).on("click", "#create-blog-link", function() {
    $("#create-blog-block").toggleClass("create-blog-block-shown");
  });
  
  $(document).on("click", "#update-blog-link", function() {
    $("#update-blog-block").toggleClass("update-blog-block-shown");
  });
  
  $(document).on("click", "#name-filter", function() {
    var pattern = $("#name-filer-pattern").val();
    var url = "/admin/blogs?partial=true&page=1" + "&pattern=" + pattern;
    $("#blogs-list").load(url);
  });

  $(document).on("click", "div.pagination a", function(event) {
    event.preventDefault();
    var url = $(this).attr('href');
    url += '&partial=true';
    $("#blogs-list").load(url);
  });
  
  $(document).on("change", "input[name='scope']", function() {
    var scope = $(this).val();
    var url = "/admin/blogs?partial=true&scope=" + scope;
    $("#blogs-list").load(url);
  });
  
  $(document).on("change", "select[name='country']", function() {
    var scope = $("#filtered-blogs").data("current-scope");
    var country = $(this).val();
    var url = "/admin/blogs?partial=true&scope=" + scope + "&country=" + country;
    
    $("#blogs-list").load(url);
  });
  
  $(document).on("click", ".fetch-post-link", function(event) {
    event.preventDefault();
    $.get($(this)[0].href);
    alert("Une tâche a été lançée pour scraper le blog...");
  });
  
  $(document).on("click", "button[id^=integrate-blog]", function() {
    var button = $(this);
    var blogId = button.data('id');
    var offset = button.offset();
    var success = false;
    
    $.post("/admin/blogs/" + blogId + '.json', {_method:'put', blog:{scraped:true}, fetch:true})
    .success(function() {
      success = true;
    });

    Heart.animate({ top: offset.top, left: offset.left + 100 }, function() {
      if (success) { button.parents("tr").toggle(); }
    });
  });
  
});