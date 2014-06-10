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
  
  $(document).on("submit", "form.edit_look", function(e){
    e.preventDefault();
    Hashtags.submit();
  });
  
  $(document).on("change", ".hashtag-destroy-checkbox", function(){
    Hashtags.submit();
  });
  
  $(document).on("change", "div.hashtags-block select", function(){
    Hashtags.submit();
  })
  
  $(document).on("change", ".hashtag-highlighted-checkbox", function(){
    Hashtags.submit();
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