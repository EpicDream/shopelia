//
// Author : Vincent Renaudineau
// Created at : 2013-09-10

define(["src/tree"], function(Tree) {
  //
  var SaturnOptions = function(mapping, argOptions) {
    this._optionTree = new Tree();
    this._currentNode = this._optionTree;
    this.mapping = mapping;
    this.argOptions = argOptions;
  };
  // Return root node.
  SaturnOptions.prototype.root = function() {
    return this._optionTree;
  };
  //
  SaturnOptions.prototype.resetToRoot = function() {
    this._currentNode = this._optionTree;
    return this;
  };
  // Get the list of available and set options.
  // Only available after 'normal' strategy is done in SaturnSession.
  SaturnOptions.prototype.options = function() {
    var node = this._optionTree.firstChild(),
        res = [];
    while (node) {
      if (node.value !== null)
        res.push(node.depth());
      node = node.firstChild();
    }
    return res;
  };
  // Get firstOption or null.
  // If options.nonAlone is set to true, check if option is not given in argument, or has not a single value.
  SaturnOptions.prototype.firstOption = function(options) {
    options = options || {};
    var node = this._optionTree.firstChild();
    while (node && (node.value === null || (options.nonAlone && ! node.hasPreviousSibling() && ! node.hasNextSibling())))
      node = node.firstChild();
    return node && node.parent() ? node.parent() : null;
  };
  //
  SaturnOptions.prototype.values = function(node) {
    if (! node)
      return this.values(this._currentNode);
    else if (node.value === null) {
      return this.values(node.childAt(null));
    } else
      return node.children().map(function(e) {return e.value;});
  };
  //
  SaturnOptions.prototype.setValues = function(values) {
    if (! values || ! (values instanceof Array)) {
      throw "ArgumentError : wait an Array of values.";
    } else if (this._currentNode.hasChildren()) {
      throw "currentNode as already values.";
    } else if (values.length === 0) {
      this._currentNode.addChildAt(null, null);
    } else {
      var currentArg = this.argOptions[this._currentNode.depth()+1],
          i;
      // Si la valeur est donnée en argument pour cette option,
      // on ajoute que celle là (si on la trouve).
      if (currentArg) {
        for (i = 0; i < values.length && (! saturn || ! saturn.TEST_ENV || i < 3); i++) {
          var stringified = JSON.stringify(values[i]);
          if (currentArg === stringified) {
            this._currentNode.addChildAt(stringified, values[i]);
            currentArg = null; // pour indiquer qu'on l'a trouvé.
            break;
          }
        }
      }
      // si la valeur n'est pas donnée ou qu'on l'a pas trouvée,
      // on les ajoute toutes.
      if (currentArg !== null) {
        // On place l'élément sélectionné en premier.
        for (i = 1; i < values.length && (! saturn || ! saturn.TEST_ENV || i < 3); i++)
          if (values[i].selected) {
            values.unshift(values.splice(i, 1)[0]);
            break;
          }
        for (i = 0; i < values.length && (! saturn || ! saturn.TEST_ENV || i < 3); i++)
          this._currentNode.addChildAt(JSON.stringify(values[i]), values[i]);
      }
    }
    return this;
  };
  //
  SaturnOptions.prototype.setCurrentVersion = function(version) {
    this._currentNode.version = version;
  };
  //
  SaturnOptions.prototype.next = function(options) {
    options = options || {};
    if (this._currentNode.isLeaf() && options.lookInMapping) {
      var nextOption = this.currentOption()+1;
      if (this.mapping['option'+nextOption] !== undefined)
        return [nextOption];
    }
    var nextNode = this._currentNode.nextNode(options);
    if (nextNode !== null)
      this._currentNode = nextNode;
    if (nextNode === null && (options.rewind !== false && ! options.depthOnly))
      this._currentNode = this._optionTree;

    if (nextNode && nextNode.value === null) {
      return this.next(options);
    } else if (nextNode !== null && nextNode !== this._optionTree) {
      return [nextNode.depth(), nextNode.value];
    } else
      return null;
  };
  //
  SaturnOptions.prototype.currentOption = function() {
    if (this._currentNode === this._optionTree)
      return null;
    return this._currentNode.depth();
  };
  // Return current option setted.
  // If currentNode's value is null, the current option is not available in the page,
  // so return parent's option (recursively).
  SaturnOptions.prototype.currentSetOption = function(node) {
    if (! node)
      return this.currentSetOption(this._currentNode);
    else if (node === this._optionTree)
      return null;
    else if (node.value === null)
      return this.currentSetOption(node.parent());
    else
      return node.depth();
  };
  //
  SaturnOptions.prototype.currentValue = function() {
    return this._currentNode.value;
  };
  //
  SaturnOptions.prototype.currentNode = function() {
    return this._currentNode;
  };
  // Return current state as a cuple [option, value].
  SaturnOptions.prototype.current = function() {
    if (this._currentNode === this._optionTree)
      return null;
    return [this.currentOption(), this.currentValue()];
  };
  // Get the version just for the current node.
  // If version's is a hash, complete it.
  SaturnOptions.prototype.currentVersion = function(version) {
    version = version || this._currentNode.version || {};
    var path = this._currentNode.path();
    for (var i = path.length - 1; i >= 0; i--) {
      if (path[i] !== 'null')
        version['option'+(i+1)] = JSON.parse(path[i]);
    }
    return version;
  };
  // Get number of option currently available (and set in).
  // If currentNode's value is null, the current option is not available in the page,
  // so return parent's option.
  SaturnOptions.prototype.currentNbOption = function() {
    var path = this._currentNode.path(),
        nb = 0;
    for (var i = path.length - 1; i >= 0; i--)
      if (path[i] !== 'null')
        nb++;
    return nb;
  };
  // Recursive versionizing function.
  // Add option of currentNode to currentVersion,
  // If a leaf node, add version if any, and add the total to versions.
  function versionize(versions, currentVersion, currentNode) {
    var currentDepth = currentNode.depth();
    if (currentNode.value !== null || currentNode.value !== undefined)
      currentVersion['option'+currentDepth] = currentNode.value;
    
    if (currentNode.isLeaf())
      versions.push($extend({},currentVersion, currentNode.version || {}));
    else for (var i = 0, l = currentNode.children().length; i < l; i++)
      versionize(versions, currentVersion, currentNode.children()[i]);

    delete currentVersion['option'+currentDepth];
  }
  // Get the partial version of the currentNode.
  SaturnOptions.prototype.partialVersionize = function() {
    var current = this._currentNode,
        version = [];
    versionize(version, this.currentVersion(), current);
    return version;
  };
  // Versionize all optionTree.
  SaturnOptions.prototype.versionize = function() {
    var versions = [];
    versionize(versions, {}, this._optionTree);
    return versions;
  };

  return SaturnOptions;

});
