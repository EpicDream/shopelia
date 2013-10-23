// CssMinimizer.
// Author : Vincent Renaudineau
// Created : 2013-10-16

define(['sorted_array', "lib/css_struct"], function(SortedArray, CssStruct) {
  'use strict';

  return (function () {

    var Minimizer = {},
      TAG_GEN = {'div': true, 'span': true, 'p': true, 'tr': true, 'td': true, 'body': true, '*': true},
      COSTS = {
        'tag_gen' : 5,
        'tag_spe' : 3,
        'id' : 1,
        'class' : 2,
        'attribute' : 3,
        'function' : 4,
        'sep' : 1,
        ' ' : 1,
        '>' : 0,
        '~' : 2,
        '+' : 1
      };

    Minimizer.COSTS = COSTS;
    Minimizer.TAG_GEN = TAG_GEN;

    //
    function arraysEqual(t1,t2) {
      if (t1 === t2) { return true; }
      if (t1 === null || t2 === null) { return false; }
      if (t1.length !== t2.length)
        return false;
      for (var i = 0, l = t1.length ; i < l ; i++) {
        if (typeof t1[i] !== typeof t2[i]) {
          return false;
        } else if (t1[i] instanceof Array && t2[i] instanceof Array && ! compArray(t1[i], t2[i])) {
          return false;
        } else if (typeof t1[i] === 'object' && t1[i] !== t2[i]) {
          return false;
        } else if (t1[i] != t2[i]) {
          return false;
        }
      }
      return true;
    }

    function score(struct) {
      var res = 0,
        l = struct.length,
        n = l >= 16 ? l / 4 : 4, // minimum 4
        i, h;
      for (i = l--; i >= 0; i--) { // l-- for (l-i) later
        h = struct[i];
        if (!h)
          continue;
        switch (h.type) {
        case 'tag':
          res += TAG_GEN[h.value] ? COSTS.tag_gen : COSTS.tag_spe;
          break;
        default:
          res += COSTS[h.type];
        }
        // struct is diveded in 4 section by n, each elems in first section cost 3, in second 2, etc.
        res += (l-i) / n >>> 0; // (x >>> 0) == Math.floor(x)
      }
      return res;
    }

    function separate(struct, initialStruct) {
      var children = [],
        sepCtr = 0,
        lastDefIdx, lastSepIdx,
        elem, child, i, l, j;

      for (i = 0, l = initialStruct.length; i < l; i++) {
        elem = struct[i];
        // => struct[i] is defined, et n'est pas un sep
        if (elem && elem.type !== 'sep') {
          for (j = children.length-1; j >= 0 && children[j].newItemIdx !== undefined; j--) {
            child = children[j];
            if (sepCtr-child.nbSep > 0 && child.newItemIdx < lastSepIdx) {
              child[lastSepIdx] = {type: initialStruct[lastSepIdx].type, kind: initialStruct[lastSepIdx].kind};
              child[lastSepIdx].kind = '>';
              if (sepCtr-child.nbSep > 1)
                child[lastSepIdx].kind = ' ';
            }
            delete child.newItemIdx;
          }
          sepCtr = 0;
          lastSepIdx = -1;
          lastDefIdx = i;
        // => struct[i] is undefined, et initialStruct[i] est un sep, et il y a déjà un elem defined dans struct avant
        } else if (initialStruct[i].type === 'sep') {
          lastSepIdx = i;
          sepCtr++;
        // => struct[i] is undefined, et initialStruct[i] n'est pas un sep
        } else {
          child = new CssStruct(struct);
          child[i] = initialStruct[i];
          child.newItemIdx = i;
          child.nbSep = sepCtr;
          if (sepCtr > 0 && lastDefIdx !== undefined)
            child[lastSepIdx] = {type: initialStruct[lastSepIdx].type, kind: '>'};
          if (sepCtr > 1 && lastDefIdx !== undefined)
            child[lastSepIdx].kind = ' ';
          children.push(child);
        }
      }

      for (j = children.length-1; j >= 0 && children[j].newItemIdx !== undefined; j--)
        delete children[j].newItemIdx;

      return children;
    }

    function isSolution(path, waitedRes, $) {
      var found = $(path);
      found = $.fn && $.fn.jquery ? found.toArray() : found;
      return arraysEqual(found, waitedRes);
    }

    Minimizer.minimize = function (initialCss, $, easySolutionCss, options) {
      options = options || {};
      var initialStruct = new CssStruct(initialCss),
        waitedRes = $(easySolutionCss || initialCss),
        bestScore = score(new CssStruct(easySolutionCss || initialCss)),
        open = new SortedArray(function(a, b) {return a.score-b.score}),
        root = new CssStruct(""),
        closed = {},
        res = [],
        current,
        paths,
        child,
        i;

      root.length = initialStruct.length,
      root.score = 0;
      open.insert(root);
      while (open.array.length > 0) {
        current = open.shift();
        if (current.score >= bestScore)
          continue;
        paths = separate(current, initialStruct);
        for (i = 0; i < paths.length; i++) {
          child = paths[i];
          child.cssString = child.toCss();
          if (closed[child.cssString])
            continue;
          child.score = score(child);
          // console.info("Processing child '"+child.cssString+"'", child.score);
          if (isSolution(child.cssString, waitedRes, $)) {
            // console.info("Solution found !");
            if (bestScore > child.score) {
              bestScore = child.score;
              open.trunc({score:bestScore});
            }
            res.push(child);
          } else if (child.score < bestScore) {
            // console.info("Add it.");
            open.insert(child);
          }
          closed[child.cssString] = true;
        }
      }

      res = res.sort(function (a, b) {
        return a.score - b.score;
      }).map(function (s) {
        return s.cssString;
      });

      if (options.maxNbResult === undefined) { 
        return res[0];
      } else {
        return res.slice(0, options.maxNbResult);
      }
    };

    Minimizer.arraysEqual = arraysEqual;
    Minimizer.score = score;
    Minimizer.separate = separate;
    Minimizer.isSolution = isSolution;

    return Minimizer;
  })();
});