//= require jquery
//= require response
//= require event_emitter
//= require jquery_regex_selector

// Global Event Emitter
globalEventEmitter = new EventEmitter();

// Responsive design
(function () {
    Response.create({
        prop: "width"  // "width" "device-width" "height" "device-height" or "device-pixel-ratio"
        , prefix: "min-width-"  // the prefix(es) for your data attributes (aliases are optional)
        , breakpoints: [769, 1025] // min breakpoints (defaults for width/device-width)
        , lazy: true // optional param - data attr contents lazyload rather than whole page at once
    });

    Response.action(function () {
        // handle flink-menu responsiveness
        $('div.flink-menu').css('text-align', (Response.viewportW() < 769) ? 'right' : 'center');
        $('div:regex(class, flink-menu-category-*)').css('width', (Response.viewportW() < 769) ? 120 : 140);

        // allow controllers js to be called
        globalEventEmitter.emit('response_action');
    });
})();