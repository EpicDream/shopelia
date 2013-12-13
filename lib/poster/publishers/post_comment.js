var casper = require('casper').create();

phantom.cookiesEnabled = true;

var googleLoginUrl = "https://accounts.google.com/ServiceLogin";
var blogPostUrl = casper.cli.get(0);
var comment = casper.cli.get(1);
var googleEmail = casper.cli.get(2);
var googlePassword = casper.cli.get(3);
var successOutput = "COMMENT HAS BEEN POSTED";
var failureOutput = "FAILURE WHILE POSTING COMMENT";

function submitComment(_this) {
  _this.evaluate(function(){
    var select = document.querySelector("#identityMenu");
    select.value = "GOOGLE";
  });
    
  _this.fill("form#commentForm", {'commentBody':comment}, true);
}

function signIn(_this) {
  return function() {
    var inputs = {Email:googleEmail, Passwd:googlePassword};
    _this.fill("form[action='https://accounts.google.com/ServiceLoginAuth']", inputs, true);
    
    this.waitFor(
      function() {
        return this.evaluate(function() {
          return !document.querySelector('#signIn');
        });
      },
      function() {
        _this.echo(successOutput);
        casper.exit();
      },
      function() {
        _this.echo(failureOutput);
        _this.capture('/tmp/post-comment-failure-.png', {top: 0, left: 0, width: 2000, height: 2000});
        casper.exit();
      },
      10000
    );
  };
}

function failure(_this) {
  return function() {
    _this.capture('/tmp/post-comment-failure-.png', {top: 0, left: 0, width: 2000, height: 2000});
    _this.echo(failureOutput);
    casper.exit();
  };
}

casper.start(blogPostUrl);

casper.then(function() {
  var iframeUrl = this.evaluate(function() {
    return document.querySelector('#comment-editor-src').getAttribute('href');
  });
  casper.thenOpen(iframeUrl);
});

casper.then(function() {
  submitComment(this);

  this.waitFor(function() {
    return this.evaluate(function() {
      return document.querySelector('#signIn');
    });
  },
  signIn(this),
  failure(this),
  10000);
});

casper.run(function() {
});
