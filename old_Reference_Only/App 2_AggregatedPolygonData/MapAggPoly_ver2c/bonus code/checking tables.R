setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 2_AggregatedPolygonData\\MapAggPoly_ver2c")
################################################################################################
################################################################################################
# App: MapAggPoly_ver2c
# Sec 0. Code Purpose and Version Notes 
# Date: 10/08/2020
# Purpose: To view annual aggregated water use data across polygon areas across the Western United Sites.
# Topic:
#   1) Creating Aggregated Data Polygon Map App
#   2) Uses Plotly (ggplotly) to create more user expereince plots.
#   3) New single use Agg table file and multiple into shp file inputs.


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
PAggTable <- import("data/Pagg.RData")  #aggreated amounts 

# Input Data: ShapeFiles
CountySF <- readOGR(dsn = "data", layer = "CountySF")
HUCSF <- readOGR(dsn = "data", layer = "HUC8SF")
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



###########################################################################################################################
###########################################################################################################################

clickVal <- 'AZag_RU1'
tempCustomSF <- CustomSF %>% subset(ReportingUnitUUID %in% clickVal)
tempPAggTable <- PAggTable %>% filter(ReportingUnitID %in% tempCustomSF$ReportingUnitID)
finalAFF_WS <- tempPAggTable %>% group_by(ReportYearCV, WaterSourceTypeCV) %>% summarise(SumAmouts = sum(Amount))


fig <- plot_ly(finalAFF_WS, labels = ~WaterSourceTypeCV, values = ~SumAmouts, type = 'pie')
fig <- fig %>% layout(title = 'Water Source Type',
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
fig