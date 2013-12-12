// Tests for Saturn.
// Author : Vincent Renaudineau
// Created at : 2013-09-19

define(['logger', 'src/saturn_session', './fake_saturn', 'satconf'], function(logger, SaturnSession, FakeSaturn) {

logger.level = logger.NONE;

describe("Saturn", function() {
  var saturn;

  beforeEach(function() {
    window.saturn = saturn = new FakeSaturn();
  });

  describe("start/pause/resume/stop", function() {

    it('start/pause/resume/stop call good functions.', function() {
      spyOn(saturn, 'main');

      expect(saturn.crawl).toBe(false);
      expect(saturn.main.calls.length).toBe(0);
      saturn.start();

      expect(saturn.crawl).toBe(true);
      expect(saturn.main.calls.length).toBe(1);

      saturn.pause();
      expect(saturn.crawl).toBe(false);

      saturn.resume();
      expect(saturn.crawl).toBe(true);
      expect(saturn.main.calls.length).toBe(2);

      saturn.stop();
      expect(saturn.crawl).toBe(false);
    });

    it('start only once', function() {
      spyOn(saturn, 'main');
      saturn.crawl = true;
      saturn.start();

      expect(saturn.crawl).toBe(true);
      expect(saturn.main).not.toHaveBeenCalled();
    });

    it('timers works when start/pause/resume/stop', function() {
      spyOn(saturn, 'main').andCallThrough();
      spyOn(saturn, 'onProductsReceived');
      satconf.DELAY_BETWEEN_PRODUCTS = 100;
      var flag, nbCalls;

      runs(function() {
        saturn.start();
        flag = false;
        setTimeout(function() {flag = true;}, satconf.DELAY_BETWEEN_PRODUCTS * 3);
      });
      waitsFor(function() {
        return flag;
      });
      runs(function() {
        expect(saturn.main.calls.length).toBeGreaterThan(1);
        saturn.pause();
        nbCalls = saturn.main.calls.length;
        flag = false;
        setTimeout(function() {flag = true;}, satconf.DELAY_BETWEEN_PRODUCTS * 2);
      });
      waitsFor(function() {return flag;});
      runs(function() {
        expect(saturn.main.calls.length).toBe(nbCalls);
        saturn.resume();

        flag = false;
        setTimeout(function() {flag = true;}, satconf.DELAY_BETWEEN_PRODUCTS * 3);
      });
      waitsFor(function() {return flag;});
      runs(function() {
        expect(saturn.main.calls.length).toBeGreaterThan(nbCalls + 1);
        saturn.stop();
        nbCalls = saturn.main.calls.length;
        flag = false;
        setTimeout(function() {flag = true;}, satconf.DELAY_BETWEEN_PRODUCTS * 2);
      });
      waitsFor(function() {return flag;});
      runs(function() {
        expect(saturn.main.calls.length).toBe(nbCalls);
      });
    });
  });

  describe('from received products to createSession',function() {
    xit('createSession, openUrl, and call next and ended', function() {
      spyOn(SaturnSession.prototype, 'start');
      spyOn(saturn, 'openUrl').andCallThrough();
      spyOn(saturn, 'crawlProduct');
      
      saturn.createSession({id: 42}, 1);
      
      expect(saturn.openUrl).toHaveBeenCalled();
      expect(session.start).toHaveBeenCalled(); // via session.next()

      saturn.endSession(session);
      expect(saturn.crawlProduct).toHaveBeenCalled();
    });

    it('addProductToQueue', function() {
      spyOn(saturn, 'crawlProduct');

      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(0);

      saturn.addProductToQueue({id: 42});

      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(0);
      expect(saturn.crawlProduct).toHaveBeenCalled();


      saturn.addProductToQueue({id: 51, batch_mode: true});

      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(1);
      expect(saturn.crawlProduct.calls.length).toBe(2);
    });

    it('crawlProduct (1)', function() {
      spyOn(saturn, 'createSession');
      
      // batchQueue and productQueue are empty.
      saturn.crawlProduct();
      expect(saturn.createSession).not.toHaveBeenCalled();

      // batchQueue and productQueue are not empty.
      saturn.batchQueue.push({id: 51});
      saturn.productQueue.push({id: 42});
      saturn.crawlProduct();
      expect(saturn.createSession.calls.length).toBe(1);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(1);

      // now there is only batch
      saturn.crawlProduct();
      expect(saturn.createSession.calls.length).toBe(2);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(0);

      // now there is nothing to crawl
      saturn.crawlProduct();
      expect(saturn.createSession.calls.length).toBe(2);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(0);
    });

    it('onProductsReceived', function() {
      spyOn(saturn, 'onProductReceived');

      saturn.onProductsReceived([{id: 42}, {id: 51}]);
      expect(saturn.onProductReceived.calls.length).toBe(2);
    });

    it('onProductReceived', function() {
      spyOn(saturn, 'addProductToQueue');
      spyOn(saturn, 'loadMapping').andCallThrough();

      // Unknow merchant_id
      saturn.onProductReceived({id: 42, merchant_id: 47});
      expect(saturn.loadMapping.calls.length).toBe(1);
      expect(saturn.addProductToQueue).not.toHaveBeenCalled();

      // Know merchant_id
      saturn.onProductReceived({id: 42, merchant_id: 2});
      expect(saturn.loadMapping.calls.length).toBe(2);
      expect(saturn.addProductToQueue).toHaveBeenCalled();
      expect(saturn.mappings[2]).not.toBe(undefined);
    });
  });

  xdescribe('Integration', function() {

    afterEach(function() {
      saturn.stop();
    });

    it('complete run', function() {
      satconf.DELAY_BETWEEN_PRODUCTS = 100;
      spyOn(saturn, 'main').andCallThrough();
      spyOn(saturn, 'onProductsReceived').andCallThrough();

      var prod = {id: 42, merchant_id: 2, url: "http://www.amazon.fr/product"},
          result = {
            title: "Le titre de mon produit.",
            option1 : { text : 'color2' },
            option2 : { text : 'size1' },
          };

      runs(function() {
        saturn.start();
        flag = false;
        setTimeout(function() {flag = true;}, satconf.DELAY_BETWEEN_PRODUCTS * 3);
      });
      waitsFor(function() {return flag;});

      runs(function() {
        expect(saturn.main.calls.length).toBeGreaterThan(1);
        expect(saturn.onProductsReceived.calls.length).toBe(0);
        saturn._productToExtract.push(prod);
      });
      waitsFor(function() {return Object.keys(saturn.sessions).length > 0 || Object.keys(saturn.results).length > 0;}, "Session creation is to long.", saturn.DELAY_BETWEEN_PRODUCTS * 10);
      waitsFor(function() {return Object.keys(saturn.results).length > 0;}, "Crawling is to long to start.", 1000);
      waitsFor(function() {return Object.keys(saturn.sessions).length === 0;}, "Crawling is to long to end.", 2000);

      runs(function() {
        expect(saturn.results[42]).not.toBe(undefined);
        expect(saturn.results[42].length).toBe(4);
        var options = [], nbComplete = 0;
        for (var i = 0; i < saturn.results[42].length; i++) {
          var r = saturn.results[42][i];
          expect(r.versions instanceof Array);
          expect(r.options_completed).not.toBe(undefined);
          nbComplete += r.options_completed ? 1 : 0;
          expect(r.versions.length).toBe(1);
          var v = r.versions[0];
          expect(v.title && typeof v.option1 === 'string' && v.option1.match(/color/) && typeof v.option2 === 'string' && v.option2.match(/size/));
        }
        expect(nbComplete).toBe(1);
      });
    });
  });
});

});
