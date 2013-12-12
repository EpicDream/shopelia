var casper = require('casper').create();
var googleLoginUrl = "https://accounts.google.com/ServiceLogin";
var blogPostUrl = "http://haveafashionbreak.blogspot.fr/2013/11/22-manteaux-pour-cet-hiver.html";
var comment = "Tu es superbe! Quel style. Cette écharpe me plait bien ...";

phantom.cookiesEnabled = true;

casper.start(blogPostUrl, function() {
});

casper.then(function(){
  var iframeUrl = this.evaluate(function() {
    return document.querySelector('#comment-editor-src').getAttribute('href');
  });

  casper.open(iframeUrl).then(function(){
    var input ={'commentBody':comment};
    this.echo(this.fetchText('div#identityControlsHolder'));
    this.evaluate(function(){
      var select = document.querySelector("#identityMenu");
      select.value = "GOOGLE";
    });
    this.fill("form#commentForm", input, true);
     
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
