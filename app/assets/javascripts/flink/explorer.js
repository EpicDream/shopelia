//= require ../jquery.infiniteScroll

$(document).ready(function() {
  var category = $("div.flink-menu").data("category");

  $(document).infiniteScroll({
    itemSelector: "a.cover",
    dataPath: "/explorer/" + category,
    onDataLoaded: function(page){
    },
    onDataLoading: function(page){
    }
  });
});
