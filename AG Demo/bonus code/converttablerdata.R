# App: SSPS Demo
library(rio)
library(readr)
library(readxl)
setwd("C:\\Users\\rjame\\Documents\\WSWC Documents\\WaDE Side Projects Local\\20221024 Rshiny AG Demo\\AG Demo\\data")


#ReportingUnit_v2
ReportingUnit_v2 <- read_excel("ReportingUnit_v2.xlsx")
export(ReportingUnit_v2, "ReportingUnit_v2.RData")

