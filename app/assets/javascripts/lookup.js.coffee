# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
###
initialize = ->
  mapOptions =
    center: new google.maps.LatLng -34.397, 150.644
    zoom: 8
  map = new google.maps.Map $('#map-canvas')[0], mapOptions
google.maps.event.addDomListener window, 'load', initialize
###

###
handler = Gmaps.build 'Google',
  markers:
    clusterer: false

handler.buildMap
  internal:
    id: 'map-canvas'
  ->
    markers = handler.addMarkers(hash_json)
    handler.addPolyline(hash_json)
    handler.bounds.extendWith(markers)
    handler.fitMapToBounds()
###

$ ->
  $('#paste-reset').click ->
    $('#paste').val('')
