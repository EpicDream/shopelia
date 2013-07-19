Ariane Chromium Extension
=========================

Ariane is a Chromium plugin used to indicate where to find information on a product url.

Indeed, Viking/Saturn need a mapping to extract information.
For the moment this mapping have to be precise by a humain operator, via Ariane.

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

Add a panel at the right of the page, like the first mapper extension.
This panel, that we will be able to hide, will be use to edit path.
It will be the editPathPage of the mapper.
We will see the current prod mapmping if available, the current new mapping, and possibly other previous mapping.

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  

[CSS selectors.](http://www.w3schools.com/cssref/css_selectors.asp)
