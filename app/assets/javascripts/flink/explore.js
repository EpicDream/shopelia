//= require ../lib/jquery.infiniteScroll

$(document).ready(function() {
  var category = $("div.flink-menu").data("category");

  $(document).infiniteScroll({
    itemSelector: "a.cover",
    dataPath: "/explore/" + category,
    onDataLoaded: function(page){
      var script = document.createElement("script");
      var links = document.querySelectorAll(".looks-covers a");
      var a = links[links.length - 1];
      
      script.type = "text/javascript";
      script.src = "http://ib.3lift.com/ttj?inv_code=flink_main_feed";
      a.parentNode.insertBefore(script, a);
    },
    onDataLoading: function(page){
    }
  });
});
