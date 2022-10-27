# MapSiteSpecific_ver3
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 3_SiteSpecificAmounts\\MapSiteSpecific_ver3\\data")

#SiteVariableAmounts_fact
SiteVariableAmounts <- read_csv("SiteVariableAmounts_fact.csv")
export(SiteVariableAmounts, "SiteVariableAmounts.RData")

#POD Sites
SitesPOD <- read_csv("Sites_PODs.csv")
export(SitesPOD, "SitesPOD.RData")

#wr_sites
wr_sites <- read_csv("wr_sites.csv")
export(wr_sites, "wr_sites.RData")






