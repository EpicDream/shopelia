// CssStruct class.
// Author : Vincent Renaudineau
// Created : 2013-08-01

define(function() {
'use strict';

var CssStruct = (function() {

  // The background CSS parser.
  // An array of hash.
  // We can also retrieve :
  // cssStruct.initial // => css;
  // cssStruct.parsed
  // cssStruct.nonParsed
  function CssStruct(css) {

    var current = css,
      i,
      match,
      value,
      insideCSS;

    if (css instanceof CssStruct) {
      for (i = 0; i < css.length; i++)
        this.push(css[i]);
      this.initial = css.initial;
      this.parsed  = css.parsed;
      this.nonParsed = css.nonParsed;
      return;
    }

    i = 0;
    while (i < css.length) {
      if ( match = current.match(/^\[([\w-]+)(?:((?:\~|\||\*|\^|\$)?=)('(?:[^']|\\')*'|"(?:[^"]|\\")*"))?\]/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "attribute", name: match[1], method: match[2], value: match[3]});
      } else if ( match = current.match(/^#([\w-]+)/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "id", value: match[1]});
      } else if ( match = current.match(/^\.([\w-]+)/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "class", value: match[1]});
      } else if ( match = current.match(/^::([\w-]+)/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        // TODO : match a pseudoElement.
      } else if ( match = current.match(/^:([\w-]+)/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        if (current[0] === '(') {
          insideCSS = CssStruct.getSubNestedBrace(current);
          i += insideCSS.length + 2;
          current = current.slice(insideCSS.length + 2);
          value = (match[1] === "not" || match[1] === "has") ? new CssStruct(insideCSS) : insideCSS;
        } else
          value = undefined;
        this.push({type: "function", name: match[1], arg: value});
      } else if ( match = current.match(/^\s*(\>|\+|\~|\,)\s*/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "sep", kind: match[1]});
      } else if ( match = current.match(/^\s+(?=[\w\.\#\[\*-])/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "sep", kind: " "});
      } else if ( match = current.match(/^[\w-]+|\*/) ) {
        i += match[0].length;
        current = current.slice(match[0].length);
        this.push({type: "tag", value: match[0]});
      } else if (  current.match(/^\s*$/) ) {
        i = css.length;
      } else {
        console.log("Don't succeed to match something in :", current);
        break;
      }
    }

    this.initial = css;
    this.parsed  = css.slice(0,i);
    this.nonParsed = css.slice(i);
  }

  CssStruct.prototype = [];

  CssStruct.prototype.toCss = function() {
    var res = '';
    for ( var i = 0, l = this.length ; i < l ; i++ ) {
      var h = this[i];
      if (!h) { continue; }
      switch (h.type) {
        case "attribute":
          res += "["+h.name;
          if (h.method)
            res += h.method + h.value;
          res += "]";
          break;
        case "id":
          res += "#"+h.value;
          break;
        case "class":
          res += "."+h.value;
          break;
        case "tag":
          res += h.value;
          break;
        case "function":
          res += ":"+h.name;
          if (h.arg instanceof CssStruct)
            res += '('+h.arg.toCss()+')';
          else if (h.arg)
            res += '('+h.arg+')';
          break;
        case "sep":
          res += " ";
          if (h.kind != " ")
            res += h.kind+" ";
          break;
        default:
          console.error("`CssStruct::toCss' Unknow type :", h.type);
      }
    }
    return res;
  };

  CssStruct.prototype.valueOf = function() {
    return this.toCss();
  };

  CssStruct.getSubNestedBrace = function(text) {
    var sep = text[0],
        i = text.indexOf(sep),
        cpt = 1,
        current = text.slice(i+1),
        res = text.slice(0,i),
        closing;
    switch (sep) {
      case '(': closing = ')'; break;
      case '{': closing = '}'; break;
      case '[': closing = ']'; break;
      case '<': closing = '>'; break;
      default: console.error("`CssStruct::getSubNestedBrace' Unknow block separator :", sep); return text;
    }

    var security = 100;
    while (cpt > 0 && security > 0) {
      i = current.search(new RegExp("\\"+sep+"|"+"\\"+closing));
      if (i === -1)
        return console.error(current, i);
      else if (current[i] === sep)
        cpt += 1;
      else if (current[i] === closing)
        cpt -= 1;
      else
        console.error(current, i);
      res += current.slice(0,i+1);
      current = current.slice(i+1);
      security -= 1;
    }

    return res.slice(0,-1);
  };

  // CssStruct.parseFromCss = function(css) {
  //   return new CssStruct(css);
  // };

  // CssStruct.parseDomElement = function(e) {
  //   var res = new CssPrase();

  //   for ( ; e && e.nodeType == 1 ; e = e.parentNode ) {
  //     var cssElem = new CssElement();
  //     var tag = e.tagName;
  //     cssElem.tag = tag.toLowerCase();
  //     cssElem.id = e.id;

  //     // Si il n'y a qu'un élément de ce type en enfant, on s'arrête
  //     var sameTagSiblings = $(e).siblings().filter(function(index) { return this.tagName == tag; });
  //     if (sameTagSiblings.length == 0)
  //       continue;

  //     // CLASSES
  //     var elementClasses = getClasses(jelement);
  //     if (! complete) {
  //       var siblingsClasses = _.map(sameTagSiblings.filter("*[class]"), function(sibling) { return getClasses($(sibling)); });
  //       var classes = _.difference(elementClasses, [].concat(_.flatten(siblingsClasses)));
  //       res += _.map(classes, function(c){return "."+c;}).join('');
  //       if (classes.length > 0)
  //         return res;
  //     } else {
  //       res += _.map(elementClasses, function(c){return "."+c;}).join('');
  //     }

  //     // ATTRIBUTES
  //     if (tag == "INPUT")
  //       cssElem.attributes.push(new CssAttribute("[type='"+e.getAttribute("type")+"']"));
  //     if (tag == "INPUT" || tag == "SELECT" || tag == "TEXTAREA")
  //       cssElem.attributes.push(new CssAttribute("[name='"+e.getAttribute("name")+"']"));

  //     // POSITION
  //     var pos = $(e).parent().children(tag).index(e) + 1;
  //     cssElem.functions.push(new CssFunction(":nth-of-type(" + pos + ")");

  //     if (res.length > 0)
  //       res.splice(0,0,new CssSeparator('>'));
  //     res.splice(0,0,cssElem);

  //     if (e.tagName == 'HTML')
  //       break;
  //   }
  //   return res;
  // };

  return CssStruct;
})();

return CssStruct;

});
/*
TODO : plutot que de récupérer un css string, récupérer un DOM element, (un jQuery element ? avec genre jelem.queryString ?)
path = new Path(arg) => arg peut être un path string, un element, ou un ensemble d'element (jQuery ou pas)
path.toCss() => to CSS format string
path.toXPath() => to XPath format string
path.to$() => to jQuery
path.minimize() => si initializé avec des elems, minimize avec ça, sinon fait un find avant.
path.from(arg) => si arg is undefined return la valeur, sinon ça la set.
path.find() => retourne les éléments
*/