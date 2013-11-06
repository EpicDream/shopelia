// Tests logger.
// Author : Vincent Renaudineau
// Created at : 2013-11-05

define(['logger'], function (logger) {
  describe("Mapping", function () {
    it('timestamp', function () {
      var regexp = "\\d\\d:\\d\\d:\\d\\d.\\d\\d\\d";
      expect(logger.timestamp()).toMatch(regexp);
      expect(logger.timestamp(Date.now())).toMatch(regexp);
    });

    it('header', function () {
      var d = new Date(),
        date_regexp = /^\[\d\d:\d\d:\d\d.\d\d\d\]/,
        date = logger.timestamp(d),
        header;
      expect(logger.header('DEBUG', 'maMethod', d)).toBe("["+date+"][DEBUG] `maMethod' :");
      expect(logger.header('DEBUG', '', d)).toBe("["+date+"][DEBUG]");

      expect(logger.header('DEBUG', 'maMethod')).toMatch(date_regexp);
      expect(logger.header('DEBUG', 'maMethod')).toMatch(/\[DEBUG\] `maMethod' :/);
      expect(logger.header('DEBUG', '')).toMatch(/\[DEBUG\]/);

      expect(logger.header('INFO', 'maMethod', d)).toMatch("[ INFO]");
    });

    it('format', function () {
      var args = ["une string", "un nombre", {un: 'object'}, [1, 'array']],
        l = args.length,
        res;

      res = logger.format('INFO', '', args);

      expect(args.length).toBe(l);
      expect(res.length).toBe(l-1);
      expect(res[1]).toBe(args[0]);
      expect(res[2]).toBe(args[1]);
      expect(res[0]).toMatch("%s %s");
      expect(res[0]).toMatch('{"un":"object"}');
      expect(res[0]).toMatch('[1,"array"]');
    });

    it('stringify', function () {
      var str = logger.stringify(["[DEBUG] %s %s", "toto", 5]);
      expect(str).toBe("[DEBUG] toto 5");
    });
  });
});
