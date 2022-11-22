# App: SSRG Demo
# Date: 10/21/2022
# Purpose: To view site specific reservoir and gage time series data.

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


# Input Data Files
sites <- import("data/Sites_v2.RData")  # POD Site CSV Table

# Input Data: Images
LegendImage <- "www/customLegend.jpg"


################################################################################################
################################################################################################
# Sec 3: Custom Functions, Values and Lists

# Fix Sites File Inputs Issues
sites$WaDENameWS <- as.list(strsplit(as.character(sites$WaDENameWS), ", ")) # convert to correct list format
sites$minTimeFrameStart <- as.Date(sites$minTimeFrameStart)
sites$maxTimeFrameEnd <- as.Date(sites$maxTimeFrameEnd)

# Min Max TimeFrameValues
minSiteTime <- min(sites$minTimeFrameStart, na.rm = TRUE)
maxSiteTime <- max(sites$maxTimeFrameEnd, na.rm = TRUE)

# Input State List
StateList <- c("CA", "CO", "ID", "MT", "NE", "NV", "OR")

# Input WaterSourceTypeCV List
WaterSourceTypeList <- c("Surface Water", "Groundwater", "Unspecified")

