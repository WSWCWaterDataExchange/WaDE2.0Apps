#AllData.RData Sample
library(rio)
library(readr)
setwd("C:\\Users\\rjame\\Documents\\RShinyAppPractice\\App 3_SiteSpecificAmounts\\MapSiteSpecific_ver3\\data")

#SiteVariableAmounts_fact
SiteVariableAmounts <- read_csv("SiteVariableAmounts_fact.csv")
export(SiteVariableAmounts, "SiteVariableAmounts.RData")

#Sites
Sites <- read_csv("Sites.csv")
export(Sites, "Sites.RData")






