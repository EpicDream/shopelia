(function() {
    globalEventEmitter.on('response_action', function () {
        var toggleRowContainerWidth = function(bool) {
            $('div.row-container').each(function(index, value) {
                $(value).toggleClass('width-1024', bool);
                $(value).toggleClass('width-100p', !bool);
            });
        }
        toggleRowContainerWidth(Response.viewportW() >= 1024)
    });
})();