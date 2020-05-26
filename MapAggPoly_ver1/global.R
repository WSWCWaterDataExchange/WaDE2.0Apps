# App: MapAggPoly_ver1
# Sec 0. Code Notes and Purpose
# Date: 05/26/2020
# Topic: 1) Creating Aggreated Data Polygon Map App
#        2) Only using limited inputs at this time.
#        3) Uses Plotly


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

library(plotly)

# Input Data
AAF <- import("data/AAF.RData")
ABBUF <- import("data/ABBUF.RData")
V <- import("data/V.RData")
WS <- import("data/WS.RData")

#Shape Files
CountyAggSF <- readOGR(dsn = "data", layer = "CountyAgg")
HUCAggSF <- readOGR(dsn = "data", layer = "HUCAgg")
BasinAggSF <- readOGR(dsn = "data", layer = "BasinAgg")

#Temp ShapeFiles
WSWCCounty <- readOGR(dsn = "data", layer = "WSWCCounty")
MNCounty <- readOGR(dsn = "data", layer = "MNCounty")

# Known issues of reading in shapefiles will only save 10 char string on attribute name.
# Need to rename shapefile input attributes within file to match input tables in order for filters to work properly.
#County
names(CountyAggSF@data)[names(CountyAggSF@data)=="ReportingU"] <- "ReportingUnitID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_5"] <- "ReportingUnitUpdateDate"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Shp_Lng"] <- "Shape_Length"

#HUC8
names(HUCAggSF@data)[names(HUCAggSF@data)=="ReportingU"] <- "ReportingUnitID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"
names(HUCAggSF@data)[names(HUCAggSF@data)=="Shape_Leng"] <- "Shape_Length"

#Basin
names(BasinAggSF@data)[names(BasinAggSF@data)=="ReportingU"] <- "ReportingUnitUUID"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_1"] <- "ReportingUnitID"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_3"] <- "ReportingUnitNativeID"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_4"] <- "ReportingUnitName"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_5"] <- "ReportingUnitTypeCV"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_6"] <- "ReportingUnitUpdateDate"
names(BasinAggSF@data)[names(BasinAggSF@data)=="Reportin_7"] <- "ReportingUnitProductVersion"

###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

ReportYearList = c(1990, 1996, 
                   2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 
                   2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018)



#Custom Header
#The 'a' tag creates a link to a web page.
titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Western States Reporting Units"
)