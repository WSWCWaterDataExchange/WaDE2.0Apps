#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 2_AggregatedPolygonData\\MapAggPoly_ver2c\\data")

#AggregatedAmountswOrg Info
AAFwO <- read_csv("P_AggregatedAmountswOrg.csv")
export(AAFwO, "AggAmountTablewO.RData")

#Variables Info
V <- read_csv("Variables.csv")
export(V, "VarTable.RData")

#WaterSources Info
WS <- read_csv("P_WaterSources.csv")
export(WS, "PWaSoTable.RData")

#Methods Info
M <- read_csv("P_Methods.csv")
export(M, "PMetTable.RData")



#Code note Used
# #AggBridge_BeneficialUses Info
# ABBUF <- read_csv("AggBridge_BeneficialUses.csv")
# export(ABBUF, "BenUseTable.RData")

# #AggregatedAmounts Info
# AAF <- read_csv("AggregatedAmounts.csv")
# export(AAF, "AggAmountTable.RData")