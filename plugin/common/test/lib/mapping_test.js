// Tests all Mappings.
// Author : Vincent Renaudineau
// Created at : 2013-10-25

define(['logger', 'mapping'], function (logger, Mapping) {

  logger.level = logger.NONE;

  describe("Mapping", function () {
    var merchant, url;

    beforeEach(function () {
      merchant = {
        id:2,
        data:{
          viking:{
            "amazon.fr":{
              "availability":{"paths":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']","b.h1:contains('recherchez une page')"]},
              "brand":{"paths":[".buying > h1 + a"]},
              "description":{"paths":["#productDescription div.content, #ps-content div.content","#feature-bullets-atf .content, .techD:first .content, #artistCentralTeaser > div","#technical-specs_feature_div .content, .content .tsTable","#technicalProductFeaturesATF","div.bucket h2:contains(\"Description\") + div.content"]},
              "image_url":{"paths":["#main-image, #prodImage, #original-main-image"]},
              "name":{"paths":["span#btAsinTitle"]},
              "price":{"paths":["span#actualPriceValue b, span#buyingPriceValue b","#secondaryUsedAndNew a:not([href*=\"condition=used\"]) + .price"]},
              "price_shipping":{"paths":["#actualPriceExtraMessaging, #pricePlusShippingQty .plusShippingText","table.qpDivTop div.cBox table td:first"]},
              "price_strikeout":{"paths":["span#listPriceValue"]},
              "shipping_info":{"paths":["div.buying > *[class*=\"avail\"]","#secondaryUsedAndNew a.buyAction[href*='condition=used']"]},
              "option1":{"paths":[".variations div#selected_color_name + div .swatchSelect, .variations div#selected_color_name + div .swatchAvailable, .variations div#selected_color_name + div .swatchUnavailable","select#dropdown_selected_color_name"]},
              "option2":{"paths":["#dropdown_selected_size_name option.dropdownAvailable, #dropdown_selected_size_name option.dropdownSelect, div.buying > select#asinRedirect",".variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchSelect, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchAvailable, .variations div.variationSelected[id!=selected_color_name] + div.spacediv .swatchUnavailable"]}
            }
          },
          pages: {
            "http://www.amazon.fr/dp/B000000001": {
              innerHTML: "<html><head><title>Ceci est un titre 1</title></head><body><h1>Titre principal</h1><div id='technicalProductFeaturesATF'>une description</div></body></html>",
              title: "Ceci est un titre 2",
              url: "http://www.amazon.fr/dp/B000000001",
              results: {
                description: "une description"
              }
            },
            "http://www.amazon.fr/dp/B000000002": {
              innerHTML: "<html><head><title>Ceci est un titre 1</title></head><body><h1>Titre principal</h1><div>Ceci est <p id='technicalProductFeaturesATF'>une description</p></div></body></html>",
              title: "Ceci est un titre 2",
              url: "http://www.amazon.fr/dp/B000000002",
              results: {
                description: "une description"
              }
            }
          }
        }
      };
      url = "http://www.amazon.fr/dp/B000000002";
    });

    it('initialize regular', function () {
      spyOn(Mapping.prototype, '_initMerchantData');
      spyOn(Mapping.prototype, 'setUrl');
      spyOn(Mapping.prototype, 'setHost');

      var mapping = new Mapping(merchant, url);

      expect(mapping._initMerchantData).not.toHaveBeenCalled();
      expect(mapping.setHost).not.toHaveBeenCalled();
      expect(mapping.setUrl.calls.length).toBe(1);
      expect(mapping.id).toBe(2);
      expect(mapping._data).toBe(merchant.data);
      expect(mapping._host_mappings).toBe(merchant.data.viking);
    });

    it('initialize without url', function () {
      spyOn(Mapping.prototype, '_initMerchantData');
      spyOn(Mapping.prototype, 'setUrl');
      spyOn(Mapping.prototype, 'setHost');

      var mapping = new Mapping(merchant);

      expect(mapping._initMerchantData).not.toHaveBeenCalled();
      expect(mapping.setHost).not.toHaveBeenCalled();
      expect(mapping.setUrl).not.toHaveBeenCalled();
      expect(mapping.id).toBe(2);
      expect(mapping._data).toBe(merchant.data);
      expect(mapping._host_mappings).toBe(merchant.data.viking);
    });

    it('initialize without data', function () {
      spyOn(Mapping.prototype, '_initMerchantData').andCallThrough();
      spyOn(Mapping.prototype, 'setUrl');
      spyOn(Mapping.prototype, 'setHost');

      var mapping = new Mapping({id: 42}, url);

      expect(mapping._initMerchantData.calls.length).toBe(1);
      expect(mapping.setHost.calls.length).toBe(1);
      expect(mapping.setUrl).not.toHaveBeenCalled();
      expect(mapping.id).toBe(42);
      expect(typeof mapping._data).toBe('object');
      expect(typeof mapping._host_mappings).toBe('object');
      expect(Object.keys(mapping._host_mappings).length).toBe(1);
      expect(mapping._host_mappings["default"]).not.toBe(undefined);
    });

    it('toObject', function () {
      var h = (new Mapping(merchant, url)).toObject();
      expect(typeof h).toBe('object');
      expect(Object.keys(h).length).toBe(2);
      expect(h.id).toBe(2);
      expect(typeof h.data).toBe('object');
      expect(Object.keys(h.data).length).toBe(2);
      expect(typeof h.data.viking).toBe('object');
      expect(Object.keys(h.data.viking).length).toBe(1);
      expect(typeof h.data.viking['amazon.fr']).toBe('object');
      expect(Object.keys(h.data.viking['amazon.fr']).length).toBeGreaterThan(10);
      expect(typeof h.data.pages).toBe('object');
      expect(Object.keys(h.data.pages).length).toBe(2);
    });

    it('getHost', function () {
      expect(Mapping.getHost('http://www.amazon.fr/dp/B00CW925QY')).toBe('amazon.fr');
      expect(Mapping.getHost('http://amazon.fr/')).toBe('amazon.fr');
      expect(Mapping.getHost('http://musique.fnac.com')).toBe('musique.fnac.com');
      expect(Mapping.getHost('https://www4.fnac.com')).toBe('www4.fnac.com');
      expect(Mapping.getHost('http://musique.fnac.com')).toBe('musique.fnac.com');
      expect(Mapping.getHost('http://a.b.musique.fnac.com')).toBe('a.b.musique.fnac.com');
      expect(Mapping.getHost('http://www.amazon.co.uk')).toBe('amazon.co.uk');
    });

    it('getMinHost', function () {
      expect(Mapping.getMinHost('http://www.amazon.fr/dp/B00CW925QY')).toBe('amazon.fr');
      expect(Mapping.getMinHost('http://amazon.fr/')).toBe('amazon.fr');
      expect(Mapping.getMinHost('http://musique.fnac.com')).toBe('fnac.com');
      expect(Mapping.getMinHost('https://www4.fnac.com')).toBe('fnac.com');
      expect(Mapping.getMinHost('http://musique.fnac.com')).toBe('fnac.com');
      expect(Mapping.getMinHost('http://a.b.musique.fnac.com')).toBe('fnac.com');
      expect(Mapping.getMinHost('http://a.b.musique.amazon.co.uk')).toBe('amazon.co.uk');
    });

    it('getMerchants', function () {
      var merchants;

      runs(function () {
        Mapping.getMerchants().done(function (merchantsHash) {
          merchants = merchantsHash;
        }).fail(function (err) {
          console.info("\nGet merchants FAIL ! " + err.statusText);
          merchants = {};
        });
      });
      waitsFor(function () {
        return merchants;
      });
      runs(function () {
        expect(typeof merchants).toBe('object');
        expect(typeof merchants.totalCount).toBe('number');
        expect(typeof merchants.supportedBySaturn).toBe('object');
        expect(merchants.supportedBySaturn instanceof Array).toBe(true);
      });
    });

    it('load from merchant_id', function () {
      var mapping;

      runs(function () {
        Mapping.load(2).done(function (merchantsHash) {
          mapping = merchantsHash;
        }).fail(function (err) {
          console.info("\nLoad merchant FAIL ! " + err.statusText);
          mapping = {};
        });
      });
      waitsFor(function () {
        return mapping;
      });
      runs(function () {
        expect(mapping instanceof Mapping).toBe(true);
        expect(mapping.id).toBe(2);
        expect(mapping.host).toBe(undefined);
      });
    });

    it('load from merchant url', function () {
      var mapping;

      runs(function () {
        Mapping.load(url).done(function (merchantsHash) {
          mapping = merchantsHash;
        }).fail(function (err) {
          console.info("\nLoad merchant FAIL ! " + err.statusText);
          mapping = {};
        });
      });
      waitsFor(function () {
        return mapping;
      });
      runs(function () {
        expect(mapping instanceof Mapping).toBe(true);
        expect(mapping.id).toBe(2);
        expect(mapping.host).toBe('amazon.fr');
      });
    });

    it('load with a ref', function () {
      var mapping;

      runs(function () {
        Mapping.load("http://www.topgeek.net/prod").done(function (merchantsHash) {
          mapping = merchantsHash;
        }).fail(function (err) {
          console.info("\nLoad merchant FAIL ! " + err.statusText);
          mapping = {};
        });
      });
      waitsFor(function () {
        return mapping;
      });
      runs(function () {
        expect(mapping instanceof Mapping).toBe(true);
        expect(mapping.id).toBe(511);
        expect(mapping.refs instanceof Array).toBe(true);
        expect(mapping.refs[0]).toBe(188);
        expect(mapping.host).toBe('default');
        expect(typeof mapping.currentMap).toBe('object');
        expect(mapping._host_mappings["default"]).not.toBe(undefined);
        expect(Object.keys(mapping.currentMap).length).toBeGreaterThan(0);
      });
    });

    it('doc2page', function () {
      var page = Mapping.doc2page();
      expect(typeof page).toBe('object');
      expect(typeof page.innerHTML).toBe('string');
      expect(page.innerHTML.search(/^</)).toBe(0);
      expect(typeof page.title).toBe('string');
      expect(page.title).toBe(document.title);
      expect(typeof page.url).toBe('string');
      expect(page.url).toBe(document.location.href);
    });

    it('page2doc', function () {
      var doc = Mapping.page2doc(
        merchant.data.pages[url]
      );

      expect(doc instanceof HTMLDocument).toBe(true);
      expect(doc.title).toBe("Ceci est un titre 2");
      expect(doc.location).toBe(null);
      expect(doc.querySelector("h1").innerText).toBe("Titre principal");
    });

    it('crawlPage', function() {
      var mapping = new Mapping(merchant, url),
        page = merchant.data.pages[url],
        crawl = mapping.crawlPage(page),
        waitedResults = page.results,
        field;
      expect(typeof crawl).toBe('object');
      expect(Object.keys(crawl).length).toBe(11);
      for (field in merchant.data.viking['amazon.fr']) {
        expect(crawl[field]).toBe(waitedResults[field]);
      }
    });

    it('checkConsistency', function() {
      var mapping = new Mapping(merchant, url+"1"),
        results = mapping.checkConsistency();
      expect(typeof results).toBe('object');
      expect(Object.keys(results).length).toBe(0);

      mapping.currentMap.description.paths = ['#technicalProductFeaturesATF'];
      results = mapping.checkConsistency('description');
      expect(typeof results).toBe('object');
      expect(Object.keys(results).length).toBe(0);

      mapping.currentMap.description.paths = ['div'];
      results = mapping.checkConsistency('description');
      expect(typeof results).toBe('object');
      expect(Object.keys(results).length).toBe(1);
      expect(results.description).not.toBe(undefined);
      expect(results.description instanceof Array).toBe(true);
      expect(results.description.length).toBe(1);
      expect(typeof results.description[0]).toBe('object');
      expect(results.description[0].url).toBe(url);
      expect(results.description[0].old).toBe(merchant.data.pages[url].results.description);
      expect(results.description[0].new).toBe('Ceci est <p id="technicalProductFeaturesATF">une description</p>');
      expect(typeof results.description[0].msg).toBe('string');
    });
  });
});
