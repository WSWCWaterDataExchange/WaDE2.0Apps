# App: RE Demo
library(rio)
library(readr)
library(readxl)
setwd("C:\\Users\\rjame\\Documents\\WSWC Documents\\WaDE Side Projects Local\\Rshiny RE Demo\\RE_Demo\\data")


#Sites_v2_sites
Sites_v2_sites <- read_excel("sites_v2.xlsx")
export(Sites_v2_sites, "sites_v2.RData")


# #Sites_v2_sites
# Sites_v2_sites <- read_excel("sitesB_v2.xlsx")
# export(Sites_v2_sites, "sitesB_v2.RData")

