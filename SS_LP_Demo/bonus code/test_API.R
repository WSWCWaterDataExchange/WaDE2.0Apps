# Libraries
library(DT) # Provides an R interface to the JavaScript library DataTables
library(xlsx) # The xlsx package gives programatic control of Excel files using R
library(jsonlite) # These functions are used to convert between JSON data and R objects.
library(curl)  # Drop-in replacement for base url that supports https, ftps, gzip, deflate, etc
library(rJava) # Low-level interface to Java VM very much like .C/.Call and friends. Allows creation of objects, calling methods and accessing fields.
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(plotly) # To create plots within the output for the app.
library(sf)


# The API string
str1 <-  "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
str2 <- "UTssps_S5239" # change here
keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
outString <- paste0(str1,str2,"&",keyStr)
print(outString)

# get API data
returnVal <- fromJSON(outString)

# Site Data
Site <- returnVal[['Organizations']][['Sites']][[1]]

if(is.na(Site$SiteGeometry) == FALSE) {
  print("Yes Geometry")
  inputData <- sf::st_as_sf(Site, wkt = "SiteGeometry")
  createPolyMapFunc(inputData)
} else {
  createSiteMapFunc(Site)
}

#------------------------
# Site Map function
#------------------------
createSiteMapFunc <- function(inputData) {
  mapA <- leaflet() %>%
    addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
    setView(
      lng = inputData$Longitude,
      lat = inputData$Latitude,
      zoom = 10) %>%
    clearGroup(group=c("SiteGroup")) %>%
    addCircleMarkers(
      data = inputData,
      layerId = ~SiteUUID,
      lng = ~Longitude,
      lat = ~Latitude,
      radius = 2,
      group = "SiteGroup")
  return(mapA)
}

#------------------------
# Poly Map function
#------------------------
createPolyMapFunc <- function(inputData) {
  bbox <- st_bbox(inputData) %>% as.vector()
  mapA <- leaflet() %>%
    addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) %>%
    clearGroup(group=c("AreaGroup")) %>%
    addPolygons(
      data = inputData,
      group = "AreaGroup")
  return(mapA)
}



# Getting Long & Lat For Related Sites
####################################################################
# get RelatedPODSites DF
RelatedPODSites <- returnVal[['Organizations']][['Sites']][[1]][['RelatedPODSites']][[1]]


returnLongFunc <- function(dfx) {
  str1 <-  "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
  str2 <- dfx['SiteUUID']
  keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
  outString <- paste0(str1, str2, "&", keyStr)
  returnVal <- fromJSON(outString)[['Organizations']][['Sites']][[1]][['Longitude']]
  return(returnVal)
}

returnLatFunc <- function(dfx) {
  str1 <-  "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
  str2 <- dfx['SiteUUID']
  keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
  outString <- paste0(str1, str2, "&", keyStr)
  returnVal <- fromJSON(outString)[['Organizations']][['Sites']][[1]][['Latitude']]
  return(returnVal)
}

# get Longitude value, bind to DF
longVal <- apply(RelatedPODSites, 1, returnLongFunc)
RelatedPODSites <- cbind(RelatedPODSites, Longitude = longVal)

# get Latitude value, bind to DF
latVal <- apply(RelatedPODSites, 1, returnLatFunc)
RelatedPODSites <- cbind(RelatedPODSites, Latitude = latVal)

