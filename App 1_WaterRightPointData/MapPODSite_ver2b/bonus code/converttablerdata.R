#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 1_WaterRightPointData\\MapPODSite_ver2b\\data")

#Allo LF Sites
P_AlloLFSite <- read_csv("P_AllowLJSite.csv")
export(P_AlloLFSite, "P_AllowLJSite.RData")

#Sites LF Allo
P_SiteLFAllo <- read_csv("P_SiteLJAllow.csv")
export(P_SiteLFAllo, "P_SiteLJAllow.RData")

#Sites_Basin LF Allo
P_SiteLFAllo_Basin <- read_csv("P_SiteLJAllow_Basin.csv")
export(P_SiteLFAllo_Basin, "P_SiteLJAllow_Basin.RData")

# #Sites_CRB LF Allo
# P_SiteLFAllo_CRB <- read_csv("P_SiteLFAllo_CRB.csv")
# export(P_SiteLFAllo_CRB, "P_SiteLFAllo_CRB.RData")
# 
# #Sites_RG LF Allo
# P_SiteLFAllo_RG <- read_csv("P_SiteLFAllo_RG.csv")
# export(P_SiteLFAllo_RG, "P_SiteLFAllo_RG.RData")
# 
# #Sites_Col LF Allo
# P_SiteLFAllo_Col <- read_csv("P_SiteLFAllo_Col.csv")
# export(P_SiteLFAllo_Col, "P_SiteLFAllo_Col.RData")

