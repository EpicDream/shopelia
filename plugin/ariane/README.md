Ariane Chromium Extension
=========================

Ariane is a Chromium plugin used to indicate where to find information on a product url.

Indeed, Viking/Saturn need a mapping to extract information.
For the moment this mapping have to be precise by a humain operator, via Ariane.

Installation
------------

Download the ariane.crx extension file, and drop it in the Google-Chrome window.

Usage
-----

It is composed of a toolbar on top of the webpage.

To indicate where to find informations, the operator select the field in the toolbar, and click on the corresponding element on the page with the Ctrl key hold.

The matched element is highlight. If the matching is good he can pass to the next field.

When finished, it can click on the 'Finished' button.

Petit Guide de la Création de Mapping (PGCM)
--------------------------------------------

Globalement, quand une même information se trouve à différents endroits en fonction de la page,
il est conseillé de faire plusieurs paths, du plus spécific/précis au plus général.

### Titre (name)

### Description (description)
Bien penser à concaténer toutes les descriptions.

### Marque (brand)
Si elle est dans le titre ce n'est pas grave.

### Prix (price)
Il y a souvent deux cas, donc deux paths :

1. d'abord le prix barré;
2. ensuite le prix normal.

### Prix barré (price_strikeout)
Voir Prix ci-dessus.

### Prix de livraison (price_shipping)
Souvent le prix de livraison est commun à tous les produits,
ou alors il y a un prix par défault qui n'est pas affiché en général.
Récupérez-le, celui-ci va aller dans le MerchantHelper.
  
Essayez de trouver des objets très différents en poids / volume,
et qui on peut être un prix de livraison différent indiqué sur la page produit.
  
Il y a aussi régulièrement un prix de commande au delà duquel la livraison est offerte.
Récupérez-le, il ira aussi dans le MerchantHelper.

### Disponibilité (availability)
Souvent absent, il va falloir ruser.
On considère dans ce cas, que si la dispo est absente, c'est que le produit est en stock.
On précise ce paramètre dans le MerchantHelper. Mais nous n'allons pas le faire tout de suite,
car d'abord, il faut trouver tous les autres cas !
  
Il faut dans un premier temps chercher des produits avec des couleurs/tailles/options en général non disponible,
en rupture de stock, en cours de réapproviennement, etc.
  
Ensuite, on va laisser aller voir dans l'admin/Viking tous les produits déjà demandés.
Il y a des grandes chances qu'on trouve des liens mal formés, vers des catégories, des produits plus proposés, etc.
Quand un produit n'est plus proposé, on arrive souvent sur la page de recherche/catégorie avec des produits similaires.
Un moyen de s'en apercevoir est de chercher le nombre de résultats ("154 articles pour cette recherche").
On va ensuite préciser dans le MerchantHelper (dans @availabilities) que si l'availability match /\d+ articles/i,
c'est que le produit n'est pas disponible.
  
FAIRE TRES ATTENTION A L'ORDRE DES PATHS !

### Image principale (image_url)
Pour un produit, la plupart du temps, on a des miniatures ou thumb (~50x50 px),
une grande image ~ (500x500 px) et un zoom (~ 1000x1000 px) quand on clic ou qu'on passe sur la grande image.
On veut bien évidemment récupérer le zoom pour chaque image.
  
ATTENTION ! Souvent on ne peut pas récupérer directement le zoom de l'image principale,
celui-ci n'est disponible dans le DOM que quand on est sur la grande image.
  
On récupère donc la src de la grande image dans image_url,
et les src des miniatures dans images.
  
Souvent la base de ces url est communes, avec en plus l'id du produit (5489),
du numéro de l'image pour ce produit (1, 2, 3, etc),
et de la taille de l'image désirée (thumb/zoom, s/m/l/xl, 50x50/640x640, etc).
On va donc chercher ce qui caractérise la taille, et ce qu'il faut changer pour passer de la miniature directement au zoom !
  
Cela ce traduira par une regex dans le MerchantHelper (dans @image_sub).
Par exemple, pour NikeCom, on a

    @image_sub = [/(?<=wid=|hei=)\d+(?=&)/, '1860']

qui dit qu'il faut chercher dans l'url les endroits on on trouve "wid=" ou "hei=" suivit de chiffres, avec un "=" après,
et qu'il faut remplacer ces chiffres par "1860".

### Autres images (images)
Voir ci-dessus.

### Rating (rating)
Pour les sites qui proposent de noter les articles, on récupère le score, noté sur 5.
  
ATTENTION ! Si le score n'est pas noté sur 5, il faudra le converture en note sur 5 dans le MerchantHelper.

### Option 1 (option1)
De préférence la couleur.
  
ATTENTION ! Même si des couleurs sont indisponibles, c'est à dire grisées par exemple,
il faut les récupérer quand même, car souvent, cela veut juste dire que la couleur n'est pas disponible pour la taille sélectionnée,
mais qu'elle est disponible pour d'autres tailles.

### Option 2 (option2)
De préférence la taille.
  
ATTENTION ! Il ne faut récupérer que les tailles disponibles, c'est à dire non grisées par exemple.

### Option N (optionN)

ATTENTION ! Pour les options supplémentaires, il ne faut récupérer que celles disponibles, c'est à dire non grisées par exemple.

Un bon path d'option est un path, qui pointe vers un élément ayant un id, une image, ou ayant un texte explicite.
Il faut préférer l'image si elle est disponible.
Pour certains élements, il n'y a ni texte, ni élément image, ce qui est problématique pour l'affichage utilisateur.
Ces éléments ont alors soit une image "en background-image" ou alors une couleur "en background-color", qui sont toutes les deux des .

Developpers
-----------

There are three main files :

- background.js
- toolbar_contentscript.js
- mapping_contentscript.js

### background.js

It's the logic piece of the program.
It communicate with the server, load the pages and the contentscript.

Common scenario :

1. background ask for a website to map ;
2. it load the product url ;
3. it load the toolbar ;
4. foreach field in the toolbar :
  5. the operator select it ;
  6. the operator click on it in the page ;
  7. the element is highlight ;
  8. if the mapping is false, retry by clicking on a different place.
  9. if the mapping is good, pass to the next field.
10. when all fields are mapped, the operator click on 'Finished'.
10bis. if there is a problem, he can 'Abort' the mapping.
12. It restart to step 1.

### toolbar_contentscript.js

It load the toolbar and build it.

It handles the 'Finished' and the 'Abort' buttons.

### mapping_contentscript.js

It captures operator's click, the context of the clicked element, and send it to the background.

TODO List
---------

Améliorer le merge : quand nouveaux éléments à la fin de mergeMapping(), popup avec tous les résultats et les choix.

Add css to add dashed border on all blocks in the page's body.

      // on body elements hover, border them.
      // var borderStyle = {border: "dashed red", "border-width": "1px 0px"};
      // $("body *").each(function() {
      //   var e = $(this);
      //   e.data("oldBorder", e.css("border"))
      // }).hover(function(event) {
      //   if (event.target != this) return;
      //   console.log("in", this.tagName, event);
      //   // on border l'élém sur lequel on vient d'entrer
      //   $(this).css(borderStyle);
      //   // on enlève le border de l'élément qu'on quitte
      //   var related = $(event.relatedTarget);
      //   related.css("border", related.data("oldBorder"));
      // }, function(event) {
      //   if (event.target != this) return;
      //   console.log("out", this.tagName, event);
      //   // on enlève le border de l'élément qu'on quitte
      //   if (event.target != this) return;
      //   var e = $(this);
      //   e.css("border", e.data("oldBorder"));
      //   // on border l'élém sur lequel on vient d'entrer
      //   $(event.relatedTarget).css(borderStyle);
      // });

      // var elemBorder = $("<div id='ariane-floated-border'>").css({position:"fixed", border: '1px dashed red'});
      // $("body").append(elemBorder);
      // $("body *:not(#ariane-floated-border)").hover(function(event) {
      //   if (event.target != this) return;
      //   var e = $(event.target);
      //   console.log(e, event);
      //   elemBorder.width(e.width()).height(e.height()).offset(e.offset()).css('z-index', parseInt(e.css('z-index'))+1);
      // });

Use require.js.

On toolbar button hover, show matched element(s), in body.
      // b.hover((function(elems) return function(event) {
      //   elems.effect("highlight", {color: "#00cc00" }, "slow");
      // })(mappingRes[key]));

See pageAction to replace browserAction.

Add a panel at the right of the page, like the first mapper extension.
This panel, that we will be hidable, will be used to edit paths.
It will be the editPathPage of the mapper.
We will see the current prod mapping if available, the current new mapping, and possibly other previous mapping.

Add a (button?) to call saturn for this page and this mapping and see the result.
Can use an inter extension message.
// else if (msg.act == 'crawl') {
//    chrome.runtime.sendMessage("nhledioladlcecbcfenmdibnnndlfikf", {tabId: tabId, url: tasks[tabId].url});
// }

// // On other extension message (Ariane for exemple)
// chrome.runtime.onMessageExternal.addListener(function(msg, sender) {
//   if (sender.id != "nhledioladlcecbcfenmdibnnndlfikf")
//     return;  // don't allow this extension access
//   console.log(msg);
// });


During merging, for a field, for each path :
while (the old-path is found in the page)
  continue;
insert(the new path); // (before the first not found).

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  

[CSS selectors.](http://www.w3schools.com/cssref/css_selectors.asp)
