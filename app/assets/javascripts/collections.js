var Show = {
  init: function() {
    algolia = new AlgoliaSearch("JUFLKNI0PS", '03832face9510ee5a495b06855dfa38b'),
    index = algolia.initIndex('products-production');
    hitsPerPage = 12;
    $('#catalogue-algolia').on('keyup', function() {
      query = $(this).val();
      index.search(query, function(success, content) {
        console.log(query);
        console.log(content.hits.length);
        for (var i in content.hits) {
          result = content.hits[i]
          $("#catalogue-box-" + i).removeClass('display-none');
          $("#catalogue-box-img-" + i).attr('src', result["image_url"]);
          $("#catalogue-box-price-" + i).html(result["price"] / 100 + " €");
        }
        for (i = content.hits.length; i < hitsPerPage; i++) {
          $("#catalogue-box-" + i).removeClass('display-none');
          $("#catalogue-box-" + i).addClass('display-none');
        }
      }, {'hitsPerPage': hitsPerPage});
    });
  }
}

$(document).ready(function() {
  if ($('body.action-show').length > 0) {
    Show.init();
  }
});
