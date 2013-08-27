Ariane Chromium Extension
=========================

Ariane is a Chromium plugin used to indicate where to find information on a product url.

Indeed, Viking/Saturn need a mapping to extract information.
For the moment this mapping have to be precise by a humain operator, via Ariane.

Installation
------------

Download the ariane.crx extension file, and drop it in the Google-Chrome window.

Usage
-----

It is composed of a toolbar on top of the webpage.

To indicate where to find informations, the operator select the field in the toolbar, and click on the corresponding element on the page with the Ctrl key hold.

The matched element is highlight. If the matching is good he can pass to the next field.

When finished, it can click on the 'Finished' button.

Developpers
-----------

There are three main files :

- background.js
- toolbar_contentscript.js
- mapping_contentscript.js

### background.js

It's the logic piece of the program.
It communicate with the server, load the pages and the contentscript.

Common scenario :

1. background ask for a website to map ;
2. it load the product url ;
3. it load the toolbar ;
4. foreach field in the toolbar :
  5. the operator select it ;
  6. the operator click on it in the page ;
  7. the element is highlight ;
  8. if the mapping is false, retry by clicking on a different place.
  9. if the mapping is good, pass to the next field.
10. when all fields are mapped, the operator click on 'Finished'.
10bis. if there is a problem, he can 'Abort' the mapping.
12. It restart to step 1.

### toolbar_contentscript.js

It load the toolbar and build it.

It handles the 'Finished' and the 'Abort' buttons.

### mapping_contentscript.js

It captures operator's click, the context of the clicked element, and send it to the background.

TODO List
---------

Améliorer le merge : quand nouveaux éléments à la fin de mergeMapping(), popup avec tous les résultats et les choix.

Add css to add dashed border on all blocks in the page's body.

      // on body elements hover, border them.
      // var borderStyle = {border: "dashed red", "border-width": "1px 0px"};
      // $("body *").each(function() {
      //   var e = $(this);
      //   e.data("oldBorder", e.css("border"))
      // }).hover(function(event) {
      //   if (event.target != this) return;
      //   console.log("in", this.tagName, event);
      //   // on border l'élém sur lequel on vient d'entrer
      //   $(this).css(borderStyle);
      //   // on enlève le border de l'élément qu'on quitte
      //   var related = $(event.relatedTarget);
      //   related.css("border", related.data("oldBorder"));
      // }, function(event) {
      //   if (event.target != this) return;
      //   console.log("out", this.tagName, event);
      //   // on enlève le border de l'élément qu'on quitte
      //   if (event.target != this) return;
      //   var e = $(this);
      //   e.css("border", e.data("oldBorder"));
      //   // on border l'élém sur lequel on vient d'entrer
      //   $(event.relatedTarget).css(borderStyle);
      // });

      // var elemBorder = $("<div id='ariane-floated-border'>").css({position:"fixed", border: '1px dashed red'});
      // $("body").append(elemBorder);
      // $("body *:not(#ariane-floated-border)").hover(function(event) {
      //   if (event.target != this) return;
      //   var e = $(event.target);
      //   console.log(e, event);
      //   elemBorder.width(e.width()).height(e.height()).offset(e.offset()).css('z-index', parseInt(e.css('z-index'))+1);
      // });

Use require.js.

On toolbar button hover, show matched element(s), in body.
      // b.hover((function(elems) return function(event) {
      //   elems.effect("highlight", {color: "#00cc00" }, "slow");
      // })(mappingRes[key]));

See pageAction to replace browserAction.

Add a panel at the right of the page, like the first mapper extension.
This panel, that we will be hidable, will be used to edit paths.
It will be the editPathPage of the mapper.
We will see the current prod mapping if available, the current new mapping, and possibly other previous mapping.

Add a (button?) to call saturn for this page and this mapping and see the result.
Can use an inter extension message.
// else if (msg.act == 'crawl') {
//    chrome.runtime.sendMessage("nhledioladlcecbcfenmdibnnndlfikf", {tabId: tabId, url: tasks[tabId].url});
// }

// // On other extension message (Ariane for exemple)
// chrome.runtime.onMessageExternal.addListener(function(msg, sender) {
//   if (sender.id != "nhledioladlcecbcfenmdibnnndlfikf")
//     return;  // don't allow this extension access
//   console.log(msg);
// });


During merging, for a field, for each path :
while (the old-path is found in the page)
  continue;
insert(the new path); // (before the first not found).

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  

[CSS selectors.](http://www.w3schools.com/cssref/css_selectors.asp)
