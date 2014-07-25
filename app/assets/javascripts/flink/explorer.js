//= require ../jquery.infiniteScroll

$(document).ready(function() {
  $(document).infiniteScroll({
    itemSelector: "a.cover",
    dataPath: "/explorer",
    onDataLoaded: function(page){
    },
    onDataLoading: function(page){
    }
  });
});
