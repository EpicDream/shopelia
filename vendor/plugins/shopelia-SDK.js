// leanModal v1.1 by Ray Stone - http://finelysliced.com.au
// Dual licensed under the MIT and GPL

(function($){
    $.fn.extend({
       leanModal:function(options){
            var defaults={top:100,overlay:0.5,closeButton:null};
            var overlay=$("<div id='lean_overlay'></div>");
           $("body").append(overlay);
            options=$.extend(defaults,options);
            return this.each(
                function(){
                    var o=options;
                    $(this).click(function(e){
                        var modal_id=$(this).attr("href");
                        $("#lean_overlay").click(function(){
                            close_modal(modal_id)
                        });
                        $(o.closeButton).click(function(){
                            close_modal(modal_id)
                        });
                        var modal_height=$(modal_id).outerHeight();
                        var modal_width=$(modal_id).outerWidth();
                        $("#lean_overlay").css({"display":"block",opacity:0});
                        $("#lean_overlay").fadeTo(200,o.overlay);
                        $(modal_id).css({"display":"block","position":"fixed","opacity":0,"z-index":11000,"left":50+"%","margin-left":-(modal_width/2)+"px","top":o.top+"px"});
                        $(modal_id).fadeTo(200,1);e.preventDefault()})
                });
            function close_modal(modal_id){
                $("#lean_overlay").fadeOut(200);
                $(modal_id).css({"display":"none"})}
        }
        ,shopelia: function(options) {
            $('body').append('<div id="container" rel="leanModal" href="#overlay"></div>');
            $('#overlay').leanModal();
            $("#lean_overlay").css({
                "position": "fixed",
                "z-index":"100",
                "top": "0px",
                "left": "0px",
                "height":"100%",
                "width":"100%",
                "z-index":"9999",
                "background-color":"rgba(0, 0, 0, 0.35)"
            });
            console.log(this);
            console.log(options);
            base = "https://www.shopelia.fr/checkout"; //"http://localhost:3000/checkout" //
            uri = base;
            i = 0;
            $.each(options,function(key,value) {
                if(i == 0){
                    uri += "?"
                } else {
                    uri += "&"
                }
                i ++;
                uri += key +"=" + value;
            });
            $('#lean_overlay').append('<div id="modal"></div>');
            var modal =  $('#modal');
            modal.css({
                "width": "100%",
                "height": "100%",
                "position": "fixed",
                "z-index": "999999"
            });
            modal.append('<iframe src=' + encodeURI(uri) + 'style="border:0px #FFFFFF none;" id="shopeliaIframe" name="shopeliaIframe" scrolling="yes" frameborder="0" marginheight="0" marginwidth="0" height="100%" width="100%" allowtransparency="true" ></iframe>');

            window.addEventListener("DOMContentLoaded", function() {

                var iframe = document.querySelector("iframe")
                    , _window = iframe.contentWindow

                window.addEventListener("message", function(e) {
                    if ( e.data === "loaded" && e.origin === iframe.src.split("/").splice(0, 3).join("/")) {
                        _window.postMessage(document.location.origin, iframe.src)
                    } else if (e.data == "deleteIframe" && e.origin === iframe.src.split("/").splice(0, 3).join("/"))
                    {
                        iframe.parentNode.removeChild(iframe);
                        var overlay = document.getElementById("lean_overlay");
                        overlay.parentNode.removeChild(overlay);
                    }
                })

            }, false);
        }

    })
})(window.jQuery || window.Zepto);



