# Libraries
library(DT) # Provides an R interface to the JavaScript library DataTables
library(xlsx) # The xlsx package gives programatic control of Excel files using R
library(jsonlite) # These functions are used to convert between JSON data and R objects.
library(curl)  # Drop-in replacement for base url that supports https, ftps, gzip, deflate, etc
library(rJava) # Low-level interface to Java VM very much like .C/.Call and friends. Allows creation of objects, calling methods and accessing fields.
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(plotly) # To create plots within the output for the app.
library(sf)

setwd(".//bonus code")
print(getwd())

# The API string
str1 <- "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
str2 <- "UTssps_S2680" # change here
keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
outString <- paste0(str1,str2,"&",keyStr)
print(outString)

# get API data
returnVal <- fromJSON(outString)


# 2nd API query to populate RelatedPODSites with Site info. Use for loop
####################################################################
# RelatedPODSites <- unique(returnVal[['Organizations']][['Sites']][[1]][['RelatedPODSites']][[1]][1])
# RelatedPODSitesList <- as.list(RelatedPODSites$SiteUUID) 
# 
# SiteReturn <- data.frame()
# for (p in RelatedPODSitesList) {
#   str2 <- p[1]
#   print(length((str2)))
#   print(str2)
#   outString <- paste0(str1,str2,"&",keyStr)
#   print(outString)
#   returnVal <- fromJSON(outString)[['Organizations']][['Sites']][[1]]
#   SiteReturn <- rbind(SiteReturn, returnVal)
# }

RelatedPOUSites <- unique(returnVal[['Organizations']][['Sites']][[1]][['RelatedPOUSites']][[1]][1])
RelatedPOUSitesList <- as.list(RelatedPOUSites$SiteUUID)

SiteReturn <- data.frame()
for (p in RelatedPOUSitesList) {
  str2 <- p[1]
  print(length((str2)))
  print(str2)
  outString <- paste0(str1,str2,"&",keyStr)
  print(outString)
  returnVal <- fromJSON(outString)[['Organizations']][['Sites']][[1]]
  SiteReturn <- rbind(SiteReturn, returnVal)
}



# # Map out site or polygon
# ####################################################################
# 
# # Site Data
# Site <- returnVal[['Organizations']][['Sites']][[1]]
# 
# if(is.na(Site$SiteGeometry) == FALSE) {
#   print("Yes Geometry")
#   inputData <- sf::st_as_sf(Site, wkt = "SiteGeometry")
#   createPolyMapFunc(inputData)
# } else {
#   createSiteMapFunc(Site)
# }
# 
# #------------------------
# # Site Map function
# #------------------------
# createSiteMapFunc <- function(inputData) {
#   mapA <- leaflet() %>%
#     addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
#     setView(
#       lng = inputData$Longitude,
#       lat = inputData$Latitude,
#       zoom = 10) %>%
#     clearGroup(group=c("SiteGroup")) %>%
#     addCircleMarkers(
#       data = inputData,
#       layerId = ~SiteUUID,
#       lng = ~Longitude,
#       lat = ~Latitude,
#       radius = 2,
#       group = "SiteGroup")
#   return(mapA)
# }
# 
# #------------------------
# # Poly Map function
# #------------------------
# createPolyMapFunc <- function(inputData) {
#   bbox <- st_bbox(inputData) %>% as.vector()
#   mapA <- leaflet() %>%
#     addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
#     fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) %>%
#     clearGroup(group=c("AreaGroup")) %>%
#     addPolygons(
#       data = inputData,
#       group = "AreaGroup")
#   return(mapA)
# }