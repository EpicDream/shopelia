// Tests for CssStruct.
// Author : Vincent Renaudineau
// Created at : 2013-10-16

define(['lib/css_struct'], function(CssStruct) {

  describe("CssStruct", function() {
    it('parse', function() {
      var css = new CssStruct("div table.noir > tr#theFirst > td[itemprop='name'] > span:nth-of-type(2) strong:first");
      expect(css instanceof CssStruct);
      expect(css instanceof Array);
      expect(css.length).toBe(16);
      expect(typeof css[0]).toBe('object');
      expect(css[0].type).toBe('tag');
      expect(css[0].value).toBe('div');

      expect(css[1].type).toBe('sep');
      expect(css[1].kind).toBe(' ');

      expect(css[2].type).toBe('tag');
      expect(css[2].value).toBe('table');
      expect(css[3].type).toBe('class');
      expect(css[3].value).toBe('noir');

      expect(css[4].type).toBe('sep');
      expect(css[4].kind).toBe('>');

      expect(css[9].type).toBe('attribute');
      expect(css[9].name).toBe('itemprop');
      expect(css[9].method).toBe('=');
      expect(css[9].value).toBe("'name'");

      expect(css[12].type).toBe('function');
      expect(css[12].name).toBe('nth-of-type');
      expect(css[12].arg).toBe('2');

      expect(css[15].type).toBe('function');
      expect(css[15].name).toBe('first');
      expect(css[15].arg).toBe(undefined);
    });

    it('clone', function() {
      var css1 = new CssStruct("div table.noir");
      var css2 = new CssStruct(css1);
      
      expect(css2).not.toBe(css1);
      expect(css2 instanceof Array);
      expect(css2 instanceof CssStruct);
      expect(css2.length).toBe(4);
      expect(css2).toEqual(css1);
    });
  });

});
