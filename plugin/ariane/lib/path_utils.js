// HTML Utils.
// Author : Vincent Renaudineau
// Created : 31/07/2013

define(['jquery', 'html_utils', 'lib/css_struct'], function($, hu, Css) {

'use strict';

var pu = {};

//
function compArray(t1,t2) {
  if (t1.length != t2.length)
    return false;
  for (var i = 0, l = t1.length ; i < l ; i++)
    if (t1[i] != t2[i])
      return false;
  return true;
}

//
function minimize(cssString, elems, commonAncestor) {
  var css = new Css(cssString),
      found = [];
  // minimized it.
  while (css.simplify()) {
    found = $(css.toCss(), commonAncestor);
    if (found.length != elems.length || ! compArray(found, elems))
      css.undo();
  }
  return css.toCss();
}

/////////////////////////////////////////////////////////////

// Return an array of HTMLNode, the ancestors of /e/,
// closed first.
pu.ancestors = function(e) {
  var ancestors = [];
  while (e != document) {
    e = e.parentNode;
    ancestors.push(e);
  }
  return ancestors;
};

// Idem ancestors + e in first place.
pu.ancestorsAndI = function(e) {
  return [e].concat(pu.ancestors(e));
};

// Search commonAncestor of /elems/.
pu.commonAncestor = function(elems) {
  var parents = [],
      minlen = Infinity,
      i, l;
  for (i = 0, l = elems.length ; i < l ; i++) {
    var curparents = pu.ancestors(elems[i]);
    parents.push(curparents);
    minlen = Math.min(minlen, curparents.length);
  }

  for (i = 0, l = parents.length ; i < l ; i++)
    parents[i] = parents[i].slice(parents[i].length - minlen);

  for (i = 0; i < parents[0].length; i++) {
    var equal = true;
    for (var j in parents) {
      if (parents[j][i] != parents[0][i]) {
        equal = false;
        break;
      }
    }
    if (equal) return parents[0][i];
  }
  return null;
};

// Get the CSS path.
pu.get = function(elems, commonAncestor) {
  // init arguments
  elems = elems instanceof Array ? elems : [elems];
  if (! commonAncestor && ! elems instanceof Array) {
    commonAncestor = document;
    elems = [elems];
  } else if (! commonAncestor)
    commonAncestor = pu.commonAncestor(elems);
  // compute full CSS
  var fullPaths = [];
  for (var i = 0, l = elems.length ; i < l ; i++)
    fullPaths.push( pu.pathFrom(commonAncestor, elems[i]) );
  return fullPaths.join(", ");
};

// Get the minimized CSS path.
pu.getMinimized = function(elems, commonAncestor) {
  // init arguments
  elems = elems instanceof Array ? elems : [elems];
  if (! commonAncestor)
    commonAncestor = elems.length == 1 ? document : pu.commonAncestor(elems);
  return minimize(pu.get(elems, commonAncestor), elems, commonAncestor);
};

// Get minimum CSS path that identifie elements and only them.
// /contexts/ allows to see how page can change,
// which allow to be less specific to the current page.
pu.getMinimumWithContexts = function(elems, contexts) {
  return console.log("Not implemented yet");

  // var matchable = [];
  // for (var i in contexts) {
  //   var c = contexts[i];
  //   var found = $(c.css);
  //   if (found.length > 0)
  //     matchable.push(c.fullCSS)
  // }

  // on a css
  // on minimize
    // si on ne trouve pas le même élément => on undo
    // si le nouveau css ne match plus dans la liste des fullCSS => on undo


  // ==> un css match un autre (full) css ??? ça veut dire qu'il couvre (mathématiquement) l'autre.
  // ==> tous les ééments qui matche le full, match le court.
  // ==> c'est le long avec moins d'éléments.
  // algo backtrack
  // aCss.cover?(anOtherCss) =>
    // aCss.phrases.one? phrase1
      // anOtherCss.find phrase2
        // phrase1.cover?(phrase2)
  // aPhrase.cover?(anOtherPhrase) =>


  // Comment gérer les changements d'éléments matchés ? (span#id => span#id p)
  // On a l'info dans context.outerHtml

/*
Dans les contextes on a des fullCssPath
Ils peuvent représenter le même élément, ou pas.
=> L'idée d'avoir les contextes est d'être moins sensible aux différences entre pages
Ainsi, si un id est différent : 
On peut garder les contextes dont la suite d'élément est identique sans regarder les classes/id/functions/etc
Si on a des diffs, on les supprime
On vérifie que l'on trouve toujours le bon element.


Différence avec merge :
Pour merge, on a deux cssPath, l'ancien et le nouveau (minimizés les deux ?)
On vérifie si on voit les elems avec l'ancien
  si oui => done
sinon
  cas facile, on rajoute ", " ou [] << 
L'idée de [] c'est qu'on ne peut pas avoir de conflit => pas de risque.
Mais il ne faut pas une multiplication non plus.

Si on prend l'exemple des prix sur Amazon ou normalement c'est span# b mais certain c'est span# tout court,
comment être sur qu'une modif du path ne soit pas nuisible...

Pour les tests on peut utiliser l'url source de la page, et vérifier que ça match toujours...
un espace de super minimize, ou à chaque fois on regarde pour toutes les url des contextes pour voir si onretoruve bien tout.

Dans le cas d'un tableau de path, il faut mettre les plus spécifique d'abord.
*/
};

// Compute the CSS path between /from/ and /to/.
pu.pathFrom = function(from, to) {
  var fullCssFrom = hu.getElementCSSSelectors(jQuery(from), true);
  var fullCssTo = hu.getElementCSSSelectors(jQuery(to), true);
  return fullCssTo.replace(fullCssFrom, '').replace(/\s*>?\s*/, '');
};

return pu;

});