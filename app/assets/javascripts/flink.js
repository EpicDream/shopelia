//= require jquery.infiniteScroll

$(document).ready(function() {
  $(document).infiniteScroll({
        itemSelector: "img.covr",
        dataPath: "/",
        onDataLoaded: function(page){
          console.log("Loaded - " + page);
        },
        onDataLoading: function(page){
          console.log("Loading - " + page);
        }
      });
});
