var casper = require('casper').create();
var googleLoginUrl = "https://accounts.google.com/ServiceLogin";
var blogPostUrl = "http://haveafashionbreak.blogspot.fr/2013/11/22-manteaux-pour-cet-hiver.html";
var comment = "Tu es superbe! Quel style. Cette écharpe me plait bien ...";

phantom.cookiesEnabled = true;

function submitComment(_this) {
  _this.evaluate(function(){
    var select = document.querySelector("#identityMenu");
    select.value = "GOOGLE";
  });
    
  _this.fill("form#commentForm", {'commentBody':comment}, true);
}

function signIn(_this) {
  return function() {
    _this.echo(_this.fetchText('#signIn'));
// var inputs = {Email:"anne.fashion.paris@gmail.com", Passwd:"bidiboussi"};
// this.fill("form[action='https://accounts.google.com/ServiceLoginAuth']", inputs, true);
    _this.echo("OK");
    return true;
  };
}

function failure(_this) {
  return function() {
    _this.capture('/tmp/post-comment-failure-.png', {top: 0, left: 0, width: 2000, height: 2000});
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

casper.run();
