# library(geojsonio)
# library(leaflet)
# 
# states <- geojsonio::geojson_read("https://rstudio.github.io/leaflet/json/us-states.geojson", what = "sp")
# class(states)
# 
# access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjbGFzazNpOTgyM3pxM3ZvNXh4d2NvN2pkIn0.I39U-VPf6gW9EtZ-GuJvaQ"
# 
# 
# m <- leaflet(states) %>%
#   setView(-96, 37.8, 4) %>%
#   addProviderTiles("MapBox", options = providerTileOptions(
#     id = "mapbox.light",
#     accessToken = Sys.getenv(access_token)))
# m %>% addPolygons()




library(leaflet)
library(mapboxapi)

leaflet() %>%
  addMapboxTiles(
    style_url = "mapbox://styles/rjameswswc/ck9lsb9k503nq1ipkuyyi4wlq",
    scaling_factor = c("1x", "0.5x", "2x"),
    access_token = "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjbGFzazNpOTgyM3pxM3ZvNXh4d2NvN2pkIn0.I39U-VPf6gW9EtZ-GuJvaQ"
  ) %>%
  setView(
    lng = -111.0051,
    lat = 40.7251,
    zoom = 13
  )