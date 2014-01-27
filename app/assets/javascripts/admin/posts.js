$(document).ready(function() {

  $(document).on("click", "button.look-direct-reject", function() {
    var link = $(this);
    var block = link.parents("section.column");
    var url = "/admin/looks/" + link.data('look-id') + "/reject";
    
    if (!confirm("Rejeter ce look ?")) {
      return;
    }
    
    $.get(url)
    .success(function() {
      block.remove();
    })
    .error(function(){
      alert("Une erreur s'est produite");
    });

  });
  
  $(document).on("change", "select.country-select", function(){
    var countryCode = $(this).val();
    window.location = "/admin/posts?country_code=" + countryCode;
  });
});