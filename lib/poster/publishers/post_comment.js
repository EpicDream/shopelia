var casper = require('casper').create();

phantom.cookiesEnabled = true;

var googleLoginUrl = "https://accounts.google.com/ServiceLogin";
var blogPostUrl = casper.cli.get(0);
var comment = casper.cli.get(1);
var googleEmail = casper.cli.get(2);
var googlePassword = casper.cli.get(3);
var successOutput = "COMMENT HAS BEEN POSTED";
var failureOutput = "FAILURE WHILE POSTING COMMENT";
var popupMode = false;

function submitCommentInPopup() {
  this.fillSelectors("form#commentForm", {'#comment-body':comment}, true);
}

function submitComment() {
  this.evaluate(function(){
    var select = document.querySelector("#identityMenu");
    select.value = "GOOGLE";
  });
    
  this.fill("form#commentForm", {'commentBody':comment}, true);
}

function signIn() {
  return function() {
    var inputs = {Email:googleEmail, Passwd:googlePassword};
    this.fill("form[action='https://accounts.google.com/ServiceLoginAuth']", inputs, true);
    
    this.waitFor(
      function() {
        return this.evaluate(function() {
          return !document.querySelector('#signIn');
        });
      },
      function() {
        this.echo(successOutput);
        casper.exit();
      },
      function() {
        this.echo(failureOutput);
        this.capture('/tmp/post-comment-failure.png');
        casper.exit();
      },
      10000
    );
  };
}

function failure() {
  return function() {
    this.capture('/tmp/post-comment-failure-.png');
    this.echo(failureOutput);
    casper.exit();
  };
}

casper.start(blogPostUrl);

casper.then(function() {
  var ret = this.evaluate(function() {
    var url = null;
    var popupMode = false;
    var node = document.querySelector('#comment-editor-src'); //iframe
    if (!node) {
      var popupLinkXpath = ".//a[contains(@href, 'blogger.com/comment.g')]";
      popupMode = true;
      node = document.evaluate(popupLinkXpath, document, null, 9, null).singleNodeValue; //link to popup
    }
    url = node.getAttribute('href');
    return [url, popupMode];
  });
  popupMode = ret[1];
  casper.thenOpen(ret[0]);
});

casper.then(function() {
  popupMode ? submitCommentInPopup.apply(this) : submitComment.apply(this);

  this.waitFor(function() {
    return this.evaluate(function() {
      return document.querySelector('#signIn');
    });
  },
  signIn.apply(this),
  failure.apply(this),
  10000);
});

casper.run();
