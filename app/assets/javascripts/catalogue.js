var Index = {
  init: function() {
    Index.feed = new ProductsFeed("products-feed-fr-new", Index.dataCallback, Index.tagsCallback);
    $('#catalogue-search').on('keyup', function() {
      var query = $(this).val();
      if (query.length > 2) {
        Index.feed.sendQuery(query);
      } else {
        Index.clean();
      }
    });
  },
  dataCallback: function(success, content) {
    console.log(content);
    $("#search-info").html(content["nbHits"] + " résultats");
    for (var i in content.hits) {
      result = content.hits[i]
      $("#catalogue-box-" + i).removeClass('display-none');
      $("#catalogue-box-img-" + i).attr('src', result["image_url"]);
      $("#catalogue-box-price-" + i).html(result["price"] / 100 + " €");
      $("#catalogue-box-name-" + i).html(result["name"]);
    }
    for (i = content.hits.length; i < Index.feed.hitsPerPage; i++) {
      $("#catalogue-box-" + i).removeClass('display-none');
      $("#catalogue-box-" + i).addClass('display-none');
    }
  },
  tagsCallback: function(success, content) {
    var result = Index.feed.parseTags(content);
    $("#tags-merchant").html(result["tagsMerchant"]);
    $("#tags-category").html(result["tagsCategory"]);
  },
  clean: function() {
    $("#tags-merchant").html("");
    $("#tags-category").html("");
    for (i = 0; i < Index.feed.hitsPerPage; i++) {
      $("#catalogue-box-" + i).removeClass('display-none');
      $("#catalogue-box-" + i).addClass('display-none');
    } 
  }
}

$(document).ready(function() {
  if ($('body.action-index').length > 0) {
    Index.init();
  }
});
