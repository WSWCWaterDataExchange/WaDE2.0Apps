# App: MapPODSite_ver2
# Sec 0. Code Notes and Purpose
# Date: 07/15/2020
# Topic: 1) Uses all and CRB Specific Sites
#        2) Using Mapdeck as drawing tool
#        3) three inputs: All site, CRB sites, allow info


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(mapdeck) # the mapping software.  Uses special access token.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(jsonlite)



# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/rjameswswc/ckb71bkpc4e2j1jnwo3zy5nrx"

# Input Data
P_SiteLFAllo  <- import("data/P_SiteLFAllo.RData")
P_AlloLFSite  <- import("data/P_AlloLFSite.RData")
P_SiteLFAllo_CRB  <- import("data/P_SiteLFAllo_CRB.RData")




library(sf)
CRBasinSF <- sf::st_read("data/CRBasin.shp")

###########################################################################################################################
###########################################################################################################################


###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

#######  Custom Lists ####### 
BenUseList <- c("Agricultural",
                "Commercial",
                "Domestic",
                "Environmental",
                "Fire",
                "Flood Control",
                "Industrial",
                "Livestock",
                "Mining",
                "Municipal",
                "Other",
                "Power",
                "Recharge",
                "Recreation",
                "Snow Making",
                "Storage",
                "Wildlife")

StateList <- c("CA",
               "CO",
               "ID",
               "ND",
               "NM",
               "OK",
               "OR",
               "TX",
               "UT",
               "WA")

#Custom Header
#The 'a' tag creates a link to a web page.
titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Western States Allocation Site Information"
                    
) #End Custom Header