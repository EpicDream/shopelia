//= require ../jquery.infiniteScroll

$(document).ready(function() {
  $(document).infiniteScroll({
    itemSelector: "div.covr",
    dataPath: "/explorer",
    onDataLoaded: function(page){
      console.log("Loaded - " + page);
    },
    onDataLoading: function(page){
      console.log("Loading - " + page);
    }
  });
});
