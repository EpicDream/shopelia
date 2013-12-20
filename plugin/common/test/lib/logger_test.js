// Tests logger.
// Author : Vincent Renaudineau
// Created at : 2013-11-05

define(['logger'], function (logger) {
  describe("logger", function () {

    var date_regexp;

    beforeEach(function () {
      date_regexp = "\\d\\d:\\d\\d:\\d\\d.\\d\\d\\d";
    });

    it('timestamp', function () {
      expect(logger.timestamp()).toMatch(date_regexp);
      expect(logger.timestamp(Date.now())).toMatch(date_regexp);
    });

    it('header', function () {
      var d = new Date(),
        date = logger.timestamp(d),
        header;
      header = logger.header('DEBUG', d);
      expect(typeof header).toBe('object');
      expect(header instanceof Array).toBe(true);
      expect(header.length).toBe(3);
      expect(header[0]).toBe("[%s][%5s]");
      expect(header[1]).toMatch(date_regexp);
      expect(header[2]).toBe("DEBUG");
    });

    it('format', function () {
      var args = ["une string", "un nombre", {un: 'object'}, [1, 'array']],
        l = args.length,
        res;

      res = logger.format('INFO', '', args);

      expect(args.length).toBe(l);
      expect(res.length).toBe(l+3);
      expect(res[3]).toBe(args[0]);
      expect(res[4]).toBe(args[1]);
      expect(res[0]).toMatch("%s %s");
      expect(res[5]).toMatch('{"un":"object"}');
      expect(res[6]).toMatch('[1,"array"]');
    });

    it('stringify', function () {
      var str = logger.stringify(["[DEBUG] %s %s", "toto", 5]);
      expect(str).toBe("[DEBUG] toto 5");
    });
  });
});
