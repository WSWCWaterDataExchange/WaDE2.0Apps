# App: SSPS Demo
library(rio)
library(readr)
library(readxl)
setwd("C:\\Users\\rjame\\Documents\\WSWC Documents\\WaDE Side Projects Local\\20221017 Rshiny SS Demo\\SSRGDemo\\data")

#Sites_v
Sites_v2 <- read_excel("Sites_v2.xlsx")
export(Sites_v2, "Sites_v2.RData")



# 
# Point_ID = c("A1", "B1", "C3")
# Latitude = c(38.05, 39.08, 40.05)
# Longitude = c(-107.00, -107.05, -108.00)
# PointUse = I(list("farm", c("farm", "house"), "house"))  # <- the column with the list entries
# Map_DF <- data.frame(Point_ID, Latitude, Longitude, PointUse)
# View(Map_DF$PointUse)
# 
# x <- "a,b,c"
# xlist <- as.list(strsplit(x, ",")[[1]])
# 
# 
# # Input Data: Shapefiles
# library(rgdal)  # To work with shapefiles.
# setwd("C:\\Users\\rjame\\Documents\\WSWC Documents\\WaDE Side Projects\\20220112 CA TX ss RShiny Demo\\CA_TX_ssDemo")
# SitesDataSF <- readOGR(dsn="data", layer="CA_TX_PWS", stringsAsFactors=FALSE) # Polygon Site info
# #SitesDataSF@data$WaDENameWS <- as.list(strsplit(SitesDataSF@data$WaDENameWS, "Surface")[[1]])  # convert Characters to List
# View(SitesDataSF@data$WaDENameWS)

