//
// Author : Vincent Renaudineau
// Created at : 2013-09-12

(function() {
  "use strict";

  var Tree = function(parent, previousSibling, nextSibling) {
    this.value = undefined;
    this._previousSibling = previousSibling || null;
    this._nextSibling = nextSibling || null;
    this._childrenH = {};
    this._childrenA = [];
    this._nbChildren = 0;
    this._parent = parent || null;
  };

  Tree.prototype.parent = function() {
    return this._parent;
  };

  Tree.prototype.hasChildren = function() {
    return this._nbChildren !== 0;
  };

  Tree.prototype.isLeaf = function() {
    return ! this.hasChildren();
  };

  Tree.prototype.firstChild = function() {
    return this._childrenA[0];
  };

  Tree.prototype.lastChild = function() {
    return this._childrenA[this._nbChildren-1];
  };

  Tree.prototype.childAt = function(idx) {
    return this._childrenH[idx];
  };

  Tree.prototype.hasNextSibling = function() {
    return this._nextSibling !== null;
  };

  Tree.prototype.hasPreviousSibling = function() {
    return this._previousSibling !== null;
  };

  Tree.prototype.nextSibling = function() {
    return this._nextSibling;
  };

  Tree.prototype.previousSibling = function() {
    return this._previousSibling;
  };

  Tree.prototype.addChildAt = function(idx, value) {
    var e;
    if (this.hasChildren()) {
      var lastChild = this.lastChild();
      e = new Tree(this, lastChild);
      lastChild._nextSibling = e;
    } else
      e = new Tree(this);
    this._childrenH[idx] = e;
    this._childrenA.push(e);
    this._nbChildren++;
    e.value = value;
    return e;
  };

  Tree.prototype.addChild = function(value) {
    this.addChildAt(this._nbChildren, value);
  };

  Tree.prototype.nextNode = function(options) {
    options = options || {};
    if (this._childrenA[0] && (! options.maxDepth || this.depth() < options.maxDepth)) {
      return this._childrenA[0];
    } else if (this._nextSibling && ! options.depthOnly && (! options.maxDepth || this.depth() <= options.maxDepth)) {
      return this._nextSibling;
    } else if (! options.depthOnly && options.rewind !== false) { // Warning default rewind is true, so undefined == true !
      var parent = this.parent();
      while (parent && ! parent.hasNextSibling())
        parent = parent.parent();
      if (! parent)
        return null;
      else 
        return parent.nextSibling();
    } else
      return null;
  };

  Tree.prototype.nextLeaf = function(options) {
    var nextNode = this.nextNode(options);
    while (nextNode !== null && nextNode.hasChildren())
      nextNode = nextNode.nextNode(options);
    return nextNode;
  };

  Tree.prototype.nextNonLeaf = function(options) {
    var nextNode = this.nextNode(options);
    while (nextNode !== null && nextNode.isLeaf())
      nextNode = nextNode.nextNode(options);
    return nextNode;
  };

  Tree.prototype.next = Tree.prototype.nextNode;

  Tree.prototype.depth = function() {
    var depth = 0,
        parent = this.parent();
    while (parent) {
      parent = parent.parent();
      depth++;
    }
    return depth;
  };

  Tree.prototype.children = function() {
    return this._childrenA;
  };

  Tree.prototype.indexOf = function(subtree) {
    for (var i in this._childrenH)
      if (this._childrenH[i] === subtree)
        return i;
    return -1;
  };

  Tree.prototype.path = function() {
    var path = [];
    var current = this;
    while (current.parent()) {
      path.splice(0,0,current.parent().indexOf(current));
      current = current.parent();
    }
    return path;
  };

  Tree.prototype.root = function() {
    var current = this;
    while (current.parent())
      current = current.parent();
    return current;
  };

  // Return child
  Tree.prototype.removeChild = function(child) {
    var arrayIdx = this._childrenA.indexOf(child),
        hashIdx;

    for (var i in this._childrenH)
      if (this._childrenH[i] === child) {
        hashIdx = i;
        break;
      }

    this._childrenA.splice(arrayIdx, 1);
    delete this._childrenH[hashIdx];
    this._nbChildren -= 1;

    if (child._previousSibling)
      child._previousSibling._nextSibling = child._nextSibling || null;
    if (child._nextSibling)
      child._nextSibling._previousSibling = child._previousSibling || null;

    return child;
  };

  if ("object" == typeof module && module && "object" == typeof module.exports)
    exports = module.exports = Tree;
  else if ("function" == typeof define && define.amd)
    define("tree", [], function(){return Tree;});
  else
    window.Tree = Tree;

})();
