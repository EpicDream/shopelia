<!-- start Mixpanel -->
(function(e,b){if(!b.__SV){var a,f,i,g;window.mixpanel=b;a=e.createElement("script");a.type="text/javascript";a.async=!0;a.src=("https:"===e.location.protocol?"https:":"http:")+'//cdn.mxpnl.com/libs/mixpanel-2.2.min.js';f=e.getElementsByTagName("script")[0];f.parentNode.insertBefore(a,f);b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==
    typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ");for(g=0;g<i.length;g++)f(c,i[g]);
    b._i.push([a,e,d])};b.__SV=1.2}})(document,window.mixpanel||[]);
mixpanel.init("95c15bf80bf7bf93cb1c673865c75a22");
<!-- end Mixpanel -->

var Tracker = {
  init: function(){
      mixpanel.register({
          "SDK": Shopelia.SDK,
          "SDK Version": Shopelia.SDKVersion
      });
  }
  , onDisplay: function(name) {
        mixpanel.track("Display " + name) ;
    }
  ,onClick: function(name) {
        mixpanel.track("Click On " + name) ;
    }
  , onFocusIn: function(name) {
        mixpanel.track("In " + name) ;
    },
    onValidate: function(name) {
        mixpanel.track("OK " + name) ;
    }, custom: function(name) {
        mixpanel.track(name) ;
    }
};