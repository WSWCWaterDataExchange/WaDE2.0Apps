#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\AllData\\AllAlloShinyAppver1\\data")

Allx <- read_csv("AllInput_verA.csv")
export(Allx, "AllInput_verA.RData")
FileIn <- import("AllInput_verA.RData") # tocheck data table

# #-----------------------------------------
# #AllData.Rds Sample
# library(rio)
# library(readr)
# setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\AllData\\AllAlloShinyAppver1\\data")
# Allx <- read_csv("AllInput_verA.csv")
# saveRDS(Allx, "AllInput_verA.Rds")

# #-----------------------------------------
# #Creating Alldata.shapefile
# library(raster)
# library(rgdal)
# library(sf)
# setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\AllData\\AllAlloShinyAppver1\\data")
# MyData <- read_csv("AllInput_verA.csv")
# 
# WGScoor <- MyData
# coordinates(WGScoor) = ~PODLongitude + PODLatitude
# proj4string(WGScoor)<- CRS("+proj=longlat +datum=WGS84")
# LLcoor <- spTransform(WGScoor,CRS("+proj=longlat"))
# raster::shapefile(LLcoor, "AllInput_verA.shp")
# FileIn <- st_read("AllocationPointMap.shp")
