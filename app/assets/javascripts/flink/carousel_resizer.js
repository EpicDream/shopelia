(function() {
    var scripts = $('script').get();
    var script = scripts[scripts.length - 1];
    var carousel = $(script).prev();
    var resizer = function(carousel) {
        var childrenCount = $('a.cover').length;
        carousel.width((110 * childrenCount) - 10);
    };

    // observe child count
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            var newNodes = mutation.addedNodes; // DOM NodeList
            if (newNodes !== null) { // If there are new nodes added
                resizer(carousel);
            }
        });
    });

    // Configuration of the observer:
    var config = {
        childList: true,
        subtree: true
    };

    // Pass in the target node, as well as the observer options
    observer.observe(carousel.get(0), config);

    // resize first time
    resizer(carousel);
})();