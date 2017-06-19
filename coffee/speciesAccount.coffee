###
# Highlight countries on a Google Map
#
# Use a Fusion Table later
#
# Fusion Tables:
#   - https://developers.google.com/maps/documentation/javascript/fusiontableslayer#constructing_a_fusiontables_layer
#   - https://fusiontables.google.com/DataSource?dsrcid=424206#rows:id=1
#   - Fusion ID: 1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ
#   -
#
###

gMapsConfig =
  jsApiKey: "AIzaSyC_qZqVvNk6A6px4Q7BJQOOHqpnQNihSBA"
  jsApiSrc: "https://maps.googleapis.com/maps/api/js"
  jsApiInitCallbackFn: null

unless isNull window.gMapsLocalKey
  gMapsConfig.jsApiKey = window.gMapsLocalKey


worldPoliticalFusionTableId = "1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ"

baseQuery =
  select: "json_4326" # GeoJson coords: http://blog.mastermaps.com/2011/02/natural-earth-vectors-in-cloud.html
  from: worldPoliticalFusionTableId


appendCountryLayerToMap = (queryObj,  mapObj = "") ->
  ###
  #
  ###
  unless google?.maps?
    console.debug "Loading Google Maps first ..."
    mapPath = "#{gMapsConfig.jsApiSrc}?key=#{gMapsConfig.jsApiKey}"
    if typeof gMapsConfig.jsApiInitCallbackFn is "function"
      mapPath += "&callback=#{gMapsConfig.jsApiInitCallbackFn.name}"
    loadJS mapPath, ->
      appendCountryLayerToMap queryObj, mapObj
      false
    return false
  # Verify the map object is really a map object
  unless mapObj instanceOf google.map.Map
    console.error "Invalid map object provided"
    return false
  # Create a map of plausible query specifications to fusion table
  # lookups
  # Primarily based on IUCNv3 API codes
  # Ex: http://apiv3.iucnredlist.org/api/v3/species/countries/name/Loxodonta%20africana?token=9bb4facb6d23f48efbf424bb05c0c1ef1cf6f468393bc745d42179ac4aca5fee
  fusionColumn =
    code: "postal"
    postal: "postal"
    name: "name"
    country: "name"
  if typeof queryObj is "object"
    build = new Array()
    for col, val of queryObj
      if col in Object.keys fusionColumn
        build.push "`#{fusionColumn[col]}` = '#{val}'"
    query = build.join " OR "
  else
    query = queryObj
  fusionQuery = baseQuery
  fusionQuery.where = query

  false


initMap = (nextToSelector = "#species-note") ->
  ###
  #
  ###
  unless google?.maps?
    console.debug "Loading Google Maps first ..."
    mapPath = "#{gMapsConfig.jsApiSrc}?key=#{gMapsConfig.jsApiKey}"
    if typeof gMapsConfig.jsApiInitCallbackFn is "function"
      selfName = @getName()
      names = [
        selfName
        "initMap"
        ]
      unless gMapsConfig.jsApiInitCallbackFn.getName() in names
        mapPath += "&callback=#{gMapsConfig.jsApiInitCallbackFn.getName()}"
    loadJS mapPath, ->
      initMap nextToSelector
      false
    return false
  unless $(nextToSelector).exists()
    console.error "Invalid page layout to init map"
    return false
  $(nextToSelector)
  .removeClass "col-xs-12"
  .addClass "col-xs-6"
  canvasHtml = """
  <div id="taxon-range-map" class="col-xs-6">
  </div>
  """
  $(nextToSelector).after canvasHtml
  mapDefaults = {}
  mapDiv = $("#taxon-range-map").get(0)
  map = new google.maps.Map mapDiv, mapDefaults
  gMapsConfig.map = map
  map

$ ->
  false
