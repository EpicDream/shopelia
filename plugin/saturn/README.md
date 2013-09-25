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

#### From packaged extension

Download the saturn.crx file, and drop it in the Google-Chrome window.

#### From sources

In Chromium extensions' tab :

1. Check 'Developper mode'
2. Then click on 'Load unpacked extension'
3. Browse on Saturn directory and open it.
4. Check 'Allow in private navigation'.

#### Automatically, in prod

To launch google-chrome and install the extension, just run

    google-chrome --load-extension=/home/USER_NAME/shopelia/plugin/saturn

To unload the extension after utilisation, add 

    && google-chrome --uninstall-extension=nhledioladlcecbcfenmdibnnndlfikf

with **nhledioladlcecbcfenmdibnnndlfikf** the extension id, that you can find in Chrome's extensions tab.
  
On a server :

    DISPLAY=:0 google-chrome --load-extension=/home/USER_NAME/shopelia/plugin/saturn ; google-chrome --uninstall-extension=nhledioladlcecbcfenmdibnnndlfikf

Usage
-----
  
You have nothing to do, the extension ask itself for product to crawl.
  
You can crawl the product on the current page by clicking on the extension's button at top-right of the window in TestMode.
  
We recommand you to use it in a private tab, to do not be tracked.
  
Click on the extension button in the toolbar to stop / restart the crawling.

Developpers
-----------

### Grunt

First, run

    npm install grunt

Then, you can use

    grunt

to check syntax with JSHint, run tests with Jasmine, concat and uglify source files.

### Files

There are three main files :

- saturn.js
- saturn_session.js
- crawler.js

### saturn.js + saturn_session.js

They are the logic piece of the program.
Saturn communicate with the server and load pages, 
while SaturnSession ask the crawler to crawl the current page.

Common scenario :

1. Saturn asks for a product to crawl ;
2. it loads the product url ;
3. it creates a SaturnSession ;
4. the SaturnSession asks the crawler for colors ;
5. for each color :
    6. it asks the crawler to select the color ;
    7. it asks the crawler for the sizes ;
    8. for each size :
        9. it asks the crawler to select the size ;
        10. it asks the crawler to extract all informations ;
11. it sends all product options to the server ;
12. it restarts to step 1.

### crawler.js

It's the executive piece of the program.
Only the crawler can interact with the web page.
But it can not communicate with other server, and it is reloaded each time the page is.

To crawl the page, it needs a mapping for this website.
The mapping indicates where to find all elements on the page.
The mapping must be previously set with Humanis extension.  

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  

[CSS selectors.](http://www.w3schools.com/cssref/css_selectors.asp)

TODO list
---------

Add the possibility to click on an element to get other images.
