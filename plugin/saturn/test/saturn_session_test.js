// Tests for SaturnSession.
// Author : Vincent Renaudineau
// Created at : 2013-12-03

define(['logger', './fake_saturn_session', './fake_saturn', 'satconf'], function(logger, FakeSaturnSession, FakeSaturn) {

logger.level = logger.NONE;

describe("SaturnSession", function() {
  var saturn, session, prod;

  beforeEach(function() {
    prod = {
      id: 42,
      url: "http://www.mondomaine.fr/une/page",
      mapping: {
        title: [""],
        option1: [""],
        option2: [""],
      },
    };
    saturn = new FakeSaturn();
    session = new FakeSaturnSession(saturn, prod);
  });

  it('Integration', function() {
    session.strategy = 'normal';

    spyOn(session, 'next').andCallThrough();
    spyOn(session, 'getOptions').andCallThrough();
    spyOn(session, 'setOption').andCallThrough();
    spyOn(session, 'crawl').andCallThrough();
    spyOn(session, 'sendPartialVersion').andCallThrough();
    spyOn(session, 'sendFinalVersions').andCallThrough();

    session.start();
    // Produce :
    // openUrl,
    // getOptions color->2,
    // (
    //   setOption color, 
    //   getOptions taille->2,
    //   (
    //     setOption,
    //     crawl
    //   ) * 2
    // ) * 2
    expect(session.next.calls.length).toBeGreaterThan(14);
    expect(session.getOptions.calls.length).toBe(3);
    expect(session.setOption.calls.length).toBe(6);
    expect(session.crawl.calls.length).toBe(4);
    expect(session.sendPartialVersion.calls.length).toBe(4);
    expect(session.sendFinalVersions.calls.length).toBe(1);

    expect(session.results.length).toBe(4);
  });
});

});