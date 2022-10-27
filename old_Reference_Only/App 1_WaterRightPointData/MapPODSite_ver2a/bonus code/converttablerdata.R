#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 1_WaterRightPointData\\MapPODSite_ver2\\data")

#Sites LF Allo
P_SiteLFAllo <- read_csv("P_SiteLFAllo.csv")
export(P_SiteLFAllo, "P_SiteLFAllo.RData")

#Sites_CRB LF Allo
P_SiteLFAllo_CRB <- read_csv("P_SiteLFAllo_CRB.csv")
export(P_SiteLFAllo_CRB, "P_SiteLFAllo_CRB.RData")

#Allo LF Sites
P_AlloLFSite <- read_csv("P_AlloLFSite.csv")
export(P_AlloLFSite, "P_AlloLFSite.RData")
