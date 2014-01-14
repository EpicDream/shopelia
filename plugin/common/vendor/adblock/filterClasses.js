/*
 * This file is part of Adblock Plus <http://adblockplus.org/>,
 * Copyright (C) 2006-2013 Eyeo GmbH
 *
 * Adblock Plus is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Adblock Plus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Adblock Plus.  If not, see <http://www.gnu.org/licenses/>.
 */

define([], function() {
/**
 * @fileOverview Definition of Filter class and its subclasses.
 */


/* ********************************************************************* */

/**
 * Abstract base class for filters
 *
 * @param {String} text   string representation of the filter
 * @constructor
 */
function Filter(text) {
  this.text = text;
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of Filter
 */
Filter.fromJSON = function (o, f) {
  if (! f)
    f = new Filter(o.text);
  return f;
};

/**
 * Cache for known filters, maps string representation to filter objects.
 * @type Object
 */
Filter.knownFilters = {__proto__: null};

/**
 * Regular expression that RegExp filters specified as RegExps should match
 * @type RegExp
 */
Filter.regexpRegExp = /^(@@)?\/.*\/(?:\$~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)?$/;
/**
 * Regular expression that options on a RegExp filter should match
 * @type RegExp
 */
Filter.optionsRegExp = /\$(~?[\w\-]+(?:=[^,\s]+)?(?:,~?[\w\-]+(?:=[^,\s]+)?)*)$/;


/**
 * Creates a filter of correct type from its text representation - does the basic parsing and
 * calls the right constructor then.
 *
 * @param {String} text   as in Filter()
 * @return {Filter}
 */
Filter.fromText = function(text) {
  if (text in Filter.knownFilters)
    return Filter.knownFilters[text];
  var ret;
  if (text[0] == "!" || text[0] == "[")
    ret = new CommentFilter(text);
  else
    ret = RegExpFilter.fromText(text);
  Filter.knownFilters[ret.text] = ret;
  return ret;
};

/**
 * Removes unnecessary whitespaces from filter text, will only return null if
 * the input parameter is null.
 * @param String
 * @return String
 */
Filter.normalize = function(text) {
  if (!text)
    return text;
  // Remove line breaks and such
  text = text.replace(/[^\S ]/g, "");
  if (/^\s*!/.test(text)) {
    // Don't remove spaces inside comments
    return text.replace(/^\s+/, "").replace(/\s+$/, "");
  } else
    return text.replace(/\s/g, "");
};

Filter.prototype = {
  /**
   * String representation of the filter
   * @type String
   */
  text: null,

  toString: function()
  {
    return this.text;
  },

  toJSON: function() {
    return {
      text: this.text,
      type: "Filter",
    };
  }
};


/* ********************************************************************* */

/**
 * Class for invalid filters
 * @param {String} text see Filter()
 * @param {String} reason Reason why this filter is invalid
 * @constructor
 * @augments Filter
 */
function InvalidFilter(text, reason) {
  Filter.call(this, text);
  this.reason = reason;
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of InvalidFilter
 */
InvalidFilter.fromJSON = function (o, f) {
  if (! f)
    f = new InvalidFilter(o.text, o.reason);
  Filter.fromJSON.call(this, o, f);
  return f;
};

InvalidFilter.prototype = {
  __proto__: Filter.prototype,
  /**
   * Reason why this filter is invalid
   * @type String
   */
  reason: null,

  toJSON: function() {
    return {
      text: this.text,
      reason: this.reason,
      type: "InvalidFilter",
    };
  }
};


/* ********************************************************************* */

/**
 * Class for comments
 * @param {String} text see Filter()
 * @constructor
 * @augments Filter
 */
function CommentFilter(text) {
  Filter.call(this, text);
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of CommentFilter
 */
CommentFilter.fromJSON = function (o, f) {
  if (! f)
    f = new CommentFilter(o.text);
  Filter.fromJSON.call(this, o, f);
  return f;
};

CommentFilter.prototype = {
  __proto__: Filter.prototype,

  toJSON: function() {
    return {
      text: this.text,
      type: "CommentFilter",
    };
  }
};


/* ********************************************************************* */

/**
 * Abstract base class for filters that can get hits
 * @param {String} text see Filter()
 * @param {String} domains  (optional) Domains that the filter is restricted to separated by domainSeparator e.g. "foo.com|bar.com|~baz.com"
 * @constructor
 * @augments Filter
 */
function ActiveFilter(text, domains) {
  Filter.call(this, text);
  this.domainSource = domains;
  this.__defineGetter__("domains", function() {return this.computeDomains();});
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of ActiveFilter
 */
ActiveFilter.fromJSON = function (o, f) {
  if (! f)
    f = new ActiveFilter(o.text, o.domainSource);
  Filter.fromJSON.call(this, o, f);
  if (o.domains)
    f.__defineGetter__("domains", function () {return o.domains});
  return f;
};

ActiveFilter.prototype = {
  __proto__: Filter.prototype,
  /**
   * String that the domains property should be generated from
   * @type String
   */
  domainSource: null,
  /**
   * Separator character used in domainSource property, must be overridden by subclasses
   * @type String
   */
  domainSeparator: null,
  /**
   * Determines whether the trailing dot in domain names isn't important and
   * should be ignored, must be overridden by subclasses.
   * @type Boolean
   */
  ignoreTrailingDot: true,
  /**
   * Map containing domains that this filter should match on/not match on or null if the filter should match on all domains
   * @type Object
   */
  computeDomains: function () {
    var domains = null;
    if (this.domainSource) {
      var list = this.domainSource.split(this.domainSeparator);
      if (list.length == 1 && list[0][0] != "~") {
        // Fast track for the common one-domain scenario
        domains = {__proto__: null, "": false};
        if (this.ignoreTrailingDot)
          list[0] = list[0].replace(/\.+$/, "");
        domains[list[0]] = true;
      } else {
        var hasIncludes = false;
        for (var i = 0; i < list.length; i++) {
          var domain = list[i];
          if (this.ignoreTrailingDot)
            domain = domain.replace(/\.+$/, "");
          if (domain == "")
            continue;
          var include;
          if (domain[0] == "~") {
            include = false;
            domain = domain.substr(1);
          } else {
            include = true;
            hasIncludes = true;
          }

          if (!domains)
            domains = {__proto__: null};

          domains[domain] = include;
        }
        domains[""] = !hasIncludes;
      }
      delete this.domainSource;
    }
    this.__defineGetter__("domains", function() {return domains;});
    this._domains = domains;
    return domains;
  },
  /**
   * Checks whether this filter is active on a domain.
   * @param String
   * @return Boolean
   */
  isActiveOnDomain: function(docDomain) {
    // If no domains are set the rule matches everywhere
    if (!this.domains)
      return true;
    // If the document has no host name, match only if the filter isn't restricted to specific domains
    if (!docDomain)
      return this.domains[""];

    if (this.ignoreTrailingDot)
      docDomain = docDomain.replace(/\.+$/, "");
    docDomain = docDomain.toUpperCase();

    while (true) {
      if (docDomain in this.domains)
        return this.domains[docDomain];

      var nextDot = docDomain.indexOf(".");
      if (nextDot < 0)
        break;
      docDomain = docDomain.substr(nextDot + 1);
    }
    return this.domains[""];
  },
  /**
   * Checks whether this filter is active only on a domain and its subdomains.
   * @param String
   * @return Boolean
   */
  isActiveOnlyOnDomain: function(docDomain) {
    if (!docDomain || !this.domains || this.domains[""])
      return false;

    if (this.ignoreTrailingDot)
      docDomain = docDomain.replace(/\.+$/, "");
    docDomain = docDomain.toUpperCase();

    for (var domain in this.domains)
      if (this.domains[domain] && domain != docDomain && (domain.length <= docDomain.length || domain.indexOf("." + docDomain) != domain.length - docDomain.length - 1))
        return false;

    return true;
  },

  toJSON: function() {
    var o = Filter.prototype.toJSON.call(this);
    o.type = "ActiveFilter";
    o.domainSource = this.domainSource;
    o.domains = this._domains;
    return o;
  }
};


/* ********************************************************************* */

/**
 * Abstract base class for RegExp-based filters
 * @param {String} text see Filter()
 * @param {String} regexpSource filter part that the regular expression should be build from
 * @param {Number} contentType  (optional) Content types the filter applies to, combination of values from RegExpFilter.typeMap
 * @param {Boolean} matchCase   (optional) Defines whether the filter should distinguish between lower and upper case letters
 * @param {String} domains      (optional) Domains that the filter is restricted to, e.g. "foo.com|bar.com|~baz.com"
 * @param {Boolean} thirdParty  (optional) Defines whether the filter should apply to third-party or first-party content only
 * @constructor
 * @augments ActiveFilter
 */
function RegExpFilter(text, regexpSource, contentType, matchCase, domains, thirdParty) {
  ActiveFilter.call(this, text, domains);

  if (contentType !== null)
    this.contentType = contentType;
  if (matchCase)
    this.matchCase = matchCase;
  if (thirdParty !== null)
    this.thirdParty = thirdParty;

  if (regexpSource.length >= 2 && regexpSource[0] == "/" && regexpSource[regexpSource.length - 1] == "/") {
    // The filter is a regular expression - convert it immediately to catch syntax errors
    this._regexp = new RegExp(regexpSource.substr(1, regexpSource.length - 2), this.matchCase ? "" : "i");
    this.__defineGetter__("regexp", function() {return this._regexp;});
  } else {
    // No need to convert this filter to regular expression yet, do it on demand
    this.regexpSource = regexpSource;
    this.__defineGetter__("regexp", function() {return this.computRegexp();});
  }
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of RegExpFilter
 */
RegExpFilter.fromJSON = function (o, f) {
  if (! f)
    f = new RegExpFilter(o.text, o.regexp, o.contentType, o.matchCase, o.sourceDomains, o.thirdParty);
  ActiveFilter.fromJSON.call(this, o, f);
  return f;
};

RegExpFilter.prototype = {
  __proto__: ActiveFilter.prototype,
  /**
   * Number of filters contained, will always be 1 (required to optimize Matcher).
   * @type Integer
   */
  length: 1,
  /**
   * @see ActiveFilter.domainSeparator
   */
  domainSeparator: "|",
  /**
   * Expression from which a regular expression should be generated - for delayed creation of the regexp property
   * @type String
   */
  regexpSource: null,
  /**
   * Content types the filter applies to, combination of values from RegExpFilter.typeMap
   * @type Number
   */
  contentType: 0x7FFFFFFF,
  /**
   * Defines whether the filter should distinguish between lower and upper case letters
   * @type Boolean
   */
  matchCase: false,
  /**
   * Defines whether the filter should apply to third-party or first-party content only. Can be null (apply to all content).
   * @type Boolean
   */
  thirdParty: null,
  /**
   * Regular expression to be used when testing against this filter
   * @type RegExp
   */
  computRegexp: function () {
    // Remove multiple wildcards
    var source = this.regexpSource.replace(/\*+/g, "*");

    // Remove leading wildcards
    if (source[0] == "*")
      source = source.substr(1);

    // Remove trailing wildcards
    var pos = source.length - 1;
    if (pos >= 0 && source[pos] == "*")
      source = source.substr(0, pos);

    source = source.replace(/\^\|$/, "^")       // remove anchors following separator placeholder
                   .replace(/\W/g, "\\$&")    // escape special symbols
                   .replace(/\\\*/g, ".*")      // replace wildcards by .*
                   // process separator placeholders (all ANSI charaters but alphanumeric characters and _%.-)
                   .replace(/\\\^/g, "(?:[\\x00-\\x24\\x26-\\x2C\\x2F\\x3A-\\x40\\x5B-\\x5E\\x60\\x7B-\\x80]|$)")
                   .replace(/^\\\|\\\|/, "^[\\w\\-]+:\\/+(?!\\/)(?:[^.\\/]+\\.)*?") // process extended anchor at expression start
                   .replace(/^\\\|/, "^")       // process anchor at expression start
                   .replace(/\\\|$/, "$");      // process anchor at expression end

    this._regexp = new RegExp(source, this.matchCase ? "" : "i");
    // delete this.regexpSource;
    this.__defineGetter__("regexp", function() {return this._regexp;});
    return this._regexp;
  },
  /**
   * Tests whether the URL matches this filter
   * @param {String} location URL to be tested
   * @param {String} contentType content type identifier of the URL
   * @param {String} docDomain domain name of the document that loads the URL
   * @param {Boolean} thirdParty should be true if the URL is a third-party request
   * @return {Boolean} true in case of a match
   */
  matches: function(location, contentType, docDomain, thirdParty) {
    if (this.regexp.test(location) &&
        (RegExpFilter.typeMap[contentType] & this.contentType) !== 0 &&
        (this.thirdParty === null || this.thirdParty == thirdParty) &&
        this.isActiveOnDomain(docDomain))
    {
      return true;
    }

    return false;
  },

  toJSON: function() {
    var o = ActiveFilter.prototype.toJSON.call(this);
    o.type = "RegExpFilter";
    o.contentType = this.contentType;
    o.matchCase = this.matchCase;
    o.thirdParty = this.thirdParty;
    if (this._regexp) {
      o.regexp = ''+this._regexp;
      if (o.regexp.slice(-1) === "i")
        o.regexp = o.regexp.slice(0, -1);  
    } else
      o.regexp = this.regexpSource;
    return o;
  }
};

RegExpFilter.prototype.__defineGetter__("0", function () {return this;});

/**
 * Creates a RegExp filter from its text representation
 * @param {String} text   same as in Filter()
 */
RegExpFilter.fromText = function(text) {
  var blocking = true;
  var origText = text;
  if (text.indexOf("@@") === 0) {
    blocking = false;
    text = text.substr(2);
  }

  var contentType = null;
  var matchCase = null;
  var domains = null;
  var siteKeys = null;
  var thirdParty = null;
  var collapse = null;
  var options;
  var match = (text.indexOf("$") >= 0 ? Filter.optionsRegExp.exec(text) : null);
  if (match) {
    options = match[1].toUpperCase().split(",");
    text = match.input.substr(0, match.index);
    for (var option in options) {
      var value = null;
      var separatorIndex = option.indexOf("=");
      if (separatorIndex >= 0) {
        value = option.substr(separatorIndex + 1);
        option = option.substr(0, separatorIndex);
      }
      option = option.replace(/-/, "_");
      if (option in RegExpFilter.typeMap) {
        if (contentType === null)
          contentType = 0;
        contentType |= RegExpFilter.typeMap[option];
      } else if (option[0] === "~" && option.substr(1) in RegExpFilter.typeMap) {
        if (contentType === null)
          contentType = RegExpFilter.prototype.contentType;
        contentType &= ~RegExpFilter.typeMap[option.substr(1)];
      }
      else if (option === "MATCH_CASE")
        matchCase = true;
      else if (option === "~MATCH_CASE")
        matchCase = false;
      else if (option === "DOMAIN" && typeof value != "undefined")
        domains = value;
      else if (option === "THIRD_PARTY")
        thirdParty = true;
      else if (option === "~THIRD_PARTY")
        thirdParty = false;
      else if (option === "COLLAPSE")
        collapse = true;
      else if (option === "~COLLAPSE")
        collapse = false;
      else if (option === "SITEKEY" && typeof value != "undefined")
        siteKeys = value.split(/\|/);
      else
        return new InvalidFilter(origText, "Unknown option " + option.toLowerCase());
    }
  }

  if (!blocking && (contentType === null || (contentType & RegExpFilter.typeMap.DOCUMENT)) &&
      (!options || options.indexOf("DOCUMENT") < 0) && !/^\|?[\w\-]+:/.test(text))
  {
    // Exception filters shouldn't apply to pages by default unless they start with a protocol name
    if (contentType === null)
      contentType = RegExpFilter.prototype.contentType;
    contentType &= ~RegExpFilter.typeMap.DOCUMENT;
  }
  if (!blocking && siteKeys)
    contentType = RegExpFilter.typeMap.DOCUMENT;

  try {
    if (blocking)
      return new BlockingFilter(origText, text, contentType, matchCase, domains, thirdParty, collapse);
    else
      return new WhitelistFilter(origText, text, contentType, matchCase, domains, thirdParty, siteKeys);
  } catch (e) {
    return new InvalidFilter(origText, e);
  }
};

/**
 * Maps type strings like "SCRIPT" or "OBJECT" to bit masks
 */
RegExpFilter.typeMap = {
  OTHER: 1,
  SCRIPT: 2,
  IMAGE: 4,
  STYLESHEET: 8,
  OBJECT: 16,
  SUBDOCUMENT: 32,
  DOCUMENT: 64,
  XBL: 1,
  PING: 1,
  XMLHTTPREQUEST: 2048,
  OBJECT_SUBREQUEST: 4096,
  DTD: 1,
  MEDIA: 16384,
  FONT: 32768,

  BACKGROUND: 4,    // Backwards compat, same as IMAGE

  POPUP: 0x10000000,
};


/* ********************************************************************* */

/**
 * Class for blocking filters
 * @param {String} text see Filter()
 * @param {String} regexpSource see RegExpFilter()
 * @param {Number} contentType see RegExpFilter()
 * @param {Boolean} matchCase see RegExpFilter()
 * @param {String} domains see RegExpFilter()
 * @param {Boolean} thirdParty see RegExpFilter()
 * @param {Boolean} collapse  defines whether the filter should collapse blocked content, can be null
 * @constructor
 * @augments RegExpFilter
 */
function BlockingFilter(text, regexpSource, contentType, matchCase, domains, thirdParty, collapse) {
  RegExpFilter.call(this, text, regexpSource, contentType, matchCase, domains, thirdParty);
  this.collapse = collapse;
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of BlockingFilter
 */
BlockingFilter.fromJSON = function (o, f) {
  if (! f)
    f = new BlockingFilter(o.text, o.regexp, o.contentType, o.matchCase, o.sourceDomains, o.thirdParty, o.collapse);
  RegExpFilter.fromJSON.call(this, o, f);
  return f;
};

BlockingFilter.prototype = {
  __proto__: RegExpFilter.prototype,
  /**
   * Defines whether the filter should collapse blocked content. Can be null (use the global preference).
   * @type Boolean
   */
  collapse: null,

  toJSON: function() {
    var o = RegExpFilter.prototype.toJSON.call(this);
    o.type = "BlockingFilter";
    o.collapse = this.collapse;
    return o;
  }
};


/* ********************************************************************* */

/**
 * Class for whitelist filters
 * @param {String} text see Filter()
 * @param {String} regexpSource see RegExpFilter()
 * @param {Number} contentType see RegExpFilter()
 * @param {Boolean} matchCase see RegExpFilter()
 * @param {String} domains see RegExpFilter()
 * @param {Boolean} thirdParty see RegExpFilter()
 * @param {String[]} siteKeys public keys of websites that this filter should apply to
 * @constructor
 * @augments RegExpFilter
 */
function WhitelistFilter(text, regexpSource, contentType, matchCase, domains, thirdParty, siteKeys) {
  RegExpFilter.call(this, text, regexpSource, contentType, matchCase, domains, thirdParty);

  if (siteKeys !== null)
    this.siteKeys = siteKeys;
}

/**
 * @param o is an object from toJSON
 * @param f (optional) is subclass of WhitelistFilter
 */
WhitelistFilter.fromJSON = function (o, f) {
  if (! f)
    f = new WhitelistFilter(o.text, o.regexp, o.contentType, o.matchCase, o.sourceDomains, o.thirdParty, o.siteKeys);
  RegExpFilter.fromJSON.call(this, o, f);
  return f;
};

WhitelistFilter.prototype = {
  __proto__: RegExpFilter.prototype,
  /**
   * List of public keys of websites that this filter should apply to
   * @type String[]
   */
  siteKeys: null,

  toJSON: function() {
    var o = RegExpFilter.prototype.toJSON.call(this);
    o.type = "WhitelistFilter";
    o.siteKeys = this.siteKeys;
    return o;
  }
};


/* ********************************************************************* */

return {
  Filter: Filter,
  InvalidFilter: InvalidFilter,
  CommentFilter: CommentFilter,
  ActiveFilter: ActiveFilter,
  RegExpFilter: RegExpFilter,
  WhitelistFilter: WhitelistFilter,
  BlockingFilter: BlockingFilter,
};

});