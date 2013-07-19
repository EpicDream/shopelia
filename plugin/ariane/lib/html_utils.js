// HTML Utils.
hu = {};

hu.getElementXPath = function(element) {
  var xpath = '';
  for ( ; element && element.nodeType == 1; element = element.parentNode ) {
    var id = $(element).attr("id");
    if (id && ! hu.isRandom(id)) {
      xpath = '//'+element.tagName.toLowerCase()+'[@id="'+id+'"]'+xpath;
      break;
    } else {
      var broAndSis = $(element.parentNode).children(element.tagName);
      if (broAndSis.size() > 1)
        xpath = '/'+element.tagName.toLowerCase()+'['+(broAndSis.index(element)+1)+']' + xpath;
      else
        xpath = '/'+element.tagName.toLowerCase() + xpath;
    }
  }
  return xpath;
};

hu.getElementCompleteXPath = function(element) {
  var xpath = '';
  for ( ; element && element.nodeType == 1; element = element.parentNode ) {
    var broAndSis = $(element.parentNode).children(element.tagName);
    var id = $(element).attr("id");
    if (id && (id.length < 15 || ! hu.isRandom(id))) {
      xpath = '/'+element.tagName.toLowerCase()+'[@id="'+id+'"]'+xpath;
    } else if (broAndSis.size() > 1)
      xpath = '/'+element.tagName.toLowerCase()+'['+(broAndSis.index(element)+1)+']' + xpath;
    else
      xpath = '/'+element.tagName.toLowerCase() + xpath;

    if (element.tagName == 'body')
      break;
  }
  return xpath;
};

hu.getElementsByXPath = function(xpath) { 
  var aResult = new Array();
  try {
    var a = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
    for ( var i = 0 ; i < a.snapshotLength ; i++ ){aResult.push(a.snapshotItem(i));}
    return aResult;
  } catch(err) {
    console.error("for", xpath);
    console.error(err);
  }
};

hu.isXpath = function(path) {
  return path[0] == '/' || path[0] == '(';
}

function getClasses(jelem) {
  return (jelem.attr("class") ? _.compact(jelem.attr("class").split(/\s+/)).sort() : []);
};

// Get CSS Selector for this element : tagname, id, classes, child position.
// If complete is false, stop when an id is found, or when discriminant classes are found and add only these.
function fromParentSelector(jelement, complete) {
  var tag = jelement[0].tagName;
  // TAGNAME
  var res = tag.toLowerCase();
  // ID
  var id = jelement.attr("id");
  if (id && (id.length < 15 || ! hu.isRandom(id))) {
    res += "#"+id;
    if (! complete)
      return res;
  }
  // Si il n'y a qu'un élément de ce type en enfant, on s'arrête
  var sameTagSiblings = jelement.siblings().filter(function(index) { return this.tagName == tag; });
  if (! complete && sameTagSiblings.length == 0)
    return res;
  // CLASSES
  var elementClasses = getClasses(jelement);
  if (! complete) {
    var siblingsClasses = _.map(sameTagSiblings.filter("*[class]"), function(sibling) { return getClasses($(sibling)); });
    var classes = _.difference(elementClasses, [].concat(_.flatten(siblingsClasses)));
    res += _.map(classes, function(c){return "."+c;}).join('');
    if (classes.length > 0)
      return res;
  } else {
    res += _.map(elementClasses, function(c){return "."+c;}).join('');
  }
  // POSITION
  var pos = jelement.index() + 1;
  res += ":nth-child(" + pos + ")";
  return res;
};

hu.getElementCSSSelectors = function(jelement, complete) {
  var css = '';
  for ( ; jelement && jelement[0].nodeType == 1 ; jelement = jelement.parent() ) {
    elem_selector = fromParentSelector(jelement, complete);
    css = elem_selector + " " + css;
    if (jelement[0].tagName.toLowerCase() == 'body' || (! complete && elem_selector.match(/#/)))
      break;
  }
  return css.trim();
};

// Return an Array of jQuery elements.
hu.getElementsByCSS = function(css) {
  return $(css);
};

// Does this xpath lead to a single element.
hu.isXPathUniq = function(xpath) {
  return hu.getElementsByXPath(xpath).length == 1;
};

// Try to modify xpath to lead to e and only e.
hu.setXPathUniq = function(xpath, e) {
  // Si cours, essai d'ajouter un parent
  // Si long, essai d'ajouter des classes ou des names

  // var elems = hu.getElementsByXPath(xpath);
  // if (elems.length == 1 && elems[0] == e)
  //   return xpath;
  // throw "Don't succeed to set xpath uniq."
  return xpath;
};

hu.nonRandomId = [];
hu.isRandom = function(value) {
  if (value.match(/\d{5,}/))
    return true;
  if (value.length < 8)
    return false;
  var m = value.match(/[a-zA-Z0-9]+/);
  for (var i = 0, mlength = m.length ; i < mlength ; i++) {
    var v = m[i];
    var l = v.length;
    if (l < 8)
      continue;
    var maj = v.match(/[A-Z]/);
    var min = v.match(/[a-z]/);
    var num = v.match(/[0-9]/);
    if ((num > 2 && num < l) || num == l || num > (maj+min)) // Trop de chiffres
      return true;
    if (maj > min && min > 0) // Trop de maj par rapport aux min.
      return true;
  }
  return false;
};

// Return a HashMap h attributes/values.
// Are always present :
// h.tagName, h.id, h.class and h.text.
hu.getElementAttrs = function(e) {
  var attrs = e.attributes;
  var data = {
    tagName: e.tagName,
    id: attrs['id'],
    class: attrs['class'],
    text: e.innerText,
    href: e.ownerDocument.location.href
  };
  if (e.tagName == "INPUT" || e.tagName == "SELECT" || e.tagName == "TEXTAREA") data.value = e.value;
  var type = e.getAttribute("type");
  if (e.tagName == "INPUT" && (type == "radio" || type == "checkbox")) data.checked = e.checked;
  for (var i = 0 ; i < attrs.length ; i++)
    data[attrs[i].name] = attrs[i].value;
  return data;
};
// getElementAttrs + xpath
hu.getLabelAttrs = function(e) {
  var l = hu.getInputsLabel(e);
  if (! l) return {};
  return Object({xpath: hu.getElementXPath(l), id: l.getAttribute("id"), class: l.getAttribute("class"), text: l.innerText})
};
hu.getFormAttrs = function(e) {
  var current = e;
  while (current.tagName.toLowerCase() != "form" && current.tagName.toLowerCase() != "body")
    current = current.parentNode;
  if (current.tagName.toLowerCase() != "form") 
    return {};
  else
    return hu.getElementAttrs(current);
};

// Return a HashMap h.
// h.xpath
// h.fullXPath
// h.css
// h.fullCSS
// h.attrs : element's attrs. See hu.getElementAttrs().
// h.siblings an Array of siblings' attrs. See hu.getElementAttrs().
// h.parent : parent's attrs. See hu.getElementAttrs().
// h.html : e.outerHTML;
// For forms elements :
// h.label : input's label's attributes + xpath. See hu.getElementAttrs().
// h.form : input's form's attributes. See hu.getElementAttrs().
hu.getElementContext = function(e) {
  var context = {};
  context.xpath = hu.getElementXPath(e);
  context.fullXPath = hu.getElementCompleteXPath(e);
  context.css = hu.getElementCSSSelectors($(e));
  context.fullCSS = hu.getElementCSSSelectors($(e), true);
  context.attrs = hu.getElementAttrs(e);
  context.parent = hu.getElementAttrs(e.parentElement);
  context.siblings = [];
  var children = e.parentElement.children;
  for (var i = 0 ; i < children.length ; i++)
    context.siblings.push(hu.getElementAttrs(children[i]));
  context.html = e.outerHTML;

  var tagName = e.tagName.toLowerCase();
  if (tagName == "input" || tagName == "select" || tagName == "textarea") {
    context.label = hu.getLabelAttrs(e);
    context.form = hu.getFormAttrs(e);
  }
  return context;
}

// For an input/textarea/select e, search the corresponding label :
// search first with the 'for' attribute if present,
// search if the label wrap e otherwise.
hu.getInputsLabel = function(e) {
  var nodelist = document.getElementsByTagName("label");
  for (var i = 0 ; i < nodelist.length ; i++) {
    var l = nodelist[i];
    if (l.getAttribute("for") && l.getAttribute("for") == e.getAttribute("id"))
      return l;
    else if (! l.getAttribute("for")) {
      var xpathResult = document.evaluate(".//input | .//textarea | .//select", l, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
      for ( var j = 0 ; j < xpathResult.snapshotLength ; j++ )
        if (xpathResult.snapshotItem(j) == e)
          return l;
    }
  }
};

// Return all know types found for e.
hu.knowTypes = function(e) {
  var types = [];
  types = types.concat(hu.inputs(e));
  types = types.concat(hu.links(e));
  types = types.concat(hu.labels(e));
  return types;
};
// e an input, a select or a textarea,
// or e include some inputs, selects, textarea.
hu.inputs = function(e) {
  var res = [];
  var tag = e.tagName.toLowerCase();
  if (tag == "select" || tag == "textarea" || (tag == "input" && ! (/submit/i).test(e.getAttribute("type"))))
    res.push(e);

  // Look for inputs inside e.
  var xpathresult = document.evaluate(".//input | .//textarea | .//select", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++) {
    var input = xpathresult.snapshotItem(i);
    if (input.tagName.toLowerCase() != "input" || ! (/submit/i).test(input.getAttribute("type")))
      res.push(input);
  }
  return res;
};
// e a a element, a button or a submit input,
// or e include a elements or buttons,
// or e inside a a element or a button.
hu.links = function(e) {
  var res = [];
  var current = e;
  var tag = current.tagName.toLowerCase();
  // Look e + e's ancestors tagName
  while (tag != "a" && tag != "button" && (tag != "input" || ! (/submit/i).test(e.getAttribute("type"))) && tag != "body") {
    current = current.parentNode;
    tag = current.tagName.toLowerCase();
  }
  if (tag == "a" || tag == "button" || (tag == "input" && (/submit/i).test(e.getAttribute("type"))))
    res.push(current);

  // Look for links inside e.
  var xpathresult = document.evaluate(".//a | .//button | .//input[@type='submit']", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++)
    res.push(xpathresult.snapshotItem(i));

  return res;
};
// e a label, or e contains labels,
// or e is inside a label.
hu.labels = function(e) {
  var res = [];
  var current = e;
  var tag = current.tagName.toLowerCase();
  // Look e + e's ancestors tagName
  while (tag != "label" && tag != "body") {
    current = current.parentNode;
    tag = current.tagName.toLowerCase();
  }
  if (tag == "label")
    res.push(current);

  // Look for labels inside e.
  var xpathresult = document.evaluate(".//label", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++)
    res.push(xpathresult.snapshotItem(i));
  
  return res;
};

hu.cookies = {};

hu.cookies.add = function(name,value,days,domain) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime()+(days*24*60*60*1000));
    var expires = "; expires="+date.toGMTString();
  }
  else var expires = "";
  if (domain) domain = "; domain="+domain;
  else domain = "";
  document.cookie = name+"="+value+expires+"; path=/"+domain;
};

hu.cookies.get = function(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
};

hu.cookies.remove = function(name) {
  this.add(name,"",-1);
  if (this.get(name))
    this.add(name,"",-1,document.location.host.match(/\.\w+\.\w+$/)[0]);
};

hu.cookies.keys = function() {
  var res = [];
  var ca = document.cookie.split('; ');
  for(var i=0;i < ca.length;i++) {
    var key = ca[i].match(/^(\w+)(?==)/g);
    if (key)
      res.push(key[0]);
  }
  return res;
};

hu.cookies.removeAll = function() {
  var keys = this.keys();
  for (var i in keys)
    this.remove(keys[i]);
};