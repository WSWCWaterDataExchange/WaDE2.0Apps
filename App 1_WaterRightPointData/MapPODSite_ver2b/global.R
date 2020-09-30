# App: MapPODSite_ver2b
# Sec 0. Code Purpose and Version Notes 
# Date: 07/16/2020
# Purpose: To view POD Sites across the Western United Sites.
# Notes: 
#   1) Uses all and CRB Specific Sites
#   2) Using Mapdeck as drawing tool
#   3) three inputs: All site, CRB sites, allow info
#   4) New UI format
#   5) Included API return tables.


################################################################################################
################################################################################################
# Sec 1. Needed Libaries
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(shinyWidgets) # more options to work with shiny, like inputs
library(mapdeck) # the mapping software.  Uses special access token.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(jsonlite)
library(sf)
library(hash) #for creating dictionaries

################################################################################################
################################################################################################
# Sec 2. Input Files

# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"

# Input Data
P_AlloLFSite  <- import("data/P_AllowLJSite.RData") # Use this with filters to reduce amount of sites
P_SiteLFAllo  <- import("data/P_SiteLJAllow.RData") # All sites
P_SiteLFAllo_Basins  <- import("data/P_SiteLJAllow_Basin.RData") # River Basin Sites
BasinsSF <- sf::st_read("data/BasinsSF.shp") # Colorado River Basin Shapefile


################################################################################################
################################################################################################
# Sec 3. Custom Lists

LegendTypeList <- c(
  "Beneficial Use",
  "Site Type",
  "Water Source Type",
  "Owner"
)

BenUseList <- c(
  "Agricultural",
  "Aquaculture",
  "Commercial",
  "Domestic",
  "Environmental",
  "Fire",
  "Fish",
  "Flood Control",
  "Heating and Cooling",
  "Industrial",
  "Instream Flow",
  "Livestock",
  "Mining",
  "Municipal",
  "Other",
  "Power",
  "Recharge",
  "Recreation",
  "Snow Making",
  "Storage",
  "Unknown",
  "Wildlife")

#BenUse & Color Dict
BenUseColorDict <- hash() #creaqte blank dict
BenUseColorDict[["Agricultural"]] <- "#006400FF"
BenUseColorDict[["Aquaculture"]] <- "#9ACD32FF"
BenUseColorDict[["Commercial"]] <- "#FFFF00FF"
BenUseColorDict[["Domestic"]] <- "#0000FFFF"
BenUseColorDict[["Environmental"]] <- "#32CD32FF"
BenUseColorDict[["Fire"]] <- "#FF4500FF"
BenUseColorDict[["Fish"]] <- "#9370DBFF"
BenUseColorDict[["Flood Control"]] <- "#00FFFFFF"
BenUseColorDict[["Heating and Cooling"]] <- "#FF69B4FF"
BenUseColorDict[["Industrial"]] <- "#800080FF"
BenUseColorDict[["Instream Flow"]] <- "#00BFFFFF"
BenUseColorDict[["Livestock"]] <- "#FFD700FF"
BenUseColorDict[["Mining"]] <- "#A52A2AFF"
BenUseColorDict[["Municipal"]] <- "#4B0082FF"
BenUseColorDict[["Other"]] <- "#808080FF"
BenUseColorDict[["Power"]] <- "#FFA500FF"
BenUseColorDict[["Recharge"]] <- "#D2691EFF"
BenUseColorDict[["Recreation"]] <- "#FFC0CBFF"
BenUseColorDict[["Snow Making"]] <- "#F0FFF0FF"
BenUseColorDict[["Storage"]] <- "#F5DEB3FF"
BenUseColorDict[["Unknown"]] <- "#D3D3D3FF"
BenUseColorDict[["Wildlife"]] <- "#FF0000FF"

StateList <- c("CA", "CO", "ID", "ND", "NE", "NM", "NV",
               "OK", "OR", "TX", "UT", "WA")

RiverBasinList <- c("Colorado River Basin", "Rio Grande River Basin", "Columbia River Basin")

SiteTypeList <- c(
  "Abandoned",
  "Aquifer",
  "Canal / Ditch / Stream",
  "Discharge Point",
  "Diversion Point",
  "Drain",
  "Effluent",
  "Exchange Plan",
  "Gravity",
  "Groundwater",
  "Lake",
  "Mine",
  "Minimum Flow",
  "Monitoring Well",
  "Other",
  "Pipeline",
  "Point of Rediversion",
  "Point of Return",
  "Power Plant",
  "Pump",
  "Reach",
  "Recharge Area",
  "Reservoir",
  "Seep",
  "Spring",
  "Storage",
  "Sump",
  "Surface & Groundwater",
  "Surface Water",
  "Unknown",
  "Well",
  "winter runoff")

WaterSourceTypeList <- c(
  "Groundwater",
  "Other",
  "Reservoir / Storage",
  "Surface & Groundwater",
  "Surface Water",
  "Unknown")

AllocationOwnerList <- c(
  "Other",
  "United States of America",
  "US Army",
  "US Bureau of Land Management",
  "US Bureau Reclamation",
  "US Department of Energy",
  "US Forest Service")


#SiteType & Color Dict
SiteTypeColorDict <- hash() #creaqte blank dict
SiteTypeColorDict[["Abandoned"]] <- "#FFC0CBFF"
SiteTypeColorDict[["Aquifer"]] <- "#FF1493FF"
SiteTypeColorDict[["Canal / Ditch / Stream"]] <- "#191970FF"
SiteTypeColorDict[["Discharge Point"]] <- "#EE82EEFF"
SiteTypeColorDict[["Diversion Point"]] <- "#BA55D3FF"
SiteTypeColorDict[["Drain"]] <- "#8A2BE2FF"
SiteTypeColorDict[["Effluent"]] <- "#800080FF"
SiteTypeColorDict[["Exchange Plan"]] <- "#483D8BFF"
SiteTypeColorDict[["Gravity"]] <- "#4B0082FF"
SiteTypeColorDict[["Groundwater"]] <- "#FFA07AFF"
SiteTypeColorDict[["Lake"]] <- "#F08080FF"
SiteTypeColorDict[["Mine"]] <- "#FF0000FF"
SiteTypeColorDict[["Minimum Flow"]] <- "#FFA500FF"
SiteTypeColorDict[["Monitoring Well"]] <- "#FF6347FF"
SiteTypeColorDict[["Other"]] <- "#FFFF00FF"
SiteTypeColorDict[["Pipeline"]] <- "#FAFAD2FF"
SiteTypeColorDict[["Point of Rediversion"]] <- "#EEE8AAFF"
SiteTypeColorDict[["Point of Return"]] <- "#ADFF2FFF"
SiteTypeColorDict[["Power Plant"]] <- "#32CD32FF"
SiteTypeColorDict[["Pump"]] <- "#00FF7FFF"
SiteTypeColorDict[["Reach"]] <- "#228B22FF"
SiteTypeColorDict[["Recharge Area"]] <- "#9ACD32FF"
SiteTypeColorDict[["Reservoir"]] <- "#800000FF"
SiteTypeColorDict[["Seep"]] <- "#20B2AAFF"
SiteTypeColorDict[["Spring"]] <- "#00FFFFFF"
SiteTypeColorDict[["Storage"]] <- "#AFEEEEFF"
SiteTypeColorDict[["Sump"]] <- "#48D1CCFF"
SiteTypeColorDict[["Surface & Groundwater"]] <- "#808000FF"
SiteTypeColorDict[["Surface Water"]] <- "#4682B4FF"
SiteTypeColorDict[["Unknown"]] <- "#D3D3D3FF"
SiteTypeColorDict[["Well"]] <- "#6495EDFF"
SiteTypeColorDict[["winter runoff"]] <- "#1E90FFFF"

#WaterSourceType & Color Dict
WaterSourceColorDict <- hash() #creaqte blank dict
WaterSourceColorDict[["Groundwater"]] <- "#008000FF"
WaterSourceColorDict[["Other"]] <- "#FFA500FF"
WaterSourceColorDict[["Reservoir / Storage"]] <- "#FFFF00FF"
WaterSourceColorDict[["Surface & Groundwater"]] <- "#800080FF"
WaterSourceColorDict[["Surface Water"]] <- "#FF4500FF"
WaterSourceColorDict[["Unknown"]] <- "#0000FFFF"

#Owner & Color Dict
OwnerColorDict <- hash() #creaqte blank dict
OwnerColorDict[["Other"]] <- "#D3D3D3FF"
OwnerColorDict[["United States of America"]] <- "#0000FFFF"
OwnerColorDict[["US Army"]] <- "#FF4500FF"
OwnerColorDict[["US Bureau of Land Management"]] <- "#800080FF"
OwnerColorDict[["US Bureau Reclamation"]] <- "#FFFF00FF"
OwnerColorDict[["US Department of Energy"]] <- "#FFA500FF"
OwnerColorDict[["US Forest Service"]] <- "#006400FF"


#Owner Background Style
MapDeckStyleList <- c("dark", "light", "outdoors", "streets", "satellite", "satellite-streets")


emptytable <- data.frame(Date=as.Date(character()),
                         File=character(), 
                         User=character(), 
                         stringsAsFactors=FALSE)
