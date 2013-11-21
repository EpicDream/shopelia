// Tests all Mappings.
// Author : Vincent Renaudineau
// Created at : 2013-10-25

define(['logger', 'mapping'], function (logger, Mapping) {

  logger.level = logger.NONE;

  describe("Mappings", function () {
    it("all is constistent", function () {
      var merchants, merchantId;

      runs(function () {
        logger.debug("Going to get merchants.");
        Mapping.getMerchants().done(function (merchantsHash) {
          logger.debug(Object.keys(merchantsHash).length + " merchants got !");
          merchants = merchantsHash.supportedBySaturn;
        });
      });
      waitsFor(function() {
        return merchants;
      });
      runs(function () {
        logger.debug("Going to define tests...");
        merchants.forEach(function(merchantId) {
          var results, nbErrors;
          runs(function () {
            Mapping.load(merchantId).done(function (mapping) {
              if (Object.keys(mapping._pages).length > 0) {
                results = mapping.checkConsistency();
                nbErrors = Object.keys(results).length;
                if (nbErrors > 0) {
                  logger.error("For merchant " + mapping.id + ", errors on fields : " + Object.keys(results).join());
                  expect(nbErrors).toBe(0);
                }
              } else {
                results = {};
              }
            });
          });
          waitsFor(function () {
            return results;
          });
        }); // forEach
        logger.debug("Tests defined.");
      }); // runs
    }); // it
  }); // describe
}); // define
