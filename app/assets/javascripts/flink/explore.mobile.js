//= require jquery

$(document).ready(function() {

    var listenViewport = function(viewport) {

        var isRunning = false;
        var currentPage = 2;
        viewport.bind('scroll', function() {

            if (isRunning) return ;
            var carousel = viewport.children('.covers-carousel');
            var category = carousel.data('category');
            if (viewport.scrollLeft() + viewport.width() >= carousel.width() * 0.8) {

                // ajax call
                isRunning = true;
                $.get('/explore/' + category + '?page=' + currentPage)
                    .done(function(covers) {
                        var beforeCount = carousel.children('.cover').length;
                        carousel.append(covers);
                        var afterCount = carousel.children('.cover').length;
                        carousel.width(110 * afterCount - 10);
                        currentPage++;
                        if (afterCount - beforeCount < 20)
                            viewport.unbind('scroll');
                    })
                    .always(function() {
                        isRunning = false;
                    });
            }
        });
    };

    $(".covers-carousel-viewport").each(function(index, viewport) {
        listenViewport($(viewport));
    });
});