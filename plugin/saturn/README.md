Saturn Chromium Extension
=========================

Saturn is a Chromium plugin used to extract products informations.
  
He gets a product url from shopelia server, open it, extract all usefull informations and send them back to server.
  
He can extract for example :

- title
- price
- price strikeout
- shipping price
- shipping info
- availability
- brand
- description
- a main image
- other images

Installation
------------

#### Manually, for tests

In Chromium extensions' tab :

1. Check 'Developper mode'
2. Then click on 'Load unpacked extension'
3. Browse on Saturn directory and open it.
4. Check 'Allow in private navigation'.

#### Automatically, in prod

To launch google-chrome and install the extension, just run

    google-chrome --load-extension=/home/barbu/shopelia/plugin/saturn

To unload the extension after utilisation, add 

    && google-chrome --uninstall-extension=nhledioladlcecbcfenmdibnnndlfikf

with **nhledioladlcecbcfenmdibnnndlfikf** the extension id, that you can find in Chrome's extensions tab.
  
On a server :

    DISPLAY=:0 google-chrome --load-extension=/home/barbu/shopelia/plugin/saturn ; google-chrome --uninstall-extension=nhledioladlcecbcfenmdibnnndlfikf

Usage
-----
  
You have nothing to do, the extension ask itself for product to crawl.
  
You can crawl the product on the current page by clicking on the extension's button at top-right of the window in TestMode.
  
We recommand you to use it in a private tab, to do not be tracked.
  
Click on the extension button in the toolbar to stop / restart the crawling.

Developpers
-----------

There are two main files :

- background.js
- contentscript.js

### background.js

It's the logic piece of the program.
It communicate with the server, load pages, and ask the content script to crawl the current page.

Common scenario :

1. background ask for a product to crawl ;
2. it load the product url ;
3. it load the content script ;
4. it ask the content script for colors ;
5. for each color :
    6. it ask the content script to select the color ;
    7. it ask the content script for the sizes ;
    8. for each size :
        9. it ask the content script to select the size ;
        10. it ask the content script to extract all informations ;
11. it send all product options to the server ;
12. it restart to step 1.

### contentscript.js

It's the executive piece of the program.
Only the contentscript can interact with the web page.
But it can not communicate with other server, and it is reloaded each time the page is.

To crawl the page, it need a mapping for this website.
The mapping indicate where to find all elements on the page.
The mapping must be previously set with Humanis extension.  

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  

[CSS selectors.](http://www.w3schools.com/cssref/css_selectors.asp)

TODO list
---------

Add the possibility to click on an element to get images.
Add the possibility to handle multiple extractor at the same time on different tab.
