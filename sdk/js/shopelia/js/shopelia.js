var ShopeliaCheckout = {
  init: function(options) {
    this.base = "http://zola.epicdream.fr:4444";
    this.options = options;
    this.urlsArray = [];
    this.update();
  },
  bindClickWith: function ($element) {
    $element.click(function(){
      $(this).unbind('click');
      var clickedParams = {type: "click"};
      ShopeliaCheckout.sendUrls($(this),clickedParams);
      ShopeliaCheckout.getProduct($(this));
    });
  },
  update: function() {
    $("[data-shopelia-url]").unbind('click');
    var $shopelia_buttons = $("[data-shopelia-url]");
    if($shopelia_buttons.length > 0) {
      var params = {type: "view"};
      this.sendUrls($shopelia_buttons,params);
    }
    if (this.options.shadow) {
      $shopelia_buttons.addClass('shadowed');
    }
  },
  sendUrls: function($elements,params) {
    that = this;
    urlsTempArray = [];
    params = this.extend(this.options,params);
    $.each($elements,function(){
      var url = $(this).attr("data-shopelia-url");
      that.bindClickWith($(this));
      if((!that.contains(that.urlsArray,url) && !that.contains(urlsTempArray,url)) || (params.type == 'click')) {
        urlsTempArray.push(url);
      }
    });
    var urls =  urlsTempArray.join('||');
    this.extend(params,{urls: urls});
    if(urls != "") {
      if (params.type != "click") {
        that.urlsArray = that.urlsArray.concat(urlsTempArray);
      }
      this.sendEvents(params);
    }
  },
  sendEvents: function(params) {
    return $.ajax({
      type: 'GET',
      url: this.generateEncodedUri(this.base,"/api/events",params) ,
      async: false,
      jsonpCallback: 'jsonCallback',
      contentType: "application/json",
      dataType: 'jsonp'
    });
  },
  contains: function(array,url) {
    for(var i = 0; i < array.length; i++) {
      if(array[i] === url) {
        return true;
      }
    }
    return false;
  },
  getProduct: function($element) {
    var options= {};
    if($element.attr('data-shopelia-url') != undefined && $element.attr('data-shopelia-url') != "") {
      options.url = $element.attr('data-shopelia-url')
    }
    options.developer = this.options.developer;
    this.createLoader();
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
  createLoader: function() {
    var loader = document.createElement('div');
    loader.id = 'loader';
    document.body.appendChild(loader);
    this.center($(loader))
  },
  deleteLoader: function() {
    var loader = document.getElementById("loader");
    loader.parentNode.removeChild(loader);
  },
  center: function($elem) {
    var top = undefined;
    var left = undefined;
    top = Math.max( $(window).height() - $elem.height(), 0) / 2 + $(window).scrollTop()   ;
    left = Math.max( $(window).width() - $elem.outerWidth(), 0) / 2;
    console.log($(window).scrollTop() );
    $elem.css({
      "top": top,
      "left":left
    });
  },
  createIframe: function(options) {
    var overlay = document.createElement('div');
    overlay.id = 'lean_overlay';
    document.body.appendChild(overlay);
    var iframe = document.createElement('iframe');
    iframe.setAttribute("src",this.generateEncodedUri(this.base,"/checkout",options));
    iframe.style.border = "0px #FFFFFF none";
    iframe.id = "shopeliaIframe";
    iframe.name = "shopeliaIframe";
    iframe.scrolling = "yes";
    iframe.frameborder ="0";
    iframe.marginHeight = "0";
    iframe.style.opacity = "0";
    iframe.marginWidth = "0";
    iframe.height = "100%";
    iframe.width = "100%";
    iframe.allowtransparency = "true";
    document.getElementById('lean_overlay').appendChild(iframe);
  },
  generateEncodedUri: function(base,endpoint,params) {
    var uri = base + endpoint;
    i = 0;
    for (var key in params) {
      var value = params[key];
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
    var iframe = document.querySelector("#shopeliaIframe")
      , _window = iframe.contentWindow;
    var body = document.body;
    var bodyClass = body.className;
    body.className += " " + 'overflow-hidden';
    var listener = function(e) {
      if ( e.data === "loaded" && e.origin === iframe.src.split("/").splice(0, 3).join("/")) {
        iframe.style.opacity = '1';
        _window.postMessage(document.location.origin, iframe.src);
        ShopeliaCheckout.deleteLoader();
      } else if (e.data === "deleteIframe" && e.origin === iframe.src.split("/").splice(0, 3).join("/")) {
        window.removeEventListener("message",listener);
        body.className = bodyClass;
        var overlay = document.getElementById("lean_overlay");
        overlay.parentNode.removeChild(overlay);
      }
    };
    window.addEventListener("message",listener);
  }
};
