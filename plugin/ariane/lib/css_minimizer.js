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
        l = initialStruct.length,
        nbSepBetweenNewAndLastSet,
        lastSepIdx, child, i;

      for (i = 0; i < l && ! struct[i]; i++) {
        if (initialStruct[i].type === 'sep') {
          lastSepIdx = i;
          sepCtr++;
        } else {
          child = new CssStruct(struct);
          child[i] = initialStruct[i];
          child.nbSep = sepCtr;
          children.push(child);
        }
      }

      if (i === l)
        return children;

      for (i = 0, l = children.length; i < l; i++) {
        child = children[i];
        nbSepBetweenNewAndLastSet = sepCtr - child.nbSep;
        delete child.nbSep;
        // On compte sur le fait que dans la boucle précédente,
        // on se rapproche du dernier élément setté de struct.
        if (nbSepBetweenNewAndLastSet === 0)
          break;
        if (nbSepBetweenNewAndLastSet > 0)
          child[lastSepIdx] = {type: 'sep', kind: '>'};
        if (nbSepBetweenNewAndLastSet > 1)
          child[lastSepIdx].kind = ' ';
      }

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
        easySolutionStruct = new CssStruct(easySolutionCss || initialCss),
        bestScore = score(easySolutionStruct),
        open = new SortedArray(function(a, b) {return a.score-b.score}),
        root = new CssStruct(""),
        closed = {},
        res = [easySolutionStruct],
        current,
        paths,
        child,
        i;

      easySolutionStruct.cssString = easySolutionCss;
      easySolutionStruct.score = bestScore;
      root.length = initialStruct.length;
      for (i = initialStruct.length-1; i >= 0 && initialStruct[i].type !== 'sep'; i--) {
        child = new CssStruct(root);
        child[i] = initialStruct[i];
        child.cssString = child.toCss();
        child.score = score(child);
        open.insert(child);
      }
      while (open.array.length > 0) {
        current = open.shift();
        // console.info("process '"+current.cssString+"', score=", current.score);
        if (isSolution(current.cssString, waitedRes, $)) {
          // console.info("Solution found !");
          if (current.score < bestScore) {
            bestScore = current.score;
            open.trunc({score:bestScore});
          }
          res.push(current);
        } else if (current.score < bestScore) {
          paths = separate(current, initialStruct);
          // console.info("Add children :", paths.length);
          for (i = 0; i < paths.length; i++) {
            child = paths[i];
            child.cssString = child.toCss();
            if (closed[child.cssString])
              continue;
            closed[child.cssString] = true;
            child.score = score(child);
            if (child.score < bestScore)
              open.insert(child);
          }
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