# App: App 3_SiteSpecificAmounts_v1
# Sec 0. Code Purpose and Version Notes 
# Date: 09/01/2020
# Purpose: To view site specific water data across polygon areas across the Western United Sites.
# Topic:


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
# SiteTable <- import("data/P_Site.RData")  #Site info for map
SiteTable <- import("data/P_SiteLJSSA.RData")  #Site info for map 
SSATable <- import("data/P_SSALJSite.RData") #Site Specific Amount info for table
EmptyTable <- import("data/EmptyData.RData") #empty table

# Input Data: ShapeFi
WaterServiceAreasSF <- readOGR(dsn = "data", layer = "RetailCulinaryWaterServiceAreas")



###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

basemapProvdierList = c(providers$Esri.WorldStreetMap, providers$Esri.WorldTopoMap, providers$Esri.WorldImagery)