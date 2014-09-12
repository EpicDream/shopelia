$(function(){
  var coordinates = {};
  var realWidth = $('#image-to-crop').data("width");
  var realHeight = $('#image-to-crop').data("height");
  
	$('#image-to-crop').Jcrop({
		onChange: updateCoordinates,
		onSelect: updateCoordinates,
    aspectRatio: 1 / 1.77,
    trueSize: [realWidth, realHeight] 
	});
  
  function updateCoordinates(c){
    coordinates = c;
    $("#crop-width").text(coordinates.w);
    $("#crop-height").text(coordinates.h);
    $("#crop_x").val(c.x);
    $("#crop_y").val(c.y);
    $("#crop_x2").val(c.x2);
    $("#crop_y2").val(c.y2);
    $("#crop_width").val(c.w);
    $("#crop_height").val(c.h);
  };
});