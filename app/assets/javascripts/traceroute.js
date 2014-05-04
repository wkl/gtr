if ((typeof avail != "undefined") && !avail && !failed) {
  $('#load').show();
  var sid = setInterval(ajaxCheck, 3000);
}

function ajaxCheck() {
  var request = $.ajax({
    url: "/check/" + uuid + "/",
    type: "POST",
    data: {},
    dataType: "json",
    cache: false
  });

  request.done(function( obj ) {
    if (obj.code == -1) {
      clearInterval(sid);
      $('#load').text(obj.msg);
      $('#loading').hide();
    } else if (obj.code == 1) {
      clearInterval(sid);
      window.location.reload();
    }
  });

  request.fail(function( jqXHR, textStatus ) {
    console.log("request failed: " + textStatus);
    clearInterval(sid);
  });
}

function fitBounds(map, LatLngList) {
  var bounds = new google.maps.LatLngBounds ();
  for (var i = 0, LtLgLen = LatLngList.length; i < LtLgLen; i++) {
    bounds.extend (LatLngList[i]);
  }
  map.fitBounds (bounds);
}

function sameLoc(hop1, hop2) {
  return (hop1.lat == hop2.lat && hop1.lng == hop2.lng)
}

var map;
var lines = [];
var markers = [];
var infoWindows = [];
var lineSymbol = {
  path: 'M 0,-0.5 0,0.5',
  strokeOpacity: 1,
  strokeWeight: 3,
  scale: 3
};
var dash = [{
    icon: lineSymbol,
    offset: '100%',
    repeat: '10px'
}]
var zindexMax = google.maps.Marker.MAX_ZINDEX;

var colorMode = 0;
var skipMode = 0;
function ColorControl(controlDiv, map) {

  controlDiv.style.padding = '5px';

  // Set CSS for the control border
  var controlUI = document.createElement('div');
  controlUI.style.backgroundColor = 'white';
  controlUI.style.borderStyle = 'solid';
  controlUI.style.borderWidth = '2px';
  controlUI.style.cursor = 'pointer';
  controlUI.style.textAlign = 'center';
  controlUI.title = 'Click to toggle color mode';
  controlDiv.appendChild(controlUI);

  // Set CSS for the control interior
  var controlText = document.createElement('div');
  controlText.style.fontFamily = 'Arial,sans-serif';
  controlText.style.fontSize = '12px';
  controlText.style.paddingLeft = '4px';
  controlText.style.paddingRight = '4px';
  controlText.innerHTML = '<b>ColorMode</b>';
  controlUI.appendChild(controlText);

  // Setup the click event listeners
  google.maps.event.addDomListener(controlUI, 'click', function() {
    colorMode = (colorMode + 1) % 3;
    switch (colorMode) {
      case 0:
        h = '<b>Default Color</b>'
        break;
      case 1:
        h = '<b>Relative RTT</b>'
        break;
      case 2:
        h = '<b>Absolute RTT</b>'
        break;
    }
    $(this).html(h);
    drawAll(colorMode, false);
  });
}

function SkipControl(controlDiv, map) {

  controlDiv.style.padding = '5px';

  // Set CSS for the control border
  var controlUI = document.createElement('div');
  controlUI.style.backgroundColor = 'white';
  controlUI.style.borderStyle = 'solid';
  controlUI.style.borderWidth = '2px';
  controlUI.style.cursor = 'pointer';
  controlUI.style.textAlign = 'center';
  controlUI.title = 'Click to skip inaccurate hops';
  controlDiv.appendChild(controlUI);

  // Set CSS for the control interior
  var controlText = document.createElement('div');
  controlText.style.fontFamily = 'Arial,sans-serif';
  controlText.style.fontSize = '12px';
  controlText.style.paddingLeft = '4px';
  controlText.style.paddingRight = '4px';
  controlText.innerHTML = '<b>Hide Inaccurate</b>';
  controlUI.appendChild(controlText);

  // Setup the click event listeners
  google.maps.event.addDomListener(controlUI, 'click', function() {
    skipMode = 1 - skipMode;
    if (skipMode == 1) {
      $(this).html('<b>Show Inaccurate</b>')
      gtr_list = gtr_list_skip;
    } else {
      gtr_list = gtr_list_org;
      $(this).html('<b>Hide Inaccurate</b>')
    }
    drawAll(colorMode, true);
  });
}

function closeAllInfoWindows(infowindow) {
    for (var i = 0; i < infoWindows.length; i++)
      infoWindows[i].close();
    infoWindows = [infowindow,]
}

function drawMarker(hop, openInfo) {
  var image = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + hop.id + "|FE6256|000000"
  var hopLatLng = new google.maps.LatLng(hop.lat, hop.lng);
  var marker = new google.maps.Marker({
      position: hopLatLng,
      map: map,
      icon: image,
  });
  markers.push(marker);

  var contentString = hop.info;

  var infowindow = new google.maps.InfoWindow({
    content: contentString
  });
  google.maps.event.addListener(marker, 'click', function() {
    marker.setZIndex(++zindexMax);
    closeAllInfoWindows(infowindow);
    infowindow.open(map,marker);
  });

  if (openInfo == true) {
    marker.setZIndex(++zindexMax);
    closeAllInfoWindows(infowindow);
    infowindow.open(map,marker);
  }
}

function drawLine(hop1, hop2, colorMode, gap) {
  var path = [];

  path.push(new google.maps.LatLng(hop1.lat, hop1.lng));
  path.push(new google.maps.LatLng(hop2.lat, hop2.lng));

  var red = '#FF0000';
  var blue = '#2E9AFE';
  var orange = '#FE9A2E';
  var color;

  if (colorMode == 1) {
    if (hop2.rtt - hop1.rtt >= 50)
      color = red;
    else
      color = blue;
  } else if (colorMode == 2) {
    if (hop2.rtt >= 150)
      color = red;
    else if (hop2.rtt >= 75)
      color = orange;
    else
      color = blue;
  } else {
    color = blue;
  }
//  console.log(hop2.ip, color, gap);

  var line;
  if (gap) {
    line = new google.maps.Polyline({
      path: path,
      geodesic: false,
      strokeColor: color,
      strokeOpacity: 0,
      icons: dash,
    });
  } else {
    line = new google.maps.Polyline({
      path: path,
      geodesic: false,
      strokeColor: color,
      strokeOpacity: 1.0,
      strokeWeight: 3,
    });
  }

  line.setMap(map);
  lines.push(line);
}

// colorMode 0: normal
//           1: relative
//           2: absolute
function drawAll(colorMode, removeMarker) {
  if (gtr_list.length == 0)
    return;

  // remove all existing lines & markers
  lines.forEach(function(line, index, array) {
    line.setMap(null);
  });
  lines.length = 0;

  if (removeMarker) {
    markers.forEach(function(marker, index, array) {
      marker.setMap(null);
    });
    markers.length = 0;
  }

  var last;
  var i;
  var gap;

  for (i = 0; i < gtr_list.length; i++) {
    if (gtr_list[i].lat != 'n/a') {
      last = gtr_list[i];
      drawMarker(last, false);
      i++;
      break;
    }
  }

  while (i < gtr_list.length) {
    curr = gtr_list[i];

    gap = false;
    while (curr.ip == '*' || curr.lat == 'n/a') {
      gap = true;
      i++;
      if (i == gtr_list.length)
        break;
      curr = gtr_list[i];
    }

    if (i == gtr_list.length)
      break;

    drawLine(last, curr, colorMode, gap);
    if (!sameLoc(last, curr))
      drawMarker(curr, false);

    last = curr;
    i++;
  }
}

function initialize() {
  var mapOptions = {
    zoom: 2,
    center: new google.maps.LatLng(0, -180),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

  drawAll(colorMode, false);

  var allPath = [];
  gtr_list.forEach(function(hop, index, array) {
    if (hop.ip != '*' && hop.lat != 'n/a')
      allPath.push(new google.maps.LatLng(hop.lat, hop.lng));
  });
  if (allPath.length > 0)
    fitBounds(map, allPath);

  var colorControlDiv = document.createElement('div');
  var colorControl = new ColorControl(colorControlDiv, map);

  colorControlDiv.index = 1;

  var skipControlDiv = document.createElement('div');
  var skipControl = new SkipControl(skipControlDiv, map);

  skipControlDiv.index = 1;
  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(colorControlDiv);
  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(skipControlDiv);
}

google.maps.event.addDomListener(window, 'load', initialize);

// page
$('.ip-pop').popover({html:true,});

$('.ip-pop').hover(
    function() {
      $(this).popover('show');
    }, function() {
      $(this).popover('hide');
    }
);

$('.has-marker').click(function(event) {
  event.preventDefault();
  $('html, body').animate({ scrollTop: 0 }, 'fast');
  hopID = parseInt($(this).attr('data'));
  drawMarker(gtr_list_org[hopID], true);
});
