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

    beforeEach(function() {
      spyOn(saturn, 'openNewTab').andCallThrough();
      spyOn(saturn, 'closeTab').andCallThrough();
    });

    it('start/pause/resume/stop call good functions.', function() {
      spyOn(saturn, 'main');

      expect(saturn.crawl).toBe(false);
      expect(saturn.openNewTab).not.toHaveBeenCalled();
      expect(saturn.closeTab).not.toHaveBeenCalled();
      expect(saturn.main.calls.length).toBe(0);
      saturn.start();

      expect(saturn.crawl).toBe(true);
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.main.calls.length).toBe(1);

      saturn.pause();
      expect(saturn.crawl).toBe(false);

      saturn.resume();
      expect(saturn.crawl).toBe(true);
      expect(saturn.main.calls.length).toBe(2);

      expect(saturn.closeTab).not.toHaveBeenCalled();
      saturn.stop();
      expect(saturn.crawl).toBe(false);
      expect(saturn.closeTab.calls.length).toBe(satconf.MIN_NB_TABS);
    });

    it('start only once', function() {
      spyOn(saturn, 'main');
      saturn.crawl = true;
      saturn.start();

      expect(saturn.crawl).toBe(true);
      expect(saturn.openNewTab).not.toHaveBeenCalled();
      expect(saturn.main).not.toHaveBeenCalled();
    });

    it('timers works when start/pause/resume/stop', function() {
      spyOn(saturn, 'main').andCallThrough();
      spyOn(saturn, 'onProductsReceived');
      spyOn(saturn, 'updateNbTabs');
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

  describe('tabs',function() {
    it('openNewTab and closeTab', function() {
      saturn.openNewTab();
      expect(saturn.tabs.pending.length).toBe(1);
      expect(Object.keys(saturn.tabs.opened).length).toBe(1);
      saturn.openNewTab();
      expect(saturn.tabs.pending.length).toBe(2);
      expect(Object.keys(saturn.tabs.opened).length).toBe(2);

      saturn.closeTab(saturn.tabs.pending[0]);
      expect(saturn.tabs.pending.length).toBe(1);
      expect(Object.keys(saturn.tabs.opened).length).toBe(1);
      saturn.closeTab(saturn.tabs.pending[0]);
      expect(saturn.tabs.pending.length).toBe(0);
      expect(Object.keys(saturn.tabs.opened).length).toBe(0);
    });

    it('updateNbTabs (1)', function() {
      satconf.MIN_NB_TABS = 2;
      satconf.MAX_NB_TABS = 15;

      spyOn(saturn, 'openNewTab').andCallThrough();
      spyOn(saturn, 'closeTab').andCallThrough();
      spyOn(saturn, 'crawlProduct');

      // Il crée autant de tab que nécessaire au démarrage.
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y a juste ce qu'il faut en pending
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Les MIN_NB_TABS sont occupées et il en manque une.
      saturn.pending = [];
      saturn.productQueue = [{id: 42}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y en a une de trop en pending
      saturn.productQueue = [];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque 3 tabs
      saturn.productQueue = [{id: 13}, {id: 14}, {id: 15}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque des tabs, mais trop.
      expect(Object.keys(saturn.tabs.opened).length).toBe(satconf.MIN_NB_TABS + 3);
      saturn.MAX_NB_TABS = saturn.MIN_NB_TABS + 3;
      saturn.productQueue = [{id: 16}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);
    });

    it('updateNbTabs (2)', function() {
      satconf.MIN_NB_TABS = 0;
      satconf.MAX_NB_TABS = 15;

      spyOn(saturn, 'openNewTab').andCallThrough();
      spyOn(saturn, 'closeTab').andCallThrough();
      spyOn(saturn, 'crawlProduct');

      // Il crée autant de tab que nécessaire au démarrage.
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y a juste ce qu'il faut en pending
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Les MIN_NB_TABS sont occupées et il en manque une.
      saturn.pending = [];
      saturn.productQueue = [{id: 42}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y en a une de trop en pending
      saturn.productQueue = [];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque 3 tabs
      saturn.productQueue = [{id: 13}, {id: 14}, {id: 15}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque des tabs, mais trop.
      expect(Object.keys(saturn.tabs.opened).length).toBe(satconf.MIN_NB_TABS + 3);
      saturn.MAX_NB_TABS = saturn.MIN_NB_TABS + 3;
      saturn.productQueue = [{id: 16}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);
    });

    it('updateNbTabs (3)', function() {
      satconf.MIN_NB_TABS = 0;
      satconf.MAX_NB_TABS = 15;

      spyOn(saturn, 'openNewTab').andCallThrough();
      spyOn(saturn, 'closeTab').andCallThrough();
      spyOn(saturn, 'crawlProduct');

      // Il crée autant de tab que nécessaire au démarrage.
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y a juste ce qu'il faut en pending
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Les MIN_NB_TABS sont occupées et il en manque une.
      saturn.pending = [];
      saturn.batchQueue = [{id: 42}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // Il y en a une de trop en pending
      saturn.batchQueue = [];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque 3 tabs
      saturn.batchQueue = [{id: 13}, {id: 14}, {id: 15}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);

      // Il manque des tabs, mais trop.
      expect(Object.keys(saturn.tabs.opened).length).toBe(satconf.MIN_NB_TABS + 3);
      saturn.MAX_NB_TABS = saturn.MIN_NB_TABS + 3;
      saturn.batchQueue = [{id: 16}];
      saturn.updateNbTabs();
      expect(saturn.openNewTab.calls.length).toBe(satconf.MIN_NB_TABS + 1 + 3);
      expect(saturn.closeTab.calls.length).toBe(1);
    });
  });

  describe('from received products to createSession',function() {
    it('createSession, openUrl, and call next and ended', function() {
      spyOn(SaturnSession.prototype, 'start');
      spyOn(saturn, 'cleanTab').andCallThrough();
      spyOn(saturn, 'openUrl').andCallThrough();
      spyOn(saturn, 'crawlProduct');
      expect(Object.keys(saturn.sessions).length).toBe(0);
      
      saturn.createSession({id: 42, url: ''}, 1);
      saturn.productsBeingProcessed[42] = true;
      
      expect(Object.keys(saturn.sessions).length).toBe(1);
      expect(saturn.sessions[1] instanceof SaturnSession).toBe(true);
      expect(saturn.cleanTab).toHaveBeenCalled();
      var session = saturn.sessions[1];
      expect(typeof session.then).toBe('function');
      expect(saturn.openUrl).toHaveBeenCalled();
      expect(session.start).toHaveBeenCalled(); // via session.next()

      saturn.endSession(session);
      
      expect(typeof saturn.sessions[1]).toBe('undefined');
      expect(saturn.productsBeingProcessed[42]).toBe(undefined);
      expect(saturn.crawlProduct).toHaveBeenCalled();
    });

    it('addProductToQueue', function() {
      spyOn(saturn, 'crawlProduct');

      expect(Object.keys(saturn.productsBeingProcessed).length).toBe(0);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(0);

      saturn.addProductToQueue({id: 42});

      expect(saturn.productsBeingProcessed[42]).toBe(true);
      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(0);
      expect(saturn.crawlProduct).toHaveBeenCalled();


      saturn.addProductToQueue({id: 51, batch_mode: true});

      expect(saturn.productsBeingProcessed[51]).toBe(true);
      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(1);
      expect(saturn.crawlProduct.calls.length).toBe(2);
    });

    it('crawlProduct (1)', function() {
      spyOn(saturn, 'updateNbTabs');
      spyOn(saturn, 'createSession');
      spyOn(saturn, 'closeTab');
      
      // pending, batchQueue and productQueue are empty.
      saturn.crawlProduct();
      expect(saturn.updateNbTabs).not.toHaveBeenCalled();
      expect(saturn.createSession).not.toHaveBeenCalled();
      expect(saturn.closeTab).not.toHaveBeenCalled();

      // batchQueue and productQueue are empty but not pending.
      saturn.tabs.pending = [1];
      saturn.crawlProduct();
      expect(saturn.updateNbTabs).not.toHaveBeenCalled();
      expect(saturn.createSession).not.toHaveBeenCalled();
      expect(saturn.closeTab).not.toHaveBeenCalled();
      expect(saturn.tabs.pending.length).toBe(1);

      // pending is empty but not batchQueue and productQueue.
      saturn.tabs.pending = [];
      saturn.batchQueue.push({id: 51});
      saturn.productQueue.push({id: 42});
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(1);
      expect(saturn.createSession).not.toHaveBeenCalled();
      expect(saturn.closeTab).not.toHaveBeenCalled();
      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(1);

      // there is a tab to close, a product and a batch
      saturn.tabs.pending = [1];
      saturn.tabs.opened[1] = {toClose: true};
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(2);
      expect(saturn.createSession).not.toHaveBeenCalled();
      expect(saturn.closeTab.calls.length).toBe(1);
      expect(saturn.productQueue.length).toBe(1);
      expect(saturn.batchQueue.length).toBe(1);
      expect(saturn.tabs.pending.length).toBe(0);

      // there is a tab, a product and a batch
      saturn.tabs.pending = [1];
      saturn.tabs.opened[1] = {};
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(3);
      expect(saturn.createSession.calls.length).toBe(1);
      expect(saturn.closeTab.calls.length).toBe(1);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(1);
      expect(saturn.tabs.pending.length).toBe(0);

      // product is empty and there is a tab and a batch
      saturn.tabs.pending = [2];
      saturn.tabs.opened[2] = {};
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(3);
      expect(saturn.closeTab.calls.length).toBe(1);
      expect(saturn.createSession.calls.length).toBe(2);
      expect(saturn.productQueue.length).toBe(0);
      expect(saturn.batchQueue.length).toBe(0);
      expect(saturn.tabs.pending.length).toBe(0);
    });

    it('crawlProduct (2)', function() {
      spyOn(saturn, 'updateNbTabs');
      spyOn(saturn, 'createSession');
      spyOn(saturn, 'closeTab');

      // productQueue and pending are empty but not batchQueue.
      saturn.tabs.pending = [];
      saturn.batchQueue.push({id: 51});
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(1);
      expect(saturn.createSession).not.toHaveBeenCalled();
      expect(saturn.closeTab).not.toHaveBeenCalled();
      expect(saturn.batchQueue.length).toBe(1);

      // productQueue is empty but not batchQueue and pending.
      saturn.tabs.pending = [1];
      saturn.tabs.opened[1] = {};
      saturn.crawlProduct();
      expect(saturn.updateNbTabs.calls.length).toBe(1);
      expect(saturn.createSession.calls.length).toBe(1);
      expect(saturn.closeTab).not.toHaveBeenCalled();
      expect(saturn.batchQueue.length).toBe(0);
    });

    it('onProductsReceived', function() {
      spyOn(saturn, 'onProductReceived');
      spyOn(saturn, 'updateNbTabs');

      saturn.productsBeingProcessed[42] = true;
      saturn.onProductsReceived([{id: 42}, {id: 51}]);
      expect(saturn.onProductReceived.calls.length).toBe(1);
      expect(saturn.updateNbTabs.calls.length).toBe(0);

      saturn.onProductsReceived([{id: 42}]);
      expect(saturn.onProductReceived.calls.length).toBe(1);
      expect(saturn.updateNbTabs.calls.length).toBe(1);
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

  describe('Integration', function() {

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
