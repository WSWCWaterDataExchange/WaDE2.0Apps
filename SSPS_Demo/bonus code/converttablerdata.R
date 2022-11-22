# App: SSPS Demo
library(rio)
library(readr)
library(readxl)
setwd("C:\\Users\\rjame\\Documents\\WSWC Documents\\WaDE Side Projects Local\\20221017 Rshiny SS Demo\\SSPS_Demo\\data")

#Sites_v2_sites
Sites_v2_sites <- read_excel("Sites_v2_sites.xlsx")
export(Sites_v2_sites, "Sites_v2_sites.RData")

# #Sites_v2_poly
# Sites_v2_poly <- read_excel("Sites_v2_poly.xlsx")
# export(Sites_v2_poly, "Sites_v2_poly.RData")





# App: SSPS Demo
# Date: 10/31/2022
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


# Input Data Files
sitesFile <- import("../data/Sites_v2_sites.RData")  # POD Site CSV Table
polyFile <- readOGR(dsn="data", layer="Sites_v2_poly", stringsAsFactors=FALSE)  # POU Polygon Shapefile
linkFile <- import("../data/start_end_Sites.RData")  # Create links between PODs and POUs


sitesFile$WaDENameWS <- as.list(strsplit(as.character(sitesFile$WaDENameWS), ", ")) # convert to correct list format

WaterSourceTypeList <- c("Surface Water")


xtest <- sitesFile[sapply(sitesFile$WaDENameWS, function(p) {any(p %in% WaterSourceTypeList)}), ]