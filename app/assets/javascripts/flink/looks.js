(function() {
    globalEventEmitter.on('response_action', function () {
        var toggleRowContainerWidth = function(bool) {
            $('div.centered-container').each(function(index, value) {
                $(value).toggleClass('mobile-sized', bool);
                $(value).toggleClass('desktop-sized', !bool);
            });
        }
        var toggleDetailColumnWidth = function(bool) {
            $('div.detail-column').each(function(index, value) {
                $(value).toggleClass('mobile-sized', bool);
            });
        }
        var toggleLookContainer = function(bool) {
            $('div.look-container').each(function(index, value) {
                $(value).toggleClass('mobile-sized', bool);
            });
        }
        var toggleSuggestionsColumn = function(bool) {
            $('div.suggestions-column').each(function(index, value) {
                $(value).toggleClass('mobile-sized', bool);
            });
        }
        toggleRowContainerWidth(Response.viewportW() < 1025);
        toggleDetailColumnWidth(Response.viewportW() < 769);
        toggleLookContainer(Response.viewportW() < 769);
        toggleSuggestionsColumn(Response.viewportW() < 769);
    });
})();