# App: MapPODSite_CRBver2
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 1_WaterRightPointData\\MapPODSite_ver2")
################################################################################################
################################################################################################
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(jsonlite)
library(mapdeck)
library(data.table)

# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/rjameswswc/ckb71bkpc4e2j1jnwo3zy5nrx"


# Input Data
P_SiteLFAllo  <- import("data/P_SiteLFAllo.RData")
P_AlloLFSite  <- import("data/P_AlloLFSite.RData")
CRBasin <- readOGR(dsn = "data", layer = "CRBasin")  #mapdeck doesn't like this datafile type

################################################################################################
################################################################################################
#Tables Combine the the data


# CustomSF.df <- as(CustomSF, "data.frame")
# # write.csv(CustomSF.df,"CustomSFdf.csv", row.names = FALSE)
# 
# # DAUCO.df <- as(DAUCO, "data.frame")
# # write.csv(DAUCO.df,"DAUCO.df.csv", row.names = FALSE)
# 
# 
# HUC8.df <- as(HUCSF, "data.frame")
# write.csv(HUC8.df,"HUC8.df.csv", row.names = FALSE)

# 
# row1 <- P_SiteLFAllo[61135,]
# tempAggAmountTable_3 <- merge(x = P_AlloLFSite, y = row1, by = "SiteUUID")
# 
# # #### Generate row number or row index using seq.int() function
# temp <- P_SiteLFAllo
# temp$SID <- seq.int(nrow(temp)) 
# 
# 
# #Popup has to be created before hand if it is to hold multipe info.
# dt <- setDT( temp )[, .(info = paste(SiteUUID, Lat, Long, WBenUse, collapse = ", ")), by = SiteUUID]
# 
# temp <- merge(
#   x = temp
#   , y = dt
#   , by = "SiteUUID"
#   , all.x = T
# )


# #assign color within app
# tempsite <- P_SiteLFAllo
# tempsite$SID <- seq.int(nrow(tempsite))
# tempsite$my_colour <- ifelse(tempsite$WBenUse == "Agricultural", "#FFFF00", "#708090")

#Returning SiteUUID value only
tablereturn <- 1
selectedLocations <- P_SiteLFAllo[tablereturn,]
SQLInput <- selectedLocations$SiteUUID

################################################################################################
################################################################################################
#Plotting

# DAUCO <- readOGR(dsn = "data", layer = "DAUCO")
# 
# #DAUCO
# names(DAUCO@data)[names(DAUCO@data)=="TypeNameNu"] <- "TypeNameNum"
# names(DAUCO@data)[names(DAUCO@data)=="ReportingU"] <- "ReportingUnitID"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_1"] <- "ReportingUnitUUID"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_2"] <- "ReportingUnitNativeID"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_3"] <- "ReportingUnitName"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
# names(DAUCO@data)[names(DAUCO@data)=="Reportin_6"] <- "ReportingUnitProductVersion"
# 
# leaflet(
#   options = leafletOptions(
#     preferCanvas = TRUE)
# ) %>%
#   addProviderTiles(
#     providers$Esri.DeLorme,
#     options = providerTileOptions(
#       updateWhenZooming = FALSE,
#       updateWhenIdle = TRUE)
#   ) %>%
#   addPolygons(
#     data = DAUCO,
#     layerId = ~ReportingUnitUUID,
#     fillColor = "blue",
#   ) %>%
#   setView(lng = -103.8080, lat = 36.6050, zoom = 4)
