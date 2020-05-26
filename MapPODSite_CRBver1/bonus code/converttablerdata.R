#-----------------------------------------
#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\ColoradoRiverBasin\\CRBShinyAppver2\\data")

#Site Info
Sitex <- read_csv("P_dfSitesCRB.csv")
export(Sitex, "P_dfSite.RData")

#SiteAllInfo Info
SiteAllx <- read_csv("P_dfSiteWithAll_CRB.csv")
export(SiteAllx, "P_dfSiteWithAll_CRB.RData")

#Allocation Info
Allox <- read_csv("P_dfAllo_CRBSites.csv")
export(Allox, "P_dfAllo.RData")

#BenUse Info
BenUsex <- read_csv("P_dfBen_CRBSites.csv")
export(BenUsex, "P_dfBen.RData")