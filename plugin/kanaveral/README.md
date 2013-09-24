
Chrome Extension Kanaveral
==========================

Kanaveral is a Google Chrome extension that allow to simply pass manually Shopelia orders.

Installation
------------

Usage
-----

Developpers
-----------

TODO
----
  

Refactorisation
---------------

On click sur l'îcone, 
le background récupère un order, 
il récupère les infos qui vont avec (autofill, chez le merchant id ?)
il lance la toolbar,
qui lui demande un order, avec les autofills
il lui renvoie les infos,
elle charge tout.

Quand l'utilisateur fait quelque chose, c'est enregistré dans autofill/event.

Un objet Session qui pour un onglet passé en paramètre (ou créer un nouvel onglet), va s'occuper d'aller récupérer les orders, ouvrir la page, lancer la toolbar, etc.
Il crée une instance de Order et une instance de Autofill.
