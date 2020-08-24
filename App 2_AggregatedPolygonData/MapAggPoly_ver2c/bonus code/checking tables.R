setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 2_AggregatedPolygonData\\MapAggPoly_ver2c")
################################################################################################
################################################################################################

# App: MapAggPoly_ver2
# Sec 0. Code Notes and Purpose
# Date: 07/02/2020
# Topic: 1) Creating Aggregated Data Polygon Map App
#        2) Only using limited inputs at this time.
#        3) Uses Plotly (ggplotly) to create more user expereince plots.
#        4) Used reactive funciton to force 1-to-1 relationship between tables for heatmapping.

################################################################################################
################################################################################################
# Sec 1a. Needed Li/baries & Input Files
# Libraries
library(shiny) # How we create the app.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(shinydashboard) # The layout used for the ui page.
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
library(leafem) #leaflet extention.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(tidyverse)
library(RColorBrewer) # adds more color schemas

library(plotly)


# Input Data: Tables
AggAmountTable <- import("data/AggAmountTable.RData")  #aggreated amounts 
# BenUseTable <- import("data/BenUseTable.RData") #aggreated beneficial use
VarTable <- import("data/VarTable.RData") # variables
PWaSoTable <- import("data/PWaSoTable.RData") #Water Sources
PMetTable <- import("data/PMetTable.RData") #Methods

# Input Data: Shape Files
CountySF <- readOGR(dsn = "data", layer = "CountySF")
HUCSF <- readOGR(dsn = "data", layer = "HUCSF")
CustomSF <- readOGR(dsn = "data", layer = "CustomSF")
USBR_UCRB_TributarySF <- readOGR(dsn = "data", layer = "USBR_UCRB_TributarySF")


# Known issues of reading in shapefiles will only save 10 char string on attribute name.
# Need to rename shapefile input attributes within file to match input tables in order for filters to work properly.
#County
names(CountySF@data)[names(CountySF@data)=="TypeNameNu"] <- "TypeNameNum"
names(CountySF@data)[names(CountySF@data)=="ReportingU"] <- "ReportingUnitID"
names(CountySF@data)[names(CountySF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(CountySF@data)[names(CountySF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(CountySF@data)[names(CountySF@data)=="Reportin_3"] <- "ReportingUnitName"
names(CountySF@data)[names(CountySF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(CountySF@data)[names(CountySF@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(CountySF@data)[names(CountySF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"

#HUC8
names(HUCSF@data)[names(HUCSF@data)=="TypeNameNu"] <- "TypeNameNum"
names(HUCSF@data)[names(HUCSF@data)=="ReportingU"] <- "ReportingUnitID"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(HUCSF@data)[names(HUCSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"

#CustomSF
names(CustomSF@data)[names(CustomSF@data)=="TypeNameNu"] <- "TypeNameNum"
names(CustomSF@data)[names(CustomSF@data)=="ReportingU"] <- "ReportingUnitID"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(CustomSF@data)[names(CustomSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"

#USBR UCRB Tributary
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="TypeNameNu"] <- "TypeNameNum"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="ReportingU"] <- "ReportingUnitID"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_3"] <- "ReportingUnitName"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(USBR_UCRB_TributarySF@data)[names(USBR_UCRB_TributarySF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"



################################################################################################
################################################################################################
#Tables Combine the the data

idvalue = "TX_48401"
ruyear = 2008
tempCountySF <- CountySF %>% subset(ReportingUnitUUID %in% idvalue)
tempAggAmountTable <- AggAmountTable %>% filter(
  ReportingUnitID %in% tempCountySF$ReportingUnitID,
  ReportYearCV %in% ruyear)
tempAggAmountTable_2 <- left_join(x = tempAggAmountTable, y = PWaSoTable, by = "WaterSourceID")
finalAFF <- tempAggAmountTable_2 %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))



CustomSF.df <- as(CustomSF, "data.frame")
# write.csv(CustomSF.df,"CustomSFdf.csv", row.names = FALSE)

# DAUCO.df <- as(DAUCO, "data.frame")
# write.csv(DAUCO.df,"DAUCO.df.csv", row.names = FALSE)


HUC8.df <- as(HUCSF, "data.frame")
write.csv(HUC8.df,"HUC8.df.csv", row.names = FALSE)


################################################################################################
################################################################################################
#Plotting

DAUCO <- readOGR(dsn = "data", layer = "DAUCO")

#DAUCO
names(DAUCO@data)[names(DAUCO@data)=="TypeNameNu"] <- "TypeNameNum"
names(DAUCO@data)[names(DAUCO@data)=="ReportingU"] <- "ReportingUnitID"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_3"] <- "ReportingUnitName"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(DAUCO@data)[names(DAUCO@data)=="Reportin_6"] <- "ReportingUnitProductVersion"

leaflet(
  options = leafletOptions(
    preferCanvas = TRUE)
) %>%
  addProviderTiles(
    providers$Esri.DeLorme,
    options = providerTileOptions(
      updateWhenZooming = FALSE,
      updateWhenIdle = TRUE)
  ) %>%
  addPolygons(
    data = DAUCO,
    layerId = ~ReportingUnitUUID,
    fillColor = "blue",
  ) %>%
  setView(lng = -103.8080, lat = 36.6050, zoom = 4)
