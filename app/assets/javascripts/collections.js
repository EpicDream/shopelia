var Show = {
  init: function() {
    var algolia = new AlgoliaSearch("JUFLKNI0PS", '03832face9510ee5a495b06855dfa38b');
    var index = algolia.initIndex('products-feed-fr-new');
    var hitsPerPage = 40;
    $('#catalogue-algolia').on('keyup', function() {
      var query = $(this).val();
      if (query.length > 2) {
        index.search(query, function(success, content) {
          var tags = {};
          for (var i in content.hits) {
            result = content.hits[i]
            $("#catalogue-box-" + i).removeClass('display-none');
            $("#catalogue-box-img-" + i).attr('src', result["image_url"]);
            $("#catalogue-box-price-" + i).html(result["price"] / 100 + " €");
            $("#catalogue-box-name-" + i).html(result["name"]);
            for (var j in result["_tags"]) {
              tag = result["_tags"][j]
              if (!tag.match("^ean")) {
                tags[tag] = (tags[tag] || 0) + 1;
              }
            }
          }
          var tuples = [];
          for (var key in tags) tuples.push([key, tags[key]]);
          tuples.sort(function(a, b) {
            a = a[1];
            b = b[1];
            return a < b ? 1 : (a > b ? -1 : 0);
          });
          var tags_category_html = "";
          var tags_merchant_html = "";
          for (var i = 0; i < tuples.length; i++) {
            var tag = tuples[i][0];
            if (tag.match("^merchant_name")) {
              tags_merchant_html += "<span class='label label-warning'>" + tag.replace('merchant_name:', '') + "</span> ";
            } else {
              tags_category_html += "<span class='label label-default'>" + tag + "</span> ";
            }
          }
          $("#tags_merchant").html(tags_merchant_html);
          $("#tags_category").html(tags_category_html);
          for (i = content.hits.length; i < hitsPerPage; i++) {
            $("#catalogue-box-" + i).removeClass('display-none');
            $("#catalogue-box-" + i).addClass('display-none');
          }
        }, {'hitsPerPage': hitsPerPage});
      } else {
        $("#tags_merchant").html("");
        $("#tags_category").html("");
        for (i = 0; i < hitsPerPage; i++) {
          $("#catalogue-box-" + i).removeClass('display-none');
          $("#catalogue-box-" + i).addClass('display-none');
        }        
      }
    });
  }
}

$(document).ready(function() {
  if ($('body.action-show').length > 0) {
    Show.init();
  }
});
