var casper = require('casper').create({
 
});
var googleLoginUrl = "https://accounts.google.com/ServiceLogin";
var blogPostUrl = "http://haveafashionbreak.blogspot.fr/2013/11/22-manteaux-pour-cet-hiver.html";
var iframeUrl = null;
var comment = "Tu es superbe! Quel style. Cette écharpe me plait bien ...";

phantom.cookiesEnabled = true;

casper.on('error', function(msg,backtrace) {
  this.echo("=========================");
  this.echo("ERROR:");
  this.echo(msg);
  this.echo(backtrace);
  this.echo("=========================");
});

// casper.start(googleLoginUrl, function() {
//   var inputs = {Email:"anne.fashion.paris@gmail.com", Passwd:"bidiboussi"};
//   this.fill("form[action='https://accounts.google.com/ServiceLoginAuth']", inputs, true);
//   this.echo("Cookies: " + this.page.cookies);
//   
// });

casper.start(blogPostUrl, function() {
});

casper.then(function(){
  iframeUrl = this.evaluate(function() {
    return __utils__.findOne('#comment-editor-src').getAttribute('href');
  });
  this.echo(">> " + iframeUrl);
  casper.open(iframeUrl).then(function(){
    
    var token = this.evaluate(function(){
      var token = document.querySelector("#bgresponse").getAttribute('value');
      return token;
    });
    this.echo("TOKEN => " + token)
    
    var input ={'commentBody':"Tu es superbe! Quel style. Cette écharpe me plait bien ..."};
    this.echo(this.fetchText('div#identityControlsHolder'));
    this.evaluate(function(){
          var select = document.querySelector("#identityMenu");
          select.value = "GOOGLE";
        });
        this.fill("form#commentForm", {'commentBody':"Tu es superbe! Quel style. Cette écharpe me plait bien ..."}, true);
        
    // this.click('#postCommentSubmit');
    
     
    this.waitFor(function(){
      var x =  this.evaluate(function() {
        return document.querySelector('#signIn');
      });
      return x;
    },
    function() {
      this.echo("***OK")
      this.echo(this.fetchText('#signIn'))
        // var inputs = {Email:"anne.fashion.paris@gmail.com", Passwd:"bidiboussi"};
        // this.fill("form[action='https://accounts.google.com/ServiceLoginAuth']", inputs, true);
      
      this.echo(this.getCurrentUrl());
      this.capture('/tmp/google.png', {
           top: 0,
           left: 0,
           width: 1000,
           height: 1000
       });
      
    },
    function() {
      this.capture('/tmp/google.png', {
           top: 0,
           left: 0,
           width: 1000,
           height: 1000
       });
      
      this.echo("***BYE BYE")
      this.echo(this.getCurrentUrl());
      
      
    },
    10000
  )
    // var x = this.evaluate(function() {
    //   document.querySelector('#commentBodyField').setAttribute("value", "toto");
    //   return document.querySelector('#commentBodyField').getAttribute("value");
    //   // return document.querySelector("#postCommentSubmit").click();
    // });
    // this.echo("click res : " + x)
    // 
    // // var x = this.click('#postCommentSubmit');
    // // this.echo("click res : " + x)
    // var script = this.evaluate(function() {
    //   return __utils__.getFieldValue('commentBody');
    //    });
    // this.echo("Sript : " + script);
    // 
    // var x = this.evaluateOrDie(function() {
    //    var t = document.getElementById('postCommentSubmit');
    //    t.click();
    //   // return document.querySelector("#postCommentSubmit").click();
    // });
    // this.echo("RET X : " + x);
    // this.wait(2000, function(){
    //   this.echo(this.getCurrentUrl());
    //   
    // })
  });
  casper.then(function(){
    this.echo(this.getCurrentUrl());
  })
});

casper.then(function(){
  this.echo(this.getCurrentUrl());
});

casper.run(function() {
});
