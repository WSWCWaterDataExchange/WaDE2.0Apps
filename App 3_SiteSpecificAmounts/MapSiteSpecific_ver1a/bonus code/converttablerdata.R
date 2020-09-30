# App: MapSiteSpecific_ver1a
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 3_SiteSpecificAmounts\\MapSiteSpecific_ver1a\\data")


#SSA -to- Site
SSA <- read_csv("P_SSALJSite.csv")
export(SSA, "P_SSALJSite.RData")


#Site -to- SSA
SiteSSA <- read_csv("P_SiteLJSSA.csv")
export(SiteSSA, "P_SiteLJSSA.RData")


#EmptyData
EmptyData <- read_csv("EmptyData.csv")
export(EmptyData, "EmptyData.RData")