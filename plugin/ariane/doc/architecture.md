
Ariane's Architecture
=====================

Ariane est une extension Chrome, elle est donc séparée en différents composants/scripts ayant des restrictions et des possibilités différentes.

Chaque script n'a ensuite pas d'architecture particulière, ce ne sont que des successions de fonctions.

Le script de background
-----------------------

Le script de background est lancé au lancement du navigateur en arrière plan.

Il peut manipuler tous ce qui est de l'ordre du navigateur (tabs, urls, windows, etc), mais il ne peut pas intéragir avec le contenu d'une page web.

Il y a une seule instance pour toutes les fenêtres/onglets/pages.

Les content scripts
------------------

Le background script ne peut pas intéragir avec le contenu de la page, mais le content script peut.

Pour le moment tous les content script sont chargés à chaque chargement de page (obligatoire pour le debugage).

Quand l'extension est lancée pour une page, le background envoie un message au content script pour lui dire "charge toi !".

Les content scripts on un context javascript différent du context de la page, ainsi on ne peut pas accèder 
aux variables globales définies par la page elle-même de même qu'elle ne peut pas accéder aux notres.
On a seulement accès au dom.

Un des problèmes des content scripts est qu'ils perdent ce contexte quand la page est changé ou reloadé.

Ici les content scripts sont séparés en deux :

1- le content script qui se charge de la toolbar ;
2- le content script qui se charge du mapping à proprement parler.

Le toolbar content script
-------------------------

Il ne s'occupe que de la toolbar.
Il l'ajoute dans le dom, initialise le jQuery-UI et les listeners.

Il s'occupe de maintenir l'état de la toolbar, les transitions, etc.

Le mapping content script
-------------------------

Lui il s'occupe de la partie page web du commmerçant.

Il récupère les évenèments qui se passent dans la page (click),
récupère le chemin associé à l'élément, et l'envoie au background.

Il s'occupe aussi de chercher les éléments qu'il connaît déjà pour l'indiquer à la toolbar.

### More Documentation

[Chrome extensions, pour commencer.](http://developer.chrome.com/extensions/getstarted.html)  
[Chrome extensions, Background Pages.](http://developer.chrome.com/extensions/background_pages.html)  
[Chrome extensions, Content Scripts.](http://developer.chrome.com/extensions/content_scripts.html)  
