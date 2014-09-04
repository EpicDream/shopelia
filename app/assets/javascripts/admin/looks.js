var Show = {
  init: function() {
    sortable();
    monitorLookProducts();
    showSpinners();
    $("#look-add-urls").on("click", function() {
      showAddUrlsModal();
    });
    $("#look-add-codes").on("click", function() {
      showAddCodesModal();
    });
    $("#look-add-custom").on("click", function() {
      showAddCustomModal();
    });
    $(".img-delete").bind('ajax:complete', function() {
      $(this).parent().hide();
    });
  }
}

var Hashtags = {
  submit: function(){
    var form = $("form.edit_look");
    var url = form.attr('action');
    
    $.post(url, form.serialize())
    .success(function(html){
      $("div.hashtags-block").replaceWith(html);
    })
    .error(function(){
      alert("Erreur");
    });
  },
  
  add_from_staff_hashtags: function(ids){
    var lookId = $("div.hashtags-block").data("look-id");
    
    $.post("/admin/looks/" + lookId + "/add_hashtags_from_staff_hashtags", {_method : 'post', staff_hashtag_ids: ids})
    .success(function(html){
      $(".staff-hashtags-popup").modal('hide');
      $("div.hashtags-block").replaceWith(html);
    })
    .error(function(){
      alert("Erreur");
    });
    
  },
  
  highlight: function(checkbox){
    var lookId = $("div.hashtags-block").data("look-id");
    var hashtagId = checkbox.data("hashtag_id");
    var isHighlighted = checkbox.is(":checked");

    $.post("/admin/looks/" + lookId + "/highlight_with_tag", {_method : 'put', hashtag_id: hashtagId, highlight:isHighlighted})
    .success(function(html){
      $("div.hashtags-block").replaceWith(html);
    })
    .error(function(){
      alert("Erreur");
    });
  }
}

var PureShopping = {
  load: function(lookProductId, categoryId, keyword){
    var box = $("#pure-shopping-products-" + lookProductId);
    categoryId = categoryId || '';
    keyword = escape(keyword || '');
    var query = "?look_product_id=" + lookProductId + "&category_id=" + categoryId + "&keyword=" + keyword
    
    $(".css-spinner").show();
    box.load("/admin/pure_shopping_products" + query, function(text, status, xhr){
      $(".css-spinner").hide();
    });
  },
  create: function(lookProductId, pureShoppingProductId, isSimilar, callback){
    var params = { product_id: pureShoppingProductId, look_product_id: lookProductId, similar: isSimilar };
    
    $.post("/admin/pure_shopping_products", params)
    .success(function(){
      callback(true);
    })
    .error(function(){
      callback(false);
    })
  }
}

$(document).ready(function() {
  if ($('body.action-show').length > 0) {
    Show.init();
  }
  
  $(document).on("change", "#assign-to-theme", function(){
    var themeID = $(this).val();
    var lookID = $(this).data("look-id");
    var url = "/admin/themes/" + themeID + "/looks";
    
    if (themeID) {
      $.post(url, { look_id: lookID, contentType:"application/json; charset=utf-8" })
      .error(function() {
        alert("Erreur");
      });
    }
  });
  
  $(document).on("change", ".hashtag-destroy-checkbox", function(){
    Hashtags.submit();
  });
  
  $(document).on("change", "div.hashtags-block select", function(){
    Hashtags.submit();
  })
  
  $(document).on("change", ".hashtag-highlighted-checkbox", function(){
    Hashtags.highlight($(this));
  });

  $(document).on("change", "#look_staff_pick", function(){
    Hashtags.submit();
  });
  
  $(document).on('DOMNodeInserted', '#look-products', function(e) {
    var object = $(e.target);
    if (object.attr("class") === "look-product") {
      var lookProductId = object.data('look-product-id');

      PureShopping.load(lookProductId);
    }
  });

  $(document).on('click', '.pure-shopping-refresh', function() {
    var lookProductId = $(this).parents("div.look-product").data('look-product-id');
    
    $("#pure-shopping-products-" + lookProductId).removeClass('hidden');
    $("#pure-shopping-products-" + lookProductId).modal('show');
    
    PureShopping.load(lookProductId);
  });

  $(document).on('click', '.add-pure-shopping-product', function() {
    var line = $(this).parents("tr");
    var lookProductId = line.data("look-product-id");
    var pureShoppingProductId = line.data("pure-shopping-id");
    var isSimilar = $("#similar-" + pureShoppingProductId).is(":checked");
    var productsBox = $("#similar-products-" + lookProductId);
    
    PureShopping.create(lookProductId, pureShoppingProductId, isSimilar, function(success){
      if (success) {
        line.css({"background" : "#C7EECE"});
        productsBox.load("/admin/vendor_products?look_product_id=" + lookProductId);
      }
      else{
        line.css({"background" : "red"});
      }
    });
  });
  
  $(document).on('click', '#ps_filter_button', function() {
    var lookProductId = $(this).data('look-product-id');
    var categoryId = $("#ps_category_filter").val();
    var keyword = $("#ps_keyword").val();
    
    
    PureShopping.load(lookProductId, categoryId, keyword);
  });
  
  $(document).on('click', 'button#staff-hashtags-button', function() {
    $(".staff-hashtags-popup").removeClass('hidden');
    $(".staff-hashtags-popup").modal('show');
  });

  $(document).on('click', 'span.staff-hashtag', function() {
    var checked = $(this).attr("data-checked") === "1";

    if (checked) {
      $(this).css({color: "black", 'font-size': "12px"});
      $(this).attr("data-checked", "0");
    }
    else{
      $(this).css({color: "#991754", 'font-size': "14px"});
      $(this).attr("data-checked", "1");
    }
  });
  
  $(document).on('click', 'button#staff-hashtags-submit', function(){
    var selectedHashtagsIds = [];
    
    $.map($("span.staff-hashtag[data-checked='1']"), function(hashtag){
      var id = hashtag.getAttribute('data-id');

      selectedHashtagsIds.push(id);
    });
    
    Hashtags.add_from_staff_hashtags(selectedHashtagsIds);
  });
  
  $(document).on('click', '.similar-product-form-element', function() {
    console.log($(this));
    $(this).parents('form').submit();
  });
  
  
});

function sortable() {
  $('#grid').sortable({
    placeholder: 'placeholder',
    items: '.sort',
    revert: 150,
    update: function(event, ui) {
      var orders = {};
      $(".img-block").each(function (index, node) {
        var item = $(node);
        var obj = {};
        obj[item.data("id")] = item.index() - 1;
        orders = $.extend(orders, obj );
      });
      var id = $(ui.item).data("id");
      var index = ui.item.index() - 1;
      $.ajax({
        url: "/admin/look_images/" + id,
        dataType: "json",
        data: {look_image:{display_orders:orders}},
        type: "put"
      })
      .fail(function(jqXHR, textStatus, errorThrown){
         $('#grid').sortable("cancel");
         alert("Une erreur s'est produite lors de la mise à jour de la position");
      });              
    }
  });
};
function showAddUrlsModal() {
  $("#look-add-urls-modal").removeClass('hidden');
  $("#look-add-urls-modal").modal('show');
  $('#look-add-urls-confirm').on('click', function() {
    $('#look-add-urls-confirm').button('loading')
    $('#look-add-urls-form').submit();
  });
}
function autocompleteBrands(selector) {
  var brands = $("#look-add-codes-modal").data("brands");
	$(selector).autocomplete({ source:brands});
}
function showAddCodesModal() {
  autocompleteBrands("input[id^='brand-']");
  $("#look-add-codes-modal").removeClass('hidden');
  $("#look-add-codes-modal").modal('show');
  $('#look-add-codes-confirm').on('click', function() {
    $('#look-add-codes-confirm').button('loading')
    lookId = $("#look").data("id");
    codes = []
    for (i = 0; i < 10; i++) {
      item = {}
      item["code"] = $("#code-" + i).val();
      item["brand"] = $("#brand-" + i).val();
      codes.push(item);
    }
    $.ajax({
      url: "/admin/look_products",
      dataType: "script",
      data: {codes:JSON.stringify(codes), look_id:lookId},
      type: "post",
      success:function(){
        Hashtags.submit();
      }
    });     
  });
}
function showAddCustomModal() {
  $("#look-add-custom-modal").removeClass('hidden');
  $("#look-add-custom-modal").modal('show');
  $('#look-add-custom-confirm').on('click', function() {
    $('#look-add-custom-confirm').button('loading')
      lookId = $("#look").data("id");
      feed = {};
      feed["product_url"] = $("#custom-url").val();
      feed["image_url"] = $("#custom-image-url").val();
      feed["name"] = $("#custom-name").val();
      feed["brand"] = $("#custom-brand").val();
      feed["description"] = $("#custom-description").val();
      feed["price"] = $("#custom-price").val();
      feed["price_shipping"] = $("#custom-price-shipping").val();
      feed["shipping_info"] = $("#custom-shipping-info").val();
      feed["saturn"] = "0"
      $.ajax({
        url: "/admin/look_products",
        dataType: "script",
        data: {feed:JSON.stringify([feed]), look_id:lookId},
        type: "post"
      });        
  });
}