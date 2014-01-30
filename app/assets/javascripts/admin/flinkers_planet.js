//= require admin/lib/d3.v3.min.js
//= require admin/lib/topojson.v1.min.js
//= require admin/lib/planetaryjs.min.js

$(document).ready(function() {
  var planet = planetaryjs.planet();
  var canvas = document.getElementById('flinkers-planet');
  var coordinates = $("#flinkers-coordinates").data("flinkers-coordinates");
  
  planet.loadPlugin(planetaryjs.plugins.earth({
    topojson: { file: '../json/world-110m.json' },
    oceans:   { fill:   '#4D5C83' },
    land:     { fill:   '#FFE491' },
    borders:  { stroke: '#515151' }
  }));
  planet.loadPlugin(planetaryjs.plugins.drag({}));
  planet.loadPlugin(planetaryjs.plugins.pings());
  planet.loadPlugin(planetaryjs.plugins.zoom({
    scaleExtent: [300, 800]
  }));
  planet.projection.scale(400).translate([500, 400]).rotate([0, 0, 0]);
  planet.draw(canvas);

  planet.onDraw(function() {
    var rotation = planet.projection.rotate();
    rotation[0] += 0.5;
    if (rotation[0] >= 180) rotation[0] -= 360;
    planet.projection.rotate(rotation);
  });
  
  setInterval(function() {
    for (var i = coordinates.length - 1; i >= 0; i--) {
      var lat = coordinates[i][0];
      var lng = coordinates[i][1];
      planet.plugins.pings.add(lng, lat, { color: '#FF3EB9', ttl:2000, angle: 3});
    }
  }, 2000);
});
