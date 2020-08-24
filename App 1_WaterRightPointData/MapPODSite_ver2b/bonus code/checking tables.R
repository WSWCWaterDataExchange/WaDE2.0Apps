# App: MapPODSite_CRBver2
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 1_WaterRightPointData\\MapPODSite_ver2b")
################################################################################################
################################################################################################
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

library(hash) #for creating dictionaries

################################################################################################
################################################################################################
# Sec 2. Input Files

# MapDeck() Style and Token Acesses.
access_token <- "pk.eyJ1IjoicmphbWVzd3N3YyIsImEiOiJjazllcndyb20wNDFpM2huYWRhdmpieW1vIn0.N9V48xEQF4EBsLgQ7j5SGA"
style_url <- "mapbox://styles/rjameswswc/ckb71bkpc4e2j1jnwo3zy5nrx"

# Input Data
P_AlloLFSite  <- import("data/P_AlloLFSite.RData") # Use this with filters to reduce amount of sites
P_SiteLFAllo  <- import("data/P_SiteLFAllo.RData") # All sites
P_SiteLFAllo_CRB  <- import("data/P_SiteLFAllo_CRB.RData") # CRB Only Sites
CRBasinSF <- sf::st_read("data/CRBasin.shp") # CRB Shapefile


################################################################################################
################################################################################################
# Sec 3. Custom Lists

BenUseList <- c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire", "Flood Control",
                "Industrial", "Livestock", "Mining", "Municipal", "Other", "Power",
                "Recharge", "Recreation", "Snow Making", "Storage", "Wildlife")

StateList <- c("CA", "CO", "ID", "ND", "NM",
               "OK", "OR", "TX", "UT", "WA")

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
# #### Generate row number or row index using seq.int() function
temp <- P_SiteLFAllo
temp$SID <- seq.int(nrow(temp))
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


#Create dict
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
                "Power",
                "Recharge",
                "Recreation",
                "Snow Making",
                "State Specific",
                "Storage",
                "Wildlife",
                "Unknown")

BenUseColourList = c("#006400FF",
                     "#9ACD32FF",
                     "#FFFF00FF",
                     "#0000FFFF",
                     "#32CD32FF",
                     "#FF4500FF",
                     "#9370DBFF",
                     "#00FFFFFF",
                     "#FF69B4FF",
                     "#800080FF",
                     "#00BFFFFF",
                     "#FFD700FF",
                     "#A52A2AFF",
                     "#4B0082FF",
                     "#FFA500FF",
                     "#D2691EFF",
                     "#FFC0CBFF",
                     "#F0FFF0FF",
                     "#808080FF",
                     "#F5DEB3FF",
                     "#FF0000FF",
                     "#D3D3D3FF")

#Create the dict
h <- hash()

# set values
h[["Agricultural"]] <-  "#006400FF"
h[["Aquaculture"]] <-  "#9ACD32FF"
h[["Commercial"]] <-  "#FFFF00FF"
h[["Domestic"]] <-  "#0000FFFF"
h[["Environmental"]] <-  "#32CD32FF"
h[["Fire"]] <-  "#FF4500FF"
h[["Fish"]] <-  "#9370DBFF"
h[["Flood Control"]] <-  "#00FFFFFF"
h[["Heating and Cooling"]] <-  "#FF69B4FF"
h[["Industrial"]] <-  "#800080FF"
h[["Instream Flow"]] <-  "#00BFFFFF"
h[["Livestock"]] <-  "#FFD700FF"
h[["Mining"]] <-  "#A52A2AFF"
h[["Municipal"]] <-  "#4B0082FF"
h[["Power"]] <-  "#FFA500FF"
h[["Recharge"]] <-  "#D2691EFF"
h[["Recreation"]] <-  "#FFC0CBFF"
h[["Snow Making"]] <-  "#F0FFF0FF"
h[["State Specific"]] <-  "#808080FF"
h[["Storage"]] <-  "#F5DEB3FF"
h[["Wildlife"]] <-  "#FF0000FF"
h[["Unknown"]] <-  "#D3D3D3FF"

#get keys
keys(h)

#get values
values(h)

##############################################

#Create the dict
b <- hash()

b[BenUseList] <- BenUseColourList

keys(b)

values(b)

returnthese <- c("Agricultural", "Commercial")
returnthese
b[returnthese]

values(b[returnthese], USE.NAMES=FALSE)

ylist <- values(b[returnthese], USE.NAMES=FALSE)
ylist
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
