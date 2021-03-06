Saturn Chromium Extension and CasperJS script
=============================================

Saturn is a Chromium plugin and a NodeJS/CasperJS script used to extract products informations.
  
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

### Chrome Extension

First of all, install the latest version of Chrome.

Then run

    ./bin/saturn

You call also run

    grunt exec

which will create a saturn.crx file, that you can add directly to your Chrome by drag and drop.

If you want a special version of saturn, rerun grunt. For example, for a prod with manual-launch Saturn, run

    grunt chrome-dev-prod

### CasperJS script

Go in saturn folder :

    cd shopelia/plugin/saturn/

Then, run it :

    sudo ./install.sh

Next times, just run

    ./update.sh

Usage
-----

### Chrome Extension
  
There are different way to use Saturn :

1. In config.run_mode=manual, you can crawl the product on the current page by clicking on the extension's button at top-right of the window.

2. In config.run_mode=auto, you have nothing to do, the extension ask itself for product to crawl.
Click on the extension button in the toolbar to pause / resume the crawling.
  
We recommand you to use it in a private tab, to do not be tracked.
  
Go in saturn folder :

    cd shopelia/plugin/saturn/

The first time, set saturn script executable :

    chmod u+x ./saturn

Then, run it :

    ./saturn

On a server, you may have to specify the output display :

    DISPLAY=:0 ./saturn

Configuration
-------------

All configuration is done in the config.yml file. You can find

- run_mode : manual to launch saturn on the current page or auto to let him get products to crawl.
- PRODUCT_EXTRACT_URL : where to find products to crawl (prod, staging, local)
- PRODUCT_EXTRACT_UPDATE : where to send crawl results (prod, staging, local)
- MAPPING_URL : where to find mapping (prod, staging, local).
- consum : cunsum or not the products (usefull when getting real products from prod for tests)
- MAX_NB_TABS : the max number of tab it can open simultaneously.
- log_level : ALL, TRACE, DEBUG, VERBOSE, INFO, WARNING, ERROR, NONE.

Developpers
-----------

Firts of all, install Saturn from sources.

Then, insteed of use packaged extension, open Chrome and in extensions' tab :

1. Check 'Developper mode'
2. Then click on 'Load unpacked extension'
3. Browse on Saturn directory and open it.
4. Check 'Allow in private navigation'.

After you have modify a file, run

    grunt [chrome|casper]

It will

- check syntax with JSHint,
- retrieve and concat all needed files,
- run tests with Jasmine,
- clean build files,
- and update manifest.json file.

Then, for Chrome, reload extension in Chrome extensions' tab, or restart NodeJs server.

When modifications are good, before commit it with git, run

    grunt [chrome|casper]-prod

Additionnaly to just grunt [chrome|casper], are also available :

- grunt [chrome|casper]-test : just run test, doesn't build or clean anything.
- grunt [chrome|casper]-dev-prod : like dev but crawl a product like in prod, not just first options.
- grunt [chrome|casper]-prod-dev : like prod, but log all and doesn't uglify.
- grunt [chrome|casper]-staging : like prod, but doesn't consum prod.

More info on [Grunt](http://gruntjs.com/)
### Files

There are three main files :

- saturn.js
- saturn_session.js
- crawler.js

### saturn.js + session.js

They are the logic piece of the program.
Saturn communicate with the server and load pages, 
while Session ask the crawler to crawl the current page.

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
