// CssMinimizer.
// Author : Vincent Renaudineau
// Created : 2013-10-16

define(["lib/css_struct"], function(CssStruct) {
  'use strict';
  
  return (function () {

    var Minimizer = {},
      TAG_GEN = ['div', 'span', 'p', 'tr', 'td', 'body'],
      COSTS = {
        'tag_gen' : 5,
        'tag_spe' : 3,
        'id' : 1,
        'class' : 2,
        'attribute' : 3,
        'function' : 4,
        'sep' : 0,
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
        i,
        l,
        h;
      for (i = 0, l = struct.length; i < l; i++) {
        h = struct[i];
        if (!h) {
          continue;
        }
        switch (h.type) {
        case 'tag':
          if (TAG_GEN.indexOf(h.value) !== -1) {
            res += COSTS.tag_gen;
          } else {
            res += COSTS.tag_spe;
          }
          break;
        default:
          res += COSTS[h.type];
        }
      }
      return res;
    }

    function separate(struct, initialStruct) {
      /*
      quand j'ajoute un élément, il faut que j'ajoute le separateur si il n'y est pas déjà, et pas '>' mais ' ' si il y en a plusieurs !
      */
      var children = [],
        sepCtr = 0,
        lastDefIdx,
        lastSepIdx,
        elem,
        child,
        i,
        l,
        j;

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
          if (sepCtr > 0 && lastDefIdx !== undefined) {
            child[lastSepIdx] = {type: initialStruct[lastSepIdx].type, kind: initialStruct[lastSepIdx].kind};
            child[lastSepIdx].kind = '>';
          }
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
      found = typeof found.toArray === 'function' ? found.toArray() : found;
      return arraysEqual(found.sort(), waitedRes.sort());
    }

    Minimizer.minimize = function (initialCss, $, easySolutionCss, options) {
      options = options || {};
      var initialStruct = new CssStruct(initialCss),
        waitedRes = $(easySolutionCss || initialCss),
        bestScore = score(new CssStruct(easySolutionCss || initialCss)),
        open = [new CssStruct("")],
        closed = {},
        res = [],
        current,
        paths,
        child,
        i;

      open[0].length = initialStruct.length,
      open[0].score = 0;
      while (open.length > 0) {
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
            if (bestScore > child.score) { bestScore = child.score; }
            res.push(child);
          } else if (child.score < bestScore) {
            // console.info("Add it.");
            open.push(child);
          }
          closed[child.cssString] = true;
        }
        open.sort(function (a, b) {
          return a.score - b.score;
        });
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