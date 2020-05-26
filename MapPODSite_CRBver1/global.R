# App: MapPODSite_CRBver1
# Sec 0. Code Notes and Purpose
# Date: 05/26/2020
# Topic: 1) Uses only Colorado River Basin Site Info
#        2) Inputs seperated into there tables: Sites, Allocations, Benefical Uses 


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
library(leafem) #leaflet extention.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source

library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.

# Libraries I'm not sure if we need anymore...
library(magrittr) #for heat maps?

# Input Data
# P_dfSite <- import("data/P_dfSite.RData")
P_dfSite <- import("data/P_dfSiteWithAll_CRB.RData")
P_dfAllo <- import("data/P_dfAllo.RData")
P_dfBen <- import("data/P_dfBen.RData")

CRBasin <- readOGR(dsn = "data", layer = "CRBasin")

###########################################################################################################################
###########################################################################################################################
# Sec 1c.  MapDeck()

library(mapdeck)
library(leaflet.mapboxgl)


access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/rjameswswc/ck9lsb9k503nq1ipkuyyi4wlq"


###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists


#######  Custom Lists ####### 
BenUseList <- c("Agricultural", "Commercial", "Domestic", "Fire", "Industrial", "Mining", "Municipal", 
                "Power", "Recreation", "Snow Making", "StockWatering", "Wildlife", "Other")

BenUseColorsList <- c(
  "Agricultural" = "#FFFF00",
  "Commercial" = "#006400",
  "Domestic" = "#0000FF",
  "Fire" = "#DC143C",
  "Industrial" = "#8A2BE2",
  "Mining" = "#B8860B",
  "Municipal" = "#000000",
  "Power" = "#FF8C00",
  "Recreation" = "#FF00FF",
  "Snow Making" = "#F5FFFA",
  "StockWatering" = "#00CED1",
  "Wildlife" = "#98FB98",
  "Other" = "#708090")

BenUseMapPalette <- colorFactor(palette = c("#FFFF00", "#006400", "#0000FF", "#DC143C", "#8A2BE2", "#B8860B", "#000000",
                                            "#FF8C00", "#FF00FF", "#F5FFFA", "#00CED1", "#98FB98", "#708090"),
                                levels = c("Agricultural", "Commercial", "Domestic", "Fire", "Industrial", "Mining", "Municipal", 
                                           "Power", "Recreation", "Snow Making", "StockWatering", "Wildlife", "Other"),
                                na.color = "#808080")

StateList <- c("AZ", "CA", "CO", "NM", "UT")


####### Map Interface Tools Function #######
# source: https://opendata.socrata.com/dataset/Airport-Codes-mapped-to-Latitude-Longitude-in-the-/rxrh-4cxm

# generate second set of unique location IDs for second layer of selected locations
P_dfSite$secondLocationID <- paste(as.character(P_dfSite$SiteUUID), "_selectedLayer", sep="")
coordinates <- SpatialPointsDataFrame(P_dfSite[,c('Long', 'Lat')] , P_dfSite)

# function for finding the locations inside the shapes we draw
findLocations <- function(shape, location_coordinates, location_id_colname){
  
  # derive polygon coordinates and feature_type from shape input
  polygon_coordinates <- shape$geometry$coordinates
  feature_type <- shape$properties$feature_type
  
  if(feature_type %in% c("rectangle","polygon")) {
    
    # transform into a spatial polygon
    drawn_polygon <- Polygon(do.call(rbind,lapply(polygon_coordinates[[1]],function(x){c(x[[1]][1],x[[2]][1])})))
    
    # use 'over' from the sp package to identify selected locations
    selected_locs <- sp::over(location_coordinates
                              , sp::SpatialPolygons(list(sp::Polygons(list(drawn_polygon),"drawn_polygon"))))
    
    # get location ids
    x = (location_coordinates[which(!is.na(selected_locs)), location_id_colname])
    
    selected_loc_id = as.character(x[[location_id_colname]])
    
    return(selected_loc_id)
    
  } else if (feature_type == "circle") {
    
    center_coords <- matrix(c(polygon_coordinates[[1]], polygon_coordinates[[2]])
                            , ncol = 2)
    
    # get distances to center of drawn circle for all locations in location_coordinates
    # distance is in kilometers
    dist_to_center <- spDistsN1(location_coordinates, center_coords, longlat=TRUE)
    
    # get location ids
    # radius is in meters
    x <- location_coordinates[dist_to_center < shape$properties$radius/1000, location_id_colname]
    
    selected_loc_id = as.character(x[[location_id_colname]])
    
    return(selected_loc_id)
  }
}



#Custom Header
#The 'a' tag creates a link to a web page.
titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Western States Allocation Site Information"
)