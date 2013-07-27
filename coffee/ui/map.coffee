root = exports ? this

$('#map-page').live 'pageinit', ->
  # Adjust map size when orientation changes
  $(window).bind 'orientationchange resize', resizeMap
  
  # Perform geolocation
  $('#map-locate').bind 'click', zoomToLocation
  
  # View the Legend
  $('#map-legend').bind 'click', viewLegend
  
  # Set the map to the right size for now
  resizeMap()
  
  # Geologic Map Layer
  geomapUrl = 'http://services.azgs.az.gov/ArcGIS/services/GeologicMapOfArizona/MapServer/WMSServer'
  geomapOpts =
    layers: '0,1,2'
    format: 'image/png'
    transparent: true
    attribution: 'AZGS 2012'
    opacity: 0.6
  geomapLayer = new L.TileLayer.WMS geomapUrl, geomapOpts
  
  # OpenStreetMap Base Layer
  #osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
  osmUrl = 'http://{s}.tile.cloudmade.com/f7d28795be6846849741b30c3e4db9a9/32024/256/{z}/{x}/{y}.png'
  osmLayer = new L.TileLayer osmUrl
  
  # Setup the map
  root.map = map = new L.Map 'map'
  center = new L.LatLng(34.1618, -111.53332);
  map.setView center, 5
  map.addLayer osmLayer
  map.addLayer geomapLayer
  
  # Add Markers for Current Location
  map.on 'locationfound', (location) ->
    map.setView location.latlng, 13
    opts =
      icon: new L.Icon {
        iconUrl: 'style/images/curpos.png'
        iconSize: new L.Point 40, 40
      }
    map.removeLayer map.curpos if map.curpos?    
    map.curpos = new L.Marker(location.latlng, opts)
    map.addLayer map.curpos
    
    radius = location.accuracy / 2
    map.removeLayer map.curacc if map.curacc?
    map.curacc = new L.Circle location.latlng, radius
    map.addLayer map.curacc 
  
  # Bugfix to get map to draw right  
  setTimeout ->
    map.invalidateSize()
  , 1
  return
  
resizeMap = ->
  header = $ ':jqmData(role="header"):visible'
  content = $ ':jqmData(role="content"):visible'
  viewportHeight = $(window).height()
  contentHeight = viewportHeight - header.outerHeight()
  $("article:jqmData(role='content')").first().height(contentHeight);
  $("#map").height(contentHeight);
  
zoomToLocation = ->
  root.map.locate { setView: true }
  
viewLegend = ->
  'http://services.usgin.org/ncgmp/getlegend?format=html&bbox=-108.16279027149%2C-115.77631566212%2C36.38827329239%2C32.336036492243'
  bounds = root.map.getBounds()
  bbox = "#{bounds.getNorthEast().lng},#{bounds.getSouthWest().lng},#{bounds.getNorthEast().lat},#{bounds.getSouthWest().lat}"
  opts = 
    type: 'GET'
    url: 'http://services.usgin.org/ncgmp/getlegend'
    data: {
      format: 'html'
      bbox: bbox
    }
    success: (response) ->
      legend = response.split('<body>')[1].split('</body')[0]
      $('#legend-content').empty().append legend
      $.mobile.changePage '#legend-page', { 'data-rel': 'dialog' }
  $.ajax opts    
