#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\AggregatedData\\AggDataApp\\data")

#PCountyAgg_AggregatedAmount_Fact Info
PCAAF <- read_csv("PCountyAgg_AggregatedAmount_Fact.csv")
export(PCAAF, "P_CAAF.RData")

#PCountyAgg_AggBridge_BeneficialUses_Facts Info
PCABBUF <- read_csv("PCountyAgg_AggBridge_BeneficialUses_Facts.csv")
export(PCABBUF, "P_CABBUF.RData")

#PHUC8_AggregatedAmount_Fact Info
PH8AAF <- read_csv("PHUC8_AggregatedAmount_Fact.csv")
export(PH8AAF, "P_PH8AAF.RData")

#PHUC8_AggBridge_BeneficialUses_Facts Info
PH8ABBUF <- read_csv("PHUC8_AggBridge_BeneficialUses_Facts.csv")
export(PH8ABBUF, "P_PH8ABBUF.RData")


#----------------------------
#Fixing Shapefile Attribute Names
library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
setwd("C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp/NotEssentialData")


##County
CountyAggSF <- readOGR(dsn = path.expand("CountyAgg.shp"), layer = "CountyAgg")
CountyAggSF

names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtngU"] <- "ReportingUnitID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RpUUUID"] <- "ReportingUnitUUID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprUNID"] <- "ReportingUnitNativeID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtnUN"] <- "ReportingUnitName"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprUTCV"] <- "ReportingUnitTypeCV"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtUUD"] <- "ReportingUnitUpdateDate"
names(CountyAggSF@data)[names(CountyAggSF@data)=="RprtUPV"] <- "ReportingUnitProductVersion"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Shp_Lng"] <- "Shape_Length"

CountyAggSF


writeOGR(CountyAggSF, 
         dsn = "../data", 
         layer = "CountyAggSF",
         driver = "ESRI Shapefile")

##HUC8
HUCAggSF <- readOGR(dsn = path.expand("HUCAgg.shp"), layer = "HUCAgg")
HUCAggSF

names(CountyAggSF@data)[names(CountyAggSF@data)=="ReportingU"] <- "ReportingUnitID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_1"] <- "ReportingUnitUUID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_2"] <- "ReportingUnitNativeID"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_3"] <- "ReportingUnitName"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_4"] <- "ReportingUnitTypeCV"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Reportin_6"] <- "ReportingUnitProductVersion"
names(CountyAggSF@data)[names(CountyAggSF@data)=="Shape_Leng"] <- "Shape_Length"

writeOGR(HUCAggSF, 
         dsn = "../data", 
         layer = "HUCAggSF",
         driver = "ESRI Shapefile" )


########### 
CountyAggSFixed <- readOGR(dsn = path.expand("../data/CountyAggSF.shp"), layer = "CountyAggSF")
