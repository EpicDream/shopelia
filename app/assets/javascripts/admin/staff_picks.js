$(document).ready(function() {
  
  $(document).on("change", ".staff-pick-unpick", function(){
    var form = $(this).parents("form");
    var url = form.attr("action");
    var tr = $(this).parents("tr");
    
    $.post(url, form.serialize())
    .success(function(){
      tr.remove();
    })
    .error(function(){
      alert("Erreur");
    });
  });
  
});
