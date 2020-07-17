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

################################################################################################
################################################################################################
# Sec 2. Input Files

# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/rjameswswc/ckb71bkpc4e2j1jnwo3zy5nrx"

# Input Data
P_AlloLFSite  <- import("data/P_AlloLFSite.RData") # Use this with filters to reduce amount of sites
P_SiteLFAllo  <- import("data/P_SiteLFAllo.RData") # All sites
P_SiteLFAllo_Basins  <- import("data/P_SiteLFAllo_Basin.RData") # River Basin Sites
BasinsSF <- sf::st_read("data/BasinsSF.shp") # Colorado River Basin Shapefile


################################################################################################
################################################################################################
# Sec 3. Custom Lists

BenUseList <- c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire", "Flood Control",
                "Industrial", "Livestock", "Mining", "Municipal", "Other", "Power",
                "Recharge", "Recreation", "Snow Making", "Storage", "Wildlife")

StateList <- c("CA", "CO", "ID", "ND", "NM",
               "OK", "OR", "TX", "UT", "WA")

RiverBasinList <- c("Colorado River Basin", "Rio Grande River Basin", "Columbia River Basin")
