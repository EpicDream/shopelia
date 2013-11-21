// Tests for CssStruct.
// Author : Vincent Renaudineau
// Created at : 2013-10-16

define(['lib/css_struct', 'lib/css_minimizer'], function(CssStruct, Minimizer) {

  var COSTS = Minimizer.COSTS;

  describe("Minimizer", function() {
    it('score', function() {
      expect(Minimizer.score(new CssStruct("div"))).toBe(COSTS.tag_gen);
      expect(Minimizer.score(new CssStruct("span"))).toBe(COSTS.tag_gen);
      expect(Minimizer.score(new CssStruct("img"))).toBe(COSTS.tag_spe);
      expect(Minimizer.score(new CssStruct(".test"))).toBe(COSTS.class);
      expect(Minimizer.score(new CssStruct("#test"))).toBe(COSTS.id);
      expect(Minimizer.score(new CssStruct(":test"))).toBe(COSTS.function);
      expect(Minimizer.score(new CssStruct("[test]"))).toBe(COSTS.attribute);
      expect(Minimizer.score(new CssStruct("div#test.test"))).toBe(COSTS.tag_gen + COSTS.id + COSTS.class);
      expect(Minimizer.score(new CssStruct("img[src]:first"))).toBe(COSTS.tag_spe + COSTS.attribute + COSTS.function);
      expect(Minimizer.score(new CssStruct("p img"))).toBe(COSTS.tag_gen + COSTS.sep + COSTS.tag_spe);

      expect(Minimizer.score(new CssStruct("div#zoom"))).toBe(
        COSTS.tag_gen + COSTS.id);
      expect(Minimizer.score(new CssStruct("div#zoom p.marged-right"))).toBe(
        COSTS.tag_gen + COSTS.id + COSTS.sep + COSTS.tag_gen + COSTS.class + 1);
      expect(Minimizer.score(new CssStruct("div#zoom p.marged-right img#productImage"))).toBe(
        COSTS.tag_gen + COSTS.id + COSTS.sep + COSTS.tag_gen + COSTS.class + COSTS.sep + COSTS.tag_spe + COSTS.id + 4);
      expect(Minimizer.score(new CssStruct("div#zoom p.marged-right img#productImage[itemprop='image']"))).toBe(
        COSTS.tag_gen + COSTS.id + COSTS.sep + COSTS.tag_gen + COSTS.class + COSTS.sep + COSTS.tag_spe + COSTS.id + COSTS.attribute + 6);
    });

    describe("separate", function() {
      var initialStruct, struct;
      beforeEach(function() {
        initialStruct = new CssStruct("div#zoom p.marged-right img#productImage[itemprop='image']");
        struct = new CssStruct("");
        struct.length = initialStruct.length;
      });

      it('create new children', function() {
        var children = Minimizer.separate(struct, initialStruct);
        expect(children instanceof Array).toBe(true);
        expect(children.length).toBe(7);
        expect(children[0].length).toBe(9);

        expect(typeof children[0][0]).toBe('object');
        expect(typeof children[0][1]).toBe('undefined');
        expect(children[0][0].type).toBe('tag');
        expect(children[0][0].value).toBe('div');
        expect(children[0].filter(function(e){return e !== undefined;}).length).toBe(1);

        expect(typeof children[1][0]).toBe('undefined');
        expect(typeof children[1][1]).toBe('object');
        expect(children[1][1].type).toBe('id');
        expect(children[1][1].value).toBe('zoom');
        expect(children[1].filter(function(e){return e !== undefined;}).length).toBe(1);

        expect(typeof children[3][0]).toBe('undefined');
        expect(typeof children[3][4]).toBe('object');
        expect(children[3][4].type).toBe('class');
        expect(children[3][4].value).toBe('marged-right');
        expect(children[3].filter(function(e){return e !== undefined;}).length).toBe(1);
      });

      it('put spaces', function() {
        var children = Minimizer.separate(struct, initialStruct);
        children = Minimizer.separate(children[6], initialStruct);
        expect(children.length).toBe(6);
        expect(children.filter(function(e){return typeof e[8] === 'object';}).length).toBe(6);

        expect(typeof children[5][7]).toBe('object');
        expect(children[5][7].type).toBe('id');
        expect(children[5][7].value).toBe('productImage');
        expect(typeof children[5][5]).toBe('undefined');
        expect(children[5].filter(function(e){return e !== undefined;}).length).toBe(2);

        expect(typeof children[0][0]).toBe('object');
        expect(children[0][0].type).toBe('tag');
        expect(children[0][0].value).toBe('div');
        expect(typeof children[0][5]).toBe('object');
        expect(children[0][5].type).toBe('sep');
        expect(children[0][5].kind).toBe(' ');
        expect(children[0].filter(function(e){return e !== undefined;}).length).toBe(3);

        expect(typeof children[2][0]).toBe('undefined');
        expect(typeof children[2][3]).toBe('object');
        expect(children[2][3].type).toBe('tag');
        expect(children[2][3].value).toBe('p');
        expect(typeof children[2][5]).toBe('object');
        expect(children[2][5].type).toBe('sep');
        expect(children[2][5].kind).toBe('>');
        expect(children[2].filter(function(e){return e !== undefined;}).length).toBe(3);
      });

      it('global test', function() {
        var children,
          res;

        children = Minimizer.separate(struct, initialStruct).map(function(s) {return s.toCss();});
        res = ["div", "#zoom", "p", ".marged-right", "img", "#productImage", "[itemprop='image']"];
        expect(children).toEqual(res);
        
        struct[8] = initialStruct[8];
        children = Minimizer.separate(struct, initialStruct).map(function(s) {return s.toCss();});
        res = ["div [itemprop='image']", "#zoom [itemprop='image']", "p > [itemprop='image']", ".marged-right > [itemprop='image']", "img[itemprop='image']", "#productImage[itemprop='image']"];
        expect(children).toEqual(res);
        
        struct[4] = initialStruct[4];
        struct[5] = initialStruct[5];
        struct[5].kind = '>';
        children = Minimizer.separate(struct, initialStruct).map(function(s) {return s.toCss();});
        res = ["div > .marged-right > [itemprop='image']", "#zoom > .marged-right > [itemprop='image']", "p.marged-right > [itemprop='image']"];
        expect(children).toEqual(res);
      });
    });

    it('arraysEqual', function() {
      var t1 = [{toto: 1}, {tata: 2}, {titi: 3}],
          t2;
      expect(Minimizer.arraysEqual([], t1)).toBe(false);
      expect(Minimizer.arraysEqual([1,2,3], t1)).toBe(false);
      t2 = t1.slice(0);
      expect(Minimizer.arraysEqual(t2, t1)).toBe(true);
      t2[3] = {tutu: 4};
      expect(Minimizer.arraysEqual(t2, t1)).toBe(false);
    });

    it('isSolution', function() {
      expect(Minimizer.isSolution(new CssStruct("#test"), [1,2], function() {
        return [1,2];
      })).toBe(true);

      expect(Minimizer.isSolution(new CssStruct("#test"), [1,2], function() {
        return [1,3];
      })).toBe(false);

      expect(Minimizer.isSolution(new CssStruct("#test"), [1,2], function() {
        return [1,2,3];
      })).toBe(false);

      expect(Minimizer.isSolution(new CssStruct("#test"), [1,2], (function () {
        var $ = function () {
          return {
            toArray: function () {
              return [1,2];
            }
          };
        };
        $.fn = {jquery: "1.9"};
        return $;
      })())).toBe(true);

      expect(Minimizer.isSolution(new CssStruct("#test "), [1,2], (function () {
        var $ = function () {
          return {
            toArray: function () {
              return [1,3];
            }
          };
        };
        $.fn = {jquery: "1.9"};
        return $;
      })())).toBe(false);
    });

    it('minimize', function() {
      var initialCss = "div#zoom p.marged-right img#productImage[itemprop='image']",
        easy = ".marged-right img",
        waitedRes = "#productImage";

      expect(Minimizer.minimize(initialCss, function(path) {
        if (path === easy || path === waitedRes)
          return ["img"];
        else
          return ["img", "img2"];
      }, easy)).toBe(waitedRes);

      easy = "div#zoom .marged-right img";
      waitedRes = ".marged-right > #productImage";

      expect(Minimizer.minimize(initialCss, function(path) {
        if (path === easy || path === waitedRes)
          return ["img"];
        else
          return ["img", "img2"];
      }, easy)).toBe(waitedRes);
    });

    it('minimize get all results', function() {
      var initialCss = "div#zoom p.marged-right > img#productImage[itemprop='image']",
        goodResults = [
          "#productImage", // best path

          ".marged-right > img", // easy path

          "div #productImage",
          "#zoom #productImage",
          "p > #productImage",
          ".marged-right > #productImage",
          "img#productImage",
          "#productImage[itemprop='image']",
          
          "div > .marged-right > img",
          "#zoom > .marged-right > img",
          "p.marged-right > img",
          ".marged-right > img#productImage",
          ".marged-right > img[itemprop='image']",
          "div#zoom #productImage",
          "div > p > #productImage",
          "div > .marged-right > #productImage",
          "div > img#productImage",
          "div > #productImage[itemprop='image']",
          "#zoom > p > #productImage",
          "#zoom > .marged-right > #productImage",
          "#zoom > img#productImage",
          "#zoom > #productImage[itemprop='image']",
        ],
        result;

      result = Minimizer.minimize(initialCss, function(path) {
        if (goodResults.indexOf(path) !== -1)
          return ["img"];
        else
          return ["img", "img2"];
      }, goodResults[1], {});
      expect(result).toEqual("#productImage");

      result = Minimizer.minimize(initialCss, function(path) {
        if (goodResults.indexOf(path) !== -1)
          return ["img"];
        else
          return ["img", "img2"];
      }, goodResults[1], {maxNbResult: 3});
      expect(result).toEqual(["#productImage", ".marged-right > img"]);
    });
  });
});
