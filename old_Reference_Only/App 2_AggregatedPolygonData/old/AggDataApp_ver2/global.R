# App: AggDataApp_ver2
# Sec 0. Code Notes and Purpose
# Date: 05/12/2020
# Topic: 1) Creating Aggreated Data Polygon Map App
#        2) Only using limited inputs at this time.


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
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

library(RColorBrewer)

# Input Data
P_CAAF <- import("data/P_CAAF.RData")
P_CABBUF <- import("data/P_CABBUF.RData")
P_H8AAF <- import("data/P_PH8AAF.RData")
P_H8ABBUF <- import("data/P_PH8ABBUF.RData")

#Shape Files
CountyAggSF <- readOGR(dsn = "data", layer = "CountyAggSF")
HUCAggSF <- readOGR(dsn = "data", layer = "HUCAggSF")

# Known issues of reading in shapefiles will only save 10 char string on attribute name.
# Need to rename shapefile input attributes within file to match input tables in order for filters to work properly.
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtUID"] <- "ReportingUnitID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RpUUUID"] <- "ReportingUnitUUID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprUNID"] <- "ReportingUnitNativeID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtnUN"] <- "ReportingUnitName"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprUTCV"] <- "ReportingUnitTypeCV"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtUUD"] <- "ReportingUnitUpdateDate"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtUPV"] <- "ReportingUnitProductVersion"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Shp_Lng"] <- "Shape_Length"

names(HUCAggSF@data)[names(HUCAggSF@data)=="ReportingU"] <- "ReportingUnitID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Shape_Leng"] <- "Shape_Length"

###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

ReportYearList = c("2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014")