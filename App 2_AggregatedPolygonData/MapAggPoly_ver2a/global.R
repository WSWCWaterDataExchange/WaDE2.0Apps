# App: MapAggPoly_ver2a
# Sec 0. Code Notes and Purpose
# Date: 07/09/2020
# Topic: 1) Creating Aggregated Data Polygon Map App
#        2) Only using limited inputs at this time.
#        3) Uses Plotly (ggplotly) to create more user expereince plots.
#        4) Used reactive funciton to force 1-to-1 relationship between tables for heatmapping.


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
library(rgdal)  #to work with shapefiles.
library(tidyverse)
library(RColorBrewer) # adds more color schemas

library(plotly)


# Input Data: Tables
AggAmountTable <- import("data/AggAmountTable.RData")  #aggreated amounts 
# BenUseTable <- import("data/BenUseTable.RData") #aggreated beneficial use
VarTable <- import("data/VarTable.RData") # variables
PWaSoTable <- import("data/PWaSoTable.RData") #Water Sources
PMetTable <- import("data/PMetTable.RData") #Methods

# Input Data: ShapeFiles
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


# # Input Data: ShapeFiles Duplicate dataframes to work with data
# CountySF <- as(CountySF, "data.frame")
# CountySF <- spTransform(CountySF, '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')


###########################################################################################################################
###########################################################################################################################
# Sec 1b. Custom Functions, Values and Lists

#Custom UI Header Function. The 'a' tag creates a link to a web page.
titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Western States Reporting Areas")

#Normalizing data function for Polygon HeatMap color.
nrmFunc <- function(x){(x-min(x))/(max(x)-min(x))} 

#Input Year List
AllReportYearList = c(1971,	1972,	1973,	1974,	1975,	1976,	1977,
                      1978,	1979,	1980,	1981,	1982,	1983,	1984,
                      1985,	1986,	1987,	1988,	1989,	1990,	1991,
                      1992,	1993,	1994,	1995,	1996,	1997,	1998,
                      1999,	2000,	2001,	2002,	2003,	2004,	2005,
                      2006,	2007,	2008,	2009,	2010,	2011,	2012,
                      2013,	2014,	2015,	2016,	2017,	2018)


#State Color Palette for Maps
StateCVPalette <- colorFactor(palette = c("#FFFF00", "#006400", "#0000FF", "#DC143C", 
                                          "#8A2BE2", "#B8860B", "#000000"),
                              levels = c("AZ", "CA", "NM", "TX", "US", "UT", "WY"),
                              na.color = "#808080")

# #USBR Tributary Color Palette for Maps
# USBRTriPalette <- colorFactor(palette = c("#4169E1", 
#                                           "#8A2BE2", 
#                                           "#00FF7F", "#3CB371", "#2E8B57", 
#                                           "#FF8C00", "#FF7F50", "#FF6347", 
#                                           "#FF00FF"),
#                                 levels = c("AZ_colorado river", 
#                                            "NM_colorado river", 
#                                            "CO_colorado river", "CO_green river", "CO_upper main stem", 
#                                            "UT_colorado river", "UT_green river", "UT_upper main stem", 
#                                            "WY_green river"),
#                                 na.color = "#808080")
