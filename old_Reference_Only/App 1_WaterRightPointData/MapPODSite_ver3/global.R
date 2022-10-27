# App: MapPODSite_ver3
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
library(mapdeck) # the mapping software.  Uses special access token.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(jsonlite)
library(sf)
library(shinyWidgets)
library(hash) #for creating dictionaries

################################################################################################
################################################################################################
# Sec 2. Input Files

# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/mapbox/dark-v9"

# Input Data
P_AlloLFSite  <- import("data/P_AlloLFSite.RData") # Use this with filters to reduce amount of sites
P_SiteLFAllo  <- import("data/P_SiteLFAllo.RData") # All sites
P_SiteLFAllo_Basins  <- import("data/P_SiteLFAllo_Basin.RData") # River Basin Sites
BasinsSF <- sf::st_read("data/BasinsSF.shp") # Colorado River Basin Shapefile


################################################################################################
################################################################################################
# Sec 3. Custom Lists

BenUseList <- c("Agricultural",
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

StateList <- c("CA", "CO", "ID", "ND", "NM",
               "OK", "OR", "TX", "UT", "WA")

RiverBasinList <- c("Colorado River Basin", "Rio Grande River Basin", "Columbia River Basin")

emptytable <- data.frame(Date=as.Date(character()),
                         File=character(), 
                         User=character(), 
                         stringsAsFactors=FALSE)
