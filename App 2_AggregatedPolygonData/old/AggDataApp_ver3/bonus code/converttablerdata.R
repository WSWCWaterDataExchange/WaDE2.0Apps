#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\AggregatedData\\AggDataApp_ver3\\data")

#P_AggregatedAmounts_FactsUTNMWY Info
AAF <- read_csv("P_AggregatedAmounts_FactsUTNMWY.csv")
export(AAF, "AAF.RData")

#AggBridge_BeneficialUses_FactsUTNMWY Info
ABBUF <- read_csv("AggBridge_BeneficialUses_FactsUTNMWY.csv")
export(ABBUF, "ABBUF.RData")

#VariablesUTNMWY Info
V <- read_csv("VariablesUTNMWY.csv")
export(V, "V.RData")

#WaterSourcesUTNMWY Info
WS <- read_csv("WaterSourcesUTNMWY.csv")
export(WS, "WS.RData")

