# App: SSPS Demo
# Date: 10/13/2022
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
amountData <- import("data/SiteVariableAmounts.RData")  # SiteVariableAmounts CSV Table
sitesPOD <- import("data/Sites_v2_POD.RData")  # POD Site CSV Table
polyPOU <- readOGR(dsn="data", layer="SSPS_Merge_withAtr", stringsAsFactors=FALSE)  # POU Polygon Shapefile

# Input Data: Images
LegendImage <- "www/customLegend.jpg"


################################################################################################
################################################################################################
# Sec 3: Custom Functions, Values and Lists

# Input: Color List
binList <- c(0,1,2,3,4,5,6,7,8,9,10,11,12)
colorList <- c("#BFBFBF", "#E9BEB8", "#E3AEA7", "#DD9E96", "#D78E84", "#D17F73", 
             "#CA6F62", "#C45F52", "#BD5041", "#AC493C", "#9A4236", "#883B31", 
             "#6C3028")

# Input State List
StateList <- c("CA", "NJ", "NM", "TX", "UT")

# Input WaterSourceTypeCV List
WaterSourceTypeList <- c("Surface Water", "Groundwater", "Surface and Groundwater", "Reuse", "Purchased", "Unspecified")

# Other Parameters
clickShape <- NULL

# Fix Input Shapefile Issues
names(polyPOU@data)[names(polyPOU@data)=="SiteNative"] <- "SiteNativeID"  # fix 10 char string
names(polyPOU@data)[names(polyPOU@data)=="PODorPOUSi"] <- "PODorPOUSite"  # fix 10 char string
names(polyPOU@data)[names(polyPOU@data)=="CommunityW"] <- "CommunityWaterSupplySystem"  # fix 10 char string
names(polyPOU@data)[names(polyPOU@data)=="VariableSp"] <- "VariableSpecificCV"  # fix 10 char string
polyPOU$CountVar <- as.numeric(as.character(polyPOU$CountVar))  # convert Factors to Integers
polyPOU$WaDENameWS <- as.list(strsplit(as.character(polyPOU$WaDENameWS), ", ")) # convert to correct list format
