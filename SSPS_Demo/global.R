# App: SSPS Demo
# Date: 02/13/2022
# Purpose: To view site specific public supply water use time series data.

################################################################################################
################################################################################################
# Sec 2: Libraries & Input Files

# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(shinyWidgets) # more options to work with shiny, like inputs
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
library(leaflegend) # custom legend functions for leaflet
library(leafem) #leaflet extension.
library(dplyr) # Used to filter data for plots.
library(DT) # Used to create more efficient data table output.
library(rio) # To import RData table from external source
library(rgdal)  # To work with shapefiles.
library(sp) # Uses SpatialPointsDataFrame function.
library(RColorBrewer) # adds more color schema options.
library(viridis) # adds more color schema options.
library(plotly) # To create plots within the output for the app.
library(jsonlite)
library(tidyverse)
library(sf)


# Input Data Files: csv
sitesFile <- import("data/Sites_v2_sites.RData")  # POD Site Table

# Input Data Files: shapefiles
polyFile <- sf::st_read("data/Sites_v2_poly.shp") # POU Polygon Shapefile
linkFile <- sf::st_read("data/Lines.shp")  # POU Polygon Shapefile
HUC12File <- sf::st_read("data/HUC12.shp")  # POU Polygon Shapefile

# Input Data: Images
LegendImage <- "www/customLegend.jpg"


################################################################################################
################################################################################################
# Sec 3: Custom Functions, Values and Lists

# # Fix Polygon Shapefile Input Issues
names(polyFile)[names(polyFile)=="SiteNative"] <- "SiteNativeID"  # fix 10 char string
names(polyFile)[names(polyFile)=="PODorPOUSi"] <- "PODorPOUSite"  # fix 10 char string
names(polyFile)[names(polyFile)=="minTimeFra"] <- "minTimeFrameStart"  # fix 10 char string
names(polyFile)[names(polyFile)=="maxTimeFra"] <- "maxTimeFrameEnd"  # fix 10 char string
names(polyFile)[names(polyFile)=="VariableSp"] <- "VariableSpecificCV"  # fix 10 char string
names(polyFile)[names(polyFile)=="minPopulat"] <- "minPopulationServed"  # fix 10 char string
names(polyFile)[names(polyFile)=="maxPopulat"] <- "maxPopulationServed"  # fix 10 char string
names(polyFile)[names(polyFile)=="HasLinksCo"] <- "HasLinksColor"  # fix 10 char string

polyFile$WaDENameS <- as.list(strsplit(as.character(polyFile$WaDENameS), ", ")) # convert to correct list format
polyFile$WaDENameWS <- as.list(strsplit(as.character(polyFile$WaDENameWS), ", ")) # convert to correct list format
polyFile$WaDENameBU <- as.list(strsplit(as.character(polyFile$WaDENameBU), ", ")) # convert to correct list format
polyFile$WaDENameV <- as.list(strsplit(as.character(polyFile$WaDENameV), ", ")) # convert to correct list format
polyFile$TimeStep <- as.list(strsplit(as.character(polyFile$TimeStep), ", ")) # convert to correct list format
polyFile$CountVar <- as.numeric(as.character(polyFile$CountVar))  # convert Factors to Integers
polyFile$minTimeFrameStart <- as.Date(polyFile$minTimeFrameStart) # convert to date
polyFile$maxTimeFrameEnd <- as.Date(polyFile$maxTimeFrameEnd) # convert to date


# Fix site File Inputs Issues
sitesFile$WaDENameS <- as.list(strsplit(as.character(sitesFile$WaDENameS), ", ")) # convert to list format
sitesFile$WaDENameWS <- as.list(strsplit(as.character(sitesFile$WaDENameWS), ", ")) # convert to list format
sitesFile$WaDENameBU <- as.list(strsplit(as.character(sitesFile$WaDENameBU), ", ")) # convert to list format
sitesFile$WaDENameV <- as.list(strsplit(as.character(sitesFile$WaDENameV), ", ")) # convert to list format
sitesFile$TimeStep <- as.list(strsplit(as.character(sitesFile$TimeStep), ", ")) # convert to list format
sitesFile$minTimeFrameStart <- as.Date(sitesFile$minTimeFrameStart) # convert to date
sitesFile$maxTimeFrameEnd <- as.Date(sitesFile$maxTimeFrameEnd) # convert to date


# Fix link File Inputs Issues
names(linkFile)[names(linkFile)=="startSiteU"] <- "SiteUUID"  # fix 10 char string
names(linkFile)[names(linkFile)=="minTimeFra"] <- "minTimeFrameStart"  # fix 10 char string
names(linkFile)[names(linkFile)=="maxTimeFra"] <- "maxTimeFrameEnd"  # fix 10 char string
names(linkFile)[names(linkFile)=="VariableSp"] <- "VariableSpecificCV"  # fix 10 char string
names(linkFile)[names(linkFile)=="minPopulat"] <- "minPopulationServed"  # fix 10 char string
names(linkFile)[names(linkFile)=="maxPopulat"] <- "maxPopulationServed"  # fix 10 char string

linkFile$WaDENameS <- as.list(strsplit(as.character(linkFile$WaDENameS), ", ")) # convert to correct list format
linkFile$WaDENameWS <- as.list(strsplit(as.character(linkFile$WaDENameWS), ", ")) # convert to correct list format
linkFile$WaDENameBU <- as.list(strsplit(as.character(linkFile$WaDENameBU), ", ")) # convert to correct list format
linkFile$WaDENameV <- as.list(strsplit(as.character(linkFile$WaDENameV), ", ")) # convert to correct list format
linkFile$TimeStep <- as.list(strsplit(as.character(linkFile$TimeStep), ", ")) # convert to correct list format
linkFile$CountVar <- as.numeric(as.character(linkFile$CountVar))  # convert Factors to Integers
linkFile$minTimeFrameStart <- as.Date(linkFile$minTimeFrameStart) # convert to date
linkFile$maxTimeFrameEnd <- as.Date(linkFile$maxTimeFrameEnd) # convert to date


# Input Site Name List
List1 <- as.list(unique(sitesFile$SiteName))
List2 <- as.list(unique(polyFile$SiteName))
SiteNameList <- c(List1, List2)
SiteNameList <- SiteNameList[order(names(setNames(SiteNameList, SiteNameList)))]

# Input State List
List1 <- as.list(unique(sitesFile$State))
List2 <- as.list(unique(polyFile$State))
StateList <- c(List1, List2)
StateList <- StateList[order(names(setNames(StateList, StateList)))]

# Input SiteTypeCV list
List1 <- as.list(unique(sitesFile$WaDENameS))
List2 <- as.list(unique(polyFile$WaDENameS))
SiteTypeList <- c(List1, List2)
SiteTypeList <- SiteTypeList[order(names(setNames(SiteTypeList, SiteTypeList)))]

# Input WaterSourceTypeCV List
List1 <- as.list(unique(sitesFile$WaDENameWS))
List2 <- as.list(unique(polyFile$WaDENameWS))
WaterSourceTypeList <- c(List1, List2)
WaterSourceTypeList <- unique(unlist(WaterSourceTypeList, recursive=F))
WaterSourceTypeList <- WaterSourceTypeList[order(names(setNames(WaterSourceTypeList, WaterSourceTypeList)))]

# Input BenUse List
List1 <- as.list(unique(sitesFile$WaDENameBU))
List2 <- as.list(unique(polyFile$WaDENameBU))
BenUseList <- c(List1, List2)
BenUseList <- unique(unlist(BenUseList, recursive=F))
BenUseList <- BenUseList[order(names(setNames(BenUseList, BenUseList)))]

# Input VariableCV List
List1 <- as.list(unique(sitesFile$WaDENameV))
List2 <- as.list(unique(polyFile$WaDENameV))
VariableCVList <- c(List1, List2)
VariableCVList <- unique(unlist(VariableCVList, recursive=F))
VariableCVList <- VariableCVList[order(names(setNames(VariableCVList, VariableCVList)))]

# Input TimeStepList
List1 <- as.list(unique(sitesFile$TimeStep))
List2 <- as.list(unique(polyFile$TimeStep))
TimeStepList <- c(List1, List2)
TimeStepList <- unique(unlist(TimeStepList, recursive=F))
TimeStepList <- TimeStepList[order(names(setNames(TimeStepList, TimeStepList)))]

# # Min Max TimeFrameValues
minSiteTime <- as.Date("1955-01-01")
maxSiteTime <- as.Date("2021-12-31")

# Input: Max & Min PopulationServed
minPopulationServed <- 0
maxPopulationServed <- 4061504

# Other Parameters
clickShape <- NULL


options(shiny.reactlog = TRUE)
