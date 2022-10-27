# App: App 3_SiteSpecificAmounts_v3
# Sec 0. Code Purpose and Version Notes 
# Date: 11/03/2021
# Purpose: To view site specific water data and the ties between POD and POU sites.


################################################################################################
################################################################################################
# Sec 1a. Needed Libraries & Input Files
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(shinyWidgets) # more options to work with shiny, like inputs
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
library(leaflegend) # custom legend functions for leaflet
library(leafem) #leaflet extention.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  #to work with shapefiles.
library(RColorBrewer) # adds more color schemas
library(plotly)
library(jsonlite)

library(tidyverse)

# Input Data: Tables
AmountsData <- import("data/SiteVariableAmounts.RData")  #SiteVariableAmounts info for map
SitesPODData <- import("data/SitesPOD.RData")  #Site POD info
wr_SiteData <- import("data/wr_sites.RData")  #Water Right Site info

# Input Data: Shapefiles
LinksSF <- readOGR(dsn = "data", layer = "LinksSF") #Links between POUs and PODs info
PolyPOUSF <- readOGR(dsn = "data", layer = "PolyPOUSF") #Poly POU info

# Input Data: Images
LegendImage <- "www/sitetypelegend.jpg"

# Other Parameters
n <- 2803 #number of links in POU_LinkData data.
clickShape <- NULL
clickMarker <- NULL
clickVal <- NULL


###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

# Input State List
StateList <- c("UT")

# Input WaterSourceTypeCV List
WaterSourceTypeList <- c("Groundwater", "Surface Water", "Unspecified")

# Known issue of exported shapefile will only save the first 10 char string of a attribute name.
# Need to rename shapefile input attributes within file to match input tables in order for filters to work properly.
names(LinksSF@data)[names(LinksSF@data)=="CommunityW"] <- "CommunityWaterSupplySystem"

names(PolyPOUSF@data)[names(PolyPOUSF@data)=="Longitude_"] <- "Longitude"
names(PolyPOUSF@data)[names(PolyPOUSF@data)=="Latitude_1"] <- "Latitude"
names(PolyPOUSF@data)[names(PolyPOUSF@data)=="PODorPOUSi"] <- "PODorPOUSite"
names(PolyPOUSF@data)[names(PolyPOUSF@data)=="WaterSourc"] <- "WaterSourceTypeCV"
names(PolyPOUSF@data)[names(PolyPOUSF@data)=="CommunityW"] <- "CommunityWaterSupplySystem"
names(PolyPOUSF@data)[names(PolyPOUSF@data)=="RecordChec"] <- "RecordCheck"