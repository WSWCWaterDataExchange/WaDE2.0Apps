# App: App 3_SiteSpecificAmounts_v3
# Sec 0. Code Purpose and Version Notes 
# Date: 11/03/2021
# Purpose: To view site specific water data and the ties between POD and POU sites.


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(shinyWidgets) # more options to work with shiny, like inputs
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
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
SiteData <- import("data/Sites.RData")  #Site info

# Input Data: ShapeFiles
LinksSF <- readOGR(dsn = "data", layer = "LinksSF") #Site info
SiteGroupSF <- readOGR(dsn = "data", layer = "Sites_Group") #Sites Group info

# Other Parameters
n = 2803 #number of links in POU_LinkData data.



###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

#Input State List
StateList <- c("UT")

#Input WaterSourceTypeCV List
WaterSourceTypeList <- list(unique(SiteData$WaterSourceTypeCV))
WaterSourceTypeList <- unlist(WaterSourceTypeList)

# Known issues of reading in shapefiles will only save 10 char string on attribute name.
# Need to rename shapefile input attributes within file to match input tables in order for filters to work properly.
names(SiteGroupSF@data)[names(SiteGroupSF@data)=="CommunityW"] <- "CommunityWaterSupplySystem"
names(LinksSF@data)[names(LinksSF@data)=="CommunityW"] <- "CommunityWaterSupplySystem"