###################################################################################
###################################################################################
# Libraries
library(dplyr)
library(stringr)
library(leaflet)


###################################################################################
###################################################################################
# InputData & Functions
Map_DF <- data.frame("Point_ID" = 1:3,
                     "Latitude" = c(38.10, 38.20, 38.30),
                     "Longitude" = c(-107.10, -107.20, -107.30),
                     "PointUse" = c("farm", "house", "farm, house"))



#This will add a color column to site based on order of str_detect writting here (e.g., red first)
Map_DF <- Map_DF %>% 
  mutate(color = case_when(str_detect(PointUse, "farm") ~ "red",
                           str_detect(PointUse, "house") ~ "blue",
                           TRUE ~ "a default"))


print(Map_DF)
# Point_ID Latitude Longitude  PointUse      color
#     1     38.1    -107.1       farm         red
#     2     38.2    -107.2       house        blue
#     3     38.3    -107.3       farm, house  blue


###################################################################################
###################################################################################
# Leaflet Map
leaflet(Map_DF) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(
    data = Map_DF,
    lat = ~Latitude,
    lng = ~Longitude,
    color = Map_DF$color,
    stroke = FALSE,
    popup = ~PointUse)
