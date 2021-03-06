// Css class
// Author : Vincent Renaudineau
// Created : 2013-10-17

define(["lib/css_struct"], function(CssStruct) {
  'use strict';

  function bind(f, scope) {
    var _function = f;
    return function() {
      return _function.apply(scope, arguments);
    };
  }

  var Css = (function() {

    // An array of CssPhrase.
    // The CSS selector "div#an_id, div.a_class a" is translate in
    // [CssPhrase("div#an_id"), CssPhrase("div.a_class a")]
    // You can retrieve the underlying CssStruct item.
    // css.stuct // => CssStruct(css)
    function Css(arg) {
      if (typeof arg === "string")
        this.structs = new CssStruct(arg);
      // else if (arg instanceof HTMLElement)
      //   return bind(Css, this)(getFullCssPath(arg));
      else if (arg instanceof CssStruct)
        this.structs = arg;
      else
        return console.error("ArgumentError : ", arg, "given but string, HTMLElement or CssStruct waited.");

      var tmp = [];
      for (var i = 0, l = this.structs.length ; i < l ; i++) {
        var s = this.structs[i];
        if (s.type === 'sep' && s.kind === ',') {
          this.push(new CssPhrase(tmp));
          tmp = [];
        } else
          tmp.push(s);
      }
      this.push(new CssPhrase(tmp));
      this.deleted = [];
    }

    // function getClasses(elem) {
    //   var classes = elem.getAttribute("class")
    //   if (! classes) return [];
    //   return classes.split(/\s+/).sort();
    // };

    // // Get CSS Selector for this element : tagname, id, classes, child position.
    // // If complete is false, stop when an id is found, or when discriminant classes are found and add only these.
    // function fromParentSelector(elem, complete) {
    //   var jelem = $(elem);
    //   var tag = elem.tagName;
    //   // TAGNAME
    //   var res = tag.toLowerCase();
    //   // ID
    //   var id = elem.id;
    //   if (id && ! hu.isRandom(id)) {
    //     res += "#"+id;
    //     if (! complete)
    //       return res;
    //   }
    //   // Si il n'y a qu'un élément de ce type en enfant, on s'arrête
    //   var sameTagSiblings = jelem.siblings().filter(function(index) { return this.tagName == tag; });
    //   if (! complete && sameTagSiblings.length == 0)
    //     return res;
    //   // CLASSES
    //   var elementClasses = getClasses(elem);
    //   if (! complete) {
    //     var siblingsClasses = _.map(sameTagSiblings.filter("*[class]"), function(sibling) { return getClasses(sibling); });
    //     var classes = _.difference(elementClasses, [].concat(_.flatten(siblingsClasses)));
    //     res += _.map(classes, function(c){return "."+c;}).join('');
    //     if (classes.length > 0)
    //       return res;
    //   } else {
    //     res += _.map(elementClasses, function(c){return "."+c;}).join('');
    //   }
    //   // POSITION
    //   var pos = jelement.parent().children(tag).index(jelement) + 1;
    //   // var pos = jelement.index(tag) + 1;
    //   res += ":nth-of-type(" + pos + ")";
    //   return res;
    // };

    // Css.make = function(elem, complete) {
    //   var css = '';
    //   for ( ; elem && elem.nodeType == 1 ; elem = elem.parentNode ) {
    //     elem_selector = fromParentSelector(elem, complete);
    //     css = elem_selector + " > " + css;
    //     if (elem.tagName == 'HTML' || (! complete && elem_selector.match(/#/)))
    //       break;
    //   }
    //   return css.trim();
    // };

    // Css.makeComplete = function(elem) {
    //   return Css.make(elem, true);
    // };

    Css.prototype = [];

    Css.prototype.toCss = function() {
      var t = [];
      for (var i = 0, l = this.length ; i < l ; i++)
        t.push(this[i].toCss());
      return t.join(', ');
    };

    Css.prototype.clone = function() {
      return new Css(this.structs);
    };

    Css.prototype.valueOf = function() {
      return this.toCss();
    };
    
    Css.prototype.reset = function() {
      this.length = 0;
      bind(Css, this)(this.structs);
      return this;
    };

    Css.prototype.undo = function() {
      if (this.deleted.length === 0) return this;
      var h = this.deleted.pop();
      if (h.i === undefined)
        h.value.undo();
      else
        this.splice(h.i, 0, h.value);
      return this;
    };

    Css.prototype.simplify = function() {
      for (var i = 0, l = this.length ; i < l ; i++) {
        var e = this[i];
        if (e.tried) continue;
        var h = {value: e};
        if (! e.simplify()) {
          e.tried = true;
          h.i = i;
          if (i !== 0 || i !== l-1) // Petit bug quand on arrive au bout : "*" => true, "*" => true, "*" => false.
            this.splice(i, 1);
        }
        this.deleted.push(h);
        return true;
      }
      return false;
    };

    return Css;
  })();

  var CssPhrase = (function() {

    // An array of CssElement.
    // The CSS selector "div#an_id > a + p" is translate in
    // [CssElement("div#an_id"), CssElement("> a"), CssElement("+ p")]
    function CssPhrase(structs) {
      if (typeof structs === 'string')
        return CssPhrase(new CssStruct(structs)).bind(this);

      this.structs = structs;

      var tmp = [];
      for (var i = 0, l = structs.length ; i < l ; i++) {
        var s = structs[i];
        if (s.type === 'sep') {
          this.push(new CssElement(tmp));
          this.push(new CssSeparator(s));
          tmp = [];
        } else
          tmp.push(s);
      }
      this.push(new CssElement(tmp));
      this.deleted = [];
    }

    CssPhrase.prototype = [];

    CssPhrase.prototype.toCss = function() {
      var s = '';
      for (var i = 0, l = this.length ; i < l ; i++) {
        s += this[i].toCss();
      }
      return s;
    };

    CssPhrase.prototype.clone = function() {
      return new CssPhrase(this.structs);
    };

    CssPhrase.prototype.valueOf = function() {
      return this.toCss();
    };
    
    CssPhrase.prototype.reset = function() {
      this.length = 0;
      bind(CssPhrase, this)(this.structs);
      return this;
    };

    CssPhrase.prototype.undo = function() {
      if (this.deleted.length === 0) return this;
      var h = this.deleted.pop();
      switch (h.type) {
        case "first":
          this.splice(h.i, 0, h.value[0], h.value[1]);
          break;
        case "desc&desc":
          this.splice(h.i-1, 1, h.value[0], h.value[1], h.value[2]);
          break;
        case "desc&prec":
          this.splice(h.i, 0, h.value[0], h.value[1]);
          break;
        case "prec&prec":
          this.splice(h.i-1, 1, h.value[0], h.value[1], h.value[2]);
          break;
        default:
          h.value.undo();
      }
      return this;
    };

    CssPhrase.prototype.simplify = function() {
      for (var i = 0, l = this.length ; i < l ; i++) {
        var e = this[i];
        if (e.tried) continue;
        var h = {value: e};
        if (! e.simplify()) {
          e.tried = true;
          if (e instanceof CssSeparator) continue;
          h.i = i;
          // First element => delete fellowing separator
          if (i === 0 && l > 1) {
            h.type = "first"; h.value = this.splice(i,2);
          // Last element => do nothing
          } else if (i === l-1) {
            return false;
          // precede by a descendant and fellowed by a preceding => delete preceding
          } else if (this[i-1].isDescendant() && this[i+1].isDescendant()) {
            h.type = "desc&desc"; h.value = this.splice(i-1,3);
            this.splice(i-1, 0, new CssSeparator({kind: ' '}));
          // precede and fellowed by a descendant => delete them and leave a ' '
          } else if (this[i-1].isDescendant() && ! this[i+1].isDescendant()) {
            h.type = "desc&prec"; h.value = this.splice(i,2);
          // precede by a preceding and fellowed by a descendant => do nothing
          } else if (! this[i-1].isDescendant() && this[i+1].isDescendant()) {
            continue;
          // precede and fellowed by a preceding => delete them and leave a '~'
          } else if (! this[i-1].isDescendant() && ! this[i+1].isDescendant()) {
            h.type = "prec&prec"; h.value = this.splice(i-1,3);
            this.splice(i-1, 0, new CssSeparator({kind: '~'}));
          }
        }
        this.deleted.push(h);
        return true;
      }
      return false;
    };

    return CssPhrase;
  })();

  var CssElement = (function() {

    // An object. The CSS selector "div#an_id.a_class" is translate in
    // cssElem.tag // => "div"
    // cssElem.id // => "an_id"
    // cssElem.classes // => [a_class]
    // cssElem.functions // => []
    // cssElem.attributes // => []
    function CssElement(structs) {
      if (typeof structs === 'string') {
        return CssElement(new CssStruct(structs)).bind(this);
      }

      this.structs = structs;
      // this.separator = undefined;
      this.tag = undefined;
      this.id = undefined;
      this.classes = [];
      this.functions = [];
      this.attributes = [];

      this.deleted = [];
      this.triedField = {classes: []};

      for (var i = 0, l = structs.length ; i < l ; i++) {
        var s = structs[i];
        switch (s.type) {
          // case "sep":
          //   this.separator = s.kind;
          //   break;
          case "tag":
            this.tag = s.value;
            break;
          case "id":
            this.id = s.value;
            break;
          case "class":
            this.classes.push(s.value);
            break;
          case "function":
            var f = new CssFunction(s);
            this.functions.push(f);
            s.pointer = f;
            break;
          case "attribute":
            var a = new CssAttribute(s);
            this.attributes.push(a);
            s.pointer = a;
            break;
          default:
            console.error("`CssElement::CssElement' : Unknow type :", s.type);
        }
      }
    }

    CssElement.prototype.toCss = function() {
      var res = '', j, dl;
      // On garde l'ordre initial.
      for (var i = 0, sl = this.structs.length ; i < sl ; i++) {
        var h = this.structs[i];
        switch (h.type) {
          // case "sep":
          //   res += ' ';
          //   if (this.separator != ' ')
          //     res += this.separator+' ';
          //   break;
          case "attribute":
            for (j = 0, dl = this.deleted.length ; j < dl ; j++)
              if (this.deleted[j].type === 'attribute' && this.deleted[j].deleted && this.deleted[j].value === h.pointer)
                break;
            if (j === dl)
              res += h.pointer.toCss();
            break;
          case "id":
            if (this.id) res += "#"+this.id;
            break;
          case "class":
            if (this.classes.indexOf(h.value) != -1) // possible bug if multiple h.value in structs but only one in this.classes.
              res += "."+h.value;
            break;
          case "tag":
            if (this.tag) res += this.tag;
            break;
          case "function":
            for (j = 0, dl = this.deleted.length ; j < dl ; j++)
              if (this.deleted[j].type === 'function' && this.deleted[j].value === h.pointer)
                break;
            if (j === dl)
              res += h.pointer.toCss();
            break;
          default:
            console.error("`CssElement::toCss' Unknow type :", h.type);
        }
      }
      if (res === '' && this.tag === '*')
        res += this.tag;

      return res;
    };

    CssElement.prototype.clone = function() {
      return new CssElement(this.structs);
    };

    CssElement.prototype.valueOf = function() {
      return this.toCss();
    };

    CssElement.prototype.reset = function() {
      bind(CssElement, this)(this.structs);
      return this;
    };

    CssElement.prototype.undo = function() {
      if (this.deleted.length === 0) return this;
      var h = this.deleted.pop();
      if (h.starSetted)
        this.tag = undefined;
      switch (h.type) {
        // case "separator":
        //   this.separator = h.value;
        //   break;
        case "attribute":
          if (h.deleted) {
            this.attributes.splice(h.i, 0, h.value);
          } else {
            h.value.undo();
            h.tried = true;
          }
          break;
        case "id":
          this.id = h.value;
          break;
        case "class":
          this.classes.splice(h.i, 0, h.value);
          break;
        case "tag":
          this.tag = h.value;
          break;
        case "function":
          this.functions.splice(h.i, 0, h.value);
          break;
        default:
          console.error("`CssElement::undo' Unknow type :", h.type);
      }
      return this;
    };

    CssElement.prototype.simplify = function() {
      if (this.deleted.length > 0 && this.deleted[this.deleted.length-1].starSetted)
        return false;

      var modifDone = false, i, l;
      // first tag,
      if (this.tag && ! this.triedField.tag) {
        this.deleted.push({type: 'tag', value: this.tag});
        this.tag = undefined;
        this.triedField.tag = true;
        modifDone = true;
      } 
      // then functions,
      if (! modifDone)
        for (i = 0, l = this.functions.length ; i < l ; i++) {
          var f = this.functions[i];
          if (f.tried) continue;
          f.tried = true;
          this.deleted.push({type: 'function', i: i, value: this.functions.splice(i, 1)[0]});
          modifDone = true;
          break;
        }
      // then attributes,
      if (! modifDone)
        for (i = 0, l = this.attributes.length ; i < l ; i++) {
          var a = this.attributes[i];
          if (a.tried) continue;
          if (a.simplify()) {
            this.deleted.push({type: 'attribute', value: a});
          } else {
            a.tried = true;
            this.deleted.push({type: 'attribute', deleted: true, i: i, value: this.attributes.splice(i, 1)[0]});
          }
          modifDone = true;
          break;
        }
      // then classes,
      if (! modifDone)
        for (i = 0, l = this.classes.length ; i < l ; i++) {
          var c = this.classes[i];
          if (this.triedField.classes.indexOf(c) != -1) continue;
          this.triedField.classes.push(c);
          this.deleted.push({type: 'class', value: this.classes.splice(i, 1)[0]});
          modifDone = true;
          break;
        }
      // and, at the end, id. 
      if (! modifDone && this.id && ! this.triedField.id) {
        this.deleted.push({type: 'id', value: this.id, starSetted: true});
        this.id = undefined;
        this.triedField.id = true;
        modifDone = true;
      }
      if (modifDone && ! (this.tag || this.id || this.classes.length > 0 || this.functions.length > 0 || this.attributes.length > 0)) {
        this.tag = '*';
        this.deleted[this.deleted.length-1].starSetted = true;
      }

      return modifDone;
    };
    
    return CssElement;
  })();

  var CssFunction = (function() {

    // An object. The CSS selector ":nth-of-type(2)" is translate in
    // cssFct.name // => "nth-of-type"
    // cssFct.arg // => "2"
    // If the function name is "not", the argument is parsed in a Css object.
    // The CSS selector ":not(span#an_other_id)" is translate in
    // cssFct.name // => "not"
    // cssFct.arg // => Css("span#an_other_id")
    function CssFunction(struct) {
      this.struct = struct;
      this.name = struct.name;
      this.arg = this.name === "not" ? new Css(struct.arg) : struct.arg;
    }

    CssFunction.prototype.toCss = function() {
      var s = ':'+this.name;
      if (this.arg)
        s += '('+this.arg+')';
      return s;
    };

    CssFunction.prototype.clone = function() {
      return new CssFunction(this.struct);
    };

    CssFunction.prototype.valueOf = function() {
      return this.toCss();
    };
    
    CssFunction.prototype.reset = function() {
      bind(CssFunction, this)(this.struct);
      return this;
    };
    
    return CssFunction;
  })();

  var CssAttribute = (function() {

    // An object. The CSS selector "[name^='pseudo']" is translate in
    // cssAttr.name // => "name"
    // cssAttr.method // => "^="
    // cssAttr.value // => "'pseudo'"
    function CssAttribute(struct) {
      this.struct = struct;
      this.name = struct.name;
      this.method = struct.method;
      this.value = struct.value;
    }

    CssAttribute.prototype.toCss = function() {
      var s = '['+this.name;
      if (this.method)
        s += this.method + this.value;
      return s + ']';
    };

    CssAttribute.prototype.clone = function() {
      return new CssAttribute(this.struct);
    };

    CssAttribute.prototype.valueOf = function() {
      return this.toCss();
    };

    CssAttribute.prototype.reset = function() {
      this.triedField = undefined;
      this.deleted = undefined;
      bind(CssAttribute, this)(this.struct);
      return this;
    };

    CssAttribute.prototype.undo = function() {
      var h = this.deleted;
      if (! h) return this;
      this.method = h.method;
      this.value = h.value;
      this.deleted = undefined;
      return this;
    };

    CssAttribute.prototype.simplify = function() {
      if (! this.method || this.triedField)
        return false;
      this.deleted = {method: this.method, value: this.value};
      this.method = undefined;
      this.value = undefined;
      this.triedField = true;
      return true;
    };
    
    return CssAttribute;
  })();

  var CssSeparator = (function() {
    // An object.
    // cssSep.kind // => ">"
    function CssSeparator(struct) {
      this.kind = struct.kind;
      this.deleted = undefined;
    }

    CssSeparator.prototype.valueOf = function() {
      return this.toCss();
    };

    CssSeparator.prototype.isDescendant = function() {
      return this.kind === ' ' || this.kind === '>';
    };

    CssSeparator.prototype.toCss = function() {
      if (this.kind === ' ')
        return ' ';
      else
        return ' '+this.kind+' ';
    };
    
    CssSeparator.prototype.reset = function() {
      this.undo();
      return this;
    };

    CssSeparator.prototype.undo = function() {
      if (! this.deleted) return this;
      this.kind = this.deleted;
      this.deleted = undefined;
      this.tried = true;
      return this;
    };

    CssSeparator.prototype.simplify = function() {
      switch (this.kind) {
        case '+': this.kind = '~'; this.deleted = '+'; return true;
        case '>': this.kind = ' '; this.deleted = '>'; return true;
        default: return false;
      }
    };
    
    return CssSeparator;
  })();

  return Css;
});
