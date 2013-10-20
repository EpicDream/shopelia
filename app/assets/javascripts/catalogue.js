var Index = {
  init: function() {
    Index.feed = new ProductsFeed("products-feed-fr", Index.dataCallback);
    $('#catalogue-search').on('keyup', function() {
      var query = $(this).val();
      if (query.length > 2) {
        Index.feed.sendQuery(query);
      } else {
        Index.clean();
      }
    });
  },
  dataCallback: function(result) {
    console.log(result);
    var products = result["products"]
    for (var i in products) {
      var product = products[i]
      $("#catalogue-box-" + i).removeClass('display-none');
      $("#catalogue-box-img-" + i).attr('src', product["image_url"]);
      $("#catalogue-box-price-" + i).html(product["price"] / 100 + " €");
      $("#catalogue-box-name-" + i).html(product["name"]);
    }
    for (i = products.length; i < Index.feed.hitsPerPage; i++) {
      $("#catalogue-box-" + i).removeClass('display-none');
      $("#catalogue-box-" + i).addClass('display-none');
    }
    $("#tags-merchant").html(result["tagsMerchant"]);
    $("#tags-category").html(result["tagsCategory"]);
  },
  clean: function() {
    $("#tags-merchant").html("");
    $("#tags-category").html("");
    $("#search-info").html("");
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
