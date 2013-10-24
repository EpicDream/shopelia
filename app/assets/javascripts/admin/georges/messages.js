$(document).ready(function() {
    $checkbox = $("#data-checkbox");
    if($checkbox.is(':checked')){
        $('#message_products_urls').show();
    } else {
        $('#message_products_urls').hide();
    }
    $checkbox.on('click', function(){
        var checked = $checkbox.attr('checked');
        $('#message_products_urls').toggle();
        $checkbox.attr('checked', !checked)
    });
});