// FakeSaturn used for tests.
// Author : Vincent Renaudineau
// Created at : 2013-09-19

define(['src/saturn_session', 'mapping'], function(SaturnSession, Mapping) {
"use strict";

var FakeSaturnSession = function() {
  SaturnSession.apply(this, arguments);
  this.currentValue = {};
};

FakeSaturnSession.prototype = new SaturnSession(null, {});

// 
FakeSaturnSession.prototype.openUrl = function(url) {
  this.next();
};

// 
FakeSaturnSession.prototype.evalAndThen = function(cmd, callback) {
  var result;
  switch (cmd.action) {
    case "getOptions" :
      switch (cmd.option) {
        case 1:
          result = [{text: 'color1', hash: 'color1'}, {text: 'color2', hash: 'color2'}];
          break;
        case 2:
          result = [{text: 'size1', hash: 'size1'}, {text: 'size2', hash: 'size2'}];
          break;
        default:
          result = [{text: 'option-'+cmd.option+'-1', hash: 'option-'+cmd.option+'-1'},
                    {text: 'option-'+cmd.option+'-2', hash: 'option-'+cmd.option+'-2'}];
      }
      break;
    case 'setOption' :
      this.currentOption = cmd.option;
      this.currentValue[cmd.option] = cmd.value;
      break;
    case 'crawl' :
      result = {title: "Le titre de mon produit."};
      break;
    default:
      throw "Bad command action : "+cmd.action;
  }
  if (callback)
    callback(result);
  else
    this.next();
};

return FakeSaturnSession;
 
});
