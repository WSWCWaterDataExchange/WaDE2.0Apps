# App: AggDataApp_ver3
# Sec 0. Code Notes and Purpose
# Date: 05/19/2020
# Topic: 1) Creating Aggreated Data Polygon Map App
#        2) Only using limited inputs at this time.


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
# Libraries
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(leaflet.extras)
library(leafem) #leaflet extention.
library(dplyr) # Used to filter data for plots.
library(ggplot2) # To create plots within the output for the app.
library(sp) #Uses SpatialPointsDataFrame function.
library(DT) # Used to create more efficent data table output.
library(rio) #to import RData table from external source
library(readr) #to read RData format from external source

library(rgdal)  # R Geospatial Dat Abstraction library, used for working with shapefiles.
library(tidyverse)

library(RColorBrewer)

# Input Data
AAF <- import("C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data/AAF.RData")
ABBUF <- import("C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data/ABBUF.RData")
V <- import("C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data/V.RData")
WS <- import("C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data/WS.RData")

#Shape Files
CountyAggSF <- readOGR(dsn = "C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data", layer = "CountyAgg")
HUCAggSF <- readOGR(dsn = "C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data", layer = "HUCAgg")
BasinAggSF <- readOGR(dsn = "C:/Users/rjame/Documents/RShinyAppPractice/AggregatedData/AggDataApp_ver3/data", layer = "BasinAgg")


################################################################################################
################################################################################################



#Subset of data
tempAAF <- AAF %>% filter(ReportingUnitID == 486)
tempAAF_2 <- left_join(x = tempAAF, y = V, by = "VariableSpecificID")

#Consumptive use
tempAAF_2_V1 <- tempAAF_2 %>% filter(VariableCV  == "Consumptive use")
tempAAF_2_V1_Y <- tempAAF_2_V1 %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))

# #Withdrawal
tempAAF_2_V2 <- tempAAF_2 %>% filter(VariableCV == "Withdrawal")
tempAAF_2_V2_Y <- tempAAF_2_V2 %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))

finalAFF <- rbind(tempAAF_2_V1_Y, tempAAF_2_V2_Y)



BtempAAF <- AAF %>% filter(ReportingUnitID == 486)
BtempAAF_2 <- left_join(x = BtempAAF, y = WS, by = "WaterSourceID")
BtempAAF_2_V <- BtempAAF_2 %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))


################################################
#Plotting
library(ggplot2) # To create plots within the output for the app.
library(plotly)

pa <- ggplot(data=BtempAAF_2_V, aes(x=ReportYearCV, y=SumAmouts, group=WaterSourceUUID, col=WaterSourceUUID)) +
  geom_line(show.legend = TRUE) +
  geom_point(show.legend = FALSE) +
  ggtitle("TEMP Amount -per- Report Year (WaterSourceType)") +
  scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                  round(max(finalAFF$ReportYearCV), digits =0),
                                  round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
  scale_y_continuous(labels = scales::comma,
                     limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                round(max(finalAFF$SumAmouts), digits = 0))) +
  labs(x="Report Year", y="Annual Water Use (Acre-Feet)") +
  theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
        plot.title = element_text(hjust = 0.5, size = 14.0),
        panel.background=element_blank(),
        axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
        axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
        plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))

ggplotly(pa)