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

There are different way to use Saturn :

1. You may install it in a Chromium, and launch it manually on each page you want to crawl.
2. You may install it in a Google-Chrome and, at launch, it will ask product to crawl to shopelia automatically.

There are also different way to install it :

1. (Recommended) Manually, from the sources.
2. Manually, with the packaged extension.
3. Automatically, via 'install' script.

#### With the packaged extension

Just download the saturn.crx file, and drop it in the Google-Chrome window.
  
You may also find it in shopelia/plugin/extensions/

#### From sources

The first thing to do is to install grunt.

1. If they are not already installed, install nodejs (> 0.8) and npm. Look http://doc.ubuntu-fr.org/nodejs for furthermore details. Take a look at the 'Depuis un PPA' section if nodejs package is too old in the repositories.
2. Install grunt
    
    sudo npm install -g grunt-cli

3. go in saturn folder.
4. install all necessary packages.

    npm install

5. run

    grunt prod

See Install "With the packaged extension".

#### Automatically, via 'install' script

Go in saturn folder :

    cd shopelia/plugin/saturn/

The first time, set saturn script executable :

    chmod u+x ./install

Then, run it :

    ./install

Usage
-----
  
In config.run_mode=auto, you have nothing to do, the extension ask itself for product to crawl.
Click on the extension button in the toolbar to pause / resume the crawling.
  
In config.run_mode=manual, you can crawl the product on the current page by clicking on the extension's button at top-right of the window.
  
We recommand you to use it in a private tab, to do not be tracked.

Go in saturn folder :

    cd shopelia/plugin/saturn/

The first time, set saturn script executable :

    chmod u+x ./saturn

Then, run it :

    ./saturn

Or, on a server, specify the output display :

    DISPLAY=:0 ./saturn

Developpers
-----------

Firts of all, install Saturn from sources.

Then, insteed of use packaged extension, open Chrome and in extensions' tab :

1. Check 'Developper mode'
2. Then click on 'Load unpacked extension'
3. Browse on Saturn directory and open it.
4. Check 'Allow in private navigation'.

After you have modify a file, run

    grunt

It will

- check syntax with JSHint,
- retrieve and concat all needed files,
- run tests with Jasmine,
- clean build files,
- and update manifest.json file.

and reload extension in Chrome extensions' tab.

When modifications are good, before commit it with git, run

    grunt prod

It will additionnaly

- minimize/uglify files,
- do more cleaning tasks,
- and package extension.

Additionnaly to just grunt, are also available :

- grunt test : just run test, doesn't build or clean anything.
- grunt dev-prod : like dev but crawl a product like in prod, not just first options.
- grunt prod-dev : like prod, but log all and doesn't uglify.
- grunt staging : like prod, but doesn't consum prod.

More info on [Grunt](http://gruntjs.com/)
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
