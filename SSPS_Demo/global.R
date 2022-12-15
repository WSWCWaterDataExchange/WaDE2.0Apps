# App: SSPS Demo
# Date: 12/05/2022
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
names(polyFile)[names(polyFile)=="Population"] <- "PopulationServed"  # fix 10 char string
polyFile$WaDENameS <- as.list(strsplit(as.character(polyFile$WaDENameS), ", ")) # convert to correct list format
polyFile$WaDENameWS <- as.list(strsplit(as.character(polyFile$WaDENameWS), ", ")) # convert to correct list format
polyFile$WaDENameBU <- as.list(strsplit(as.character(polyFile$WaDENameBU), ", ")) # convert to correct list format
polyFile$WaDENameV <- as.list(strsplit(as.character(polyFile$WaDENameV), ", ")) # convert to correct list format
polyFile$TimeStep <- as.list(strsplit(as.character(polyFile$TimeStep), ", ")) # convert to correct list format
polyFile$PopulationServed <- as.list(strsplit(as.character(polyFile$PopulationServed), ", ")) # convert to correct list format
polyFile$CountVar <- as.numeric(as.character(polyFile$CountVar))  # convert Factors to Integers
polyFile$minTimeFrameStart <- as.Date(polyFile$minTimeFrameStart) # convert to date
polyFile$maxTimeFrameEnd <- as.Date(polyFile$maxTimeFrameEnd) # convert to date


# Fix sitesFile File Inputs Issues
sitesFile$WaDENameS <- as.list(strsplit(as.character(sitesFile$WaDENameS), ", ")) # convert to list format
sitesFile$WaDENameWS <- as.list(strsplit(as.character(sitesFile$WaDENameWS), ", ")) # convert to list format
sitesFile$WaDENameBU <- as.list(strsplit(as.character(sitesFile$WaDENameBU), ", ")) # convert to list format
sitesFile$WaDENameV <- as.list(strsplit(as.character(sitesFile$WaDENameV), ", ")) # convert to list format
sitesFile$TimeStep <- as.list(strsplit(as.character(sitesFile$TimeStep), ", ")) # convert to list format
sitesFile$PopulationServed <- as.list(strsplit(as.character(sitesFile$PopulationServed), ", ")) # convert to list format
sitesFile$minTimeFrameStart <- as.Date(sitesFile$minTimeFrameStart) # convert to date
sitesFile$maxTimeFrameEnd <- as.Date(sitesFile$maxTimeFrameEnd) # convert to date


# Fix link File Inputs Issues
names(linkFile)[names(linkFile)=="startSiteU"] <- "SiteUUID"  # fix 10 char string


# issue of having to try and get the min and max from two different files. Temp fix to hardcode it for now.
# # Min Max TimeFrameValues
# minSiteTime <- min(sitesFile$minTimeFrameStart, na.rm = TRUE)
# maxSiteTime <- max(sitesFile$maxTimeFrameEnd, na.rm = TRUE)
minSiteTime <- as.Date("1955-01-01")
maxSiteTime <- as.Date("2021-12-31")

# Input State List
StateList <- c("CA", "NJ", "NM", "TX", "UT")

# Input SiteTypeCV list
SiteTypeList <- c("City / District",
                  "Lake",
                  "Reservoir",
                  "Stream Gage",
                  "Surface Water Point",
                  "Unspecified",
                  "Well / Pump / Spring / Groundwater Point")

# Input WaterSourceTypeCV List
WaterSourceTypeList <- c("Groundwater",
                         "Reuse",
                         "Surface Water",
                         "Surface and Groundwater",
                         "Unspecified")

# Input BenUse List
BenUseList <- c("Agriculture Irrigation",
                "Commercial/Industrial",
                "Domestic",
                "Hydroelectric",
                "Mining",
                "Municipal Irrigation",
                "Other",
                "Public Supply",
                "Thermoelectric Cooling",
                "Treated Wastewater/Reuse",
                "Unspecified")

# Input VariableCV List
VariableCVList <- c("Consumptive Use",
                    "Delivered",
                    "Produced",
                    "Return",
                    "Withdrawal")

# Input TimeStepList
TimeStepList <- c("Annual", "Monthly")


# issue of trying to get a min and max slider value to work from a list
# Input: Max & Min PopulationServed
# minPopulationServed <- 0
# maxPopulationServed <- 4061504

# Other Parameters
clickShape <- NULL
