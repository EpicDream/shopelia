var ShopeliaCheckout = {
    init: function(options) {
        var base = "https://www.shopelia.fr/checkout";
        this.extend(options, {base:base});
        this.createIframe(options);
        this.handleIframe(options);

    },
    extend: function (){
        for(var i=1; i<arguments.length; i++)
            for(var key in arguments[i])
                if(arguments[i].hasOwnProperty(key))
                    arguments[0][key] = arguments[i][key];
        return arguments[0];
    },
    createIframe: function(options) {
        console.log("create iframe");
        var overlay = document.createElement('div');
        overlay.id = 'lean_overlay';
        document.body.appendChild(overlay);
        [].forEach.call( document.querySelectorAll('#lean_overlay'), function(el) {
            el.style.position = 'fixed';
            el.style.top = '0px';
            el.style.left = '0px';
            el.style.height = '100%';
            el.style.width = '100%';
            el.style.zIndex = '10000';
            el.style.backgroundColor = 'rgba(0, 0, 0, 0.35)';
        });
        console.log(document.getElementById('lean_overlay'));
        var iframe = document.createElement('iframe');
        iframe.setAttribute("src",this.generateEncodedUri(options));
        iframe.style.border = "0px #FFFFFF none";
        iframe.id = "shopeliaIframe";
        iframe.name = "shopeliaIframe";
        iframe.scrolling = "yes";
        iframe.frameborder ="0";
        iframe.marginHeight = "0";
        iframe.marginWidth = "0";
        iframe.height = "100%";
        iframe.width = "100%";
        iframe.allowtransparency = "true";
        document.getElementById('lean_overlay').appendChild(iframe);
    },
    generateEncodedUri: function(options) {
        var uri = options.base;
        i = 0;

        for (var key in options['product']) {
            var value = options['product'][key];
            if(i == 0){
                uri += "?"
            } else {
                uri += "&"
            }
            i ++;
            uri += key +"=" + encodeURIComponent(value);
        }
        return uri
    },
    handleIframe: function(options) {
        console.log("handleIframe begins");
        var iframe = document.querySelector("#shopeliaIframe")
            , _window = iframe.contentWindow;

        var listener =  function(e) {
            if ( e.data === "loaded" && e.origin === iframe.src.split("/").splice(0, 3).join("/")) {
                _window.postMessage(document.location.origin, iframe.src);
            } else if (e.data === "deleteIframe" && e.origin === iframe.src.split("/").splice(0, 3).join("/"))
            {
                window.removeEventListener("message",listener);
                console.log("1");
                var overlay = document.getElementById("lean_overlay");
                overlay.parentNode.removeChild(overlay);
            }
        };

        window.addEventListener("message",listener);

    }
};
