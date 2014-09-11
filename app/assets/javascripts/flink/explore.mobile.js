//= require jquery

$(document).ready(function() {

    var listenViewport = function(viewport) {

        var isRunning = false;
        var currentPage = 2;
        var carousel = viewport.children('.covers-carousel');
        var category = carousel.data('category');

        // observe scroll
        viewport.bind('scroll', function() {

            if (isRunning) return ;
            if (viewport.scrollLeft() + viewport.width() >= carousel.width() * 0.8) {

                 // ajax call
                isRunning = true;
                $.get('/explore/' + category + '?page=' + currentPage)
                    .done(function(covers) {
                        var beforeCount = carousel.children('.cover').length;

                        // append ad
                        var div = document.createElement("div");
                        div.className = "ad";
                        var script = document.createElement("script");
                        script.type = "text/javascript";
                        script.src = "http://ib.3lift.com/ttj?inv_code=flink_main_feed";
                        div.insertBefore(script, null);
                        carousel.get(0).insertBefore(div, null);

                        // append covers
                        carousel.append(covers);

                        var afterCount = carousel.children('.cover').length;
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