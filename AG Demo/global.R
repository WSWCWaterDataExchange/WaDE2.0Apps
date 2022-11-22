# App: AG Demo
# Date: 10/26/2022
# Purpose: To view aggregated budget time series data.

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


# Input Data Files
ReportingUnitData <- sf::st_read("data/ReportingUnit_v2.shp")  # Polygon Shapefile

# Input Data: Images
LegendImage <- "www/customLegend.jpg"


################################################################################################
################################################################################################
# Sec 3: Custom Functions, Values and Lists

# Input State List
StateList <- c('AZ', 'CA', 'CO', 'NE', 'NM', 'NV', 'TX', 'US', 'UT', 'WY')

# Input WaterSourceTypeCV List
WaterSourceTypeList <- c("Surface Water", "Groundwater", "Surface and Groundwater", "Reuse", "Purchased", "Unspecified", "Other", "Effluent")

# Input ReportingUnitTypeCV List
ReportingUnitTypeList <- c("County", "HUC8", "Custom Basin", "Custom Basin 2", "Custom Basin 3")

# Other Parameters
clickShape <- NULL

# Fix Input Shapefile Issues
names(ReportingUnitData)[names(ReportingUnitData)=="ReportingU"] <- "ReportingUnitUUID"  # fix 10 char string
names(ReportingUnitData)[names(ReportingUnitData)=="Reportin_1"] <- "ReportingUnitName"  # fix 10 char string
names(ReportingUnitData)[names(ReportingUnitData)=="Reportin_2"] <- "ReportingUnitNativeID"  # fix 10 char string
names(ReportingUnitData)[names(ReportingUnitData)=="VariableSp"] <- "VariableSpecificCV"  # fix 10 char string
ReportingUnitData$CountVar <- as.numeric(as.character(ReportingUnitData$CountVar))  # convert Factors to Integers
ReportingUnitData$WaDENameWS <- as.list(strsplit(as.character(ReportingUnitData$WaDENameWS), ", ")) # convert to correct list format
