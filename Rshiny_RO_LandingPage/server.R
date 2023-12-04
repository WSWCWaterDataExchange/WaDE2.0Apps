



# Define server
server <- function(input,output, session){
  
  
  ##################################################################
  ######## Observe change in ruInput Input ######## 
  
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['SQPInput']])) {
      updateTextInput(session, "SQPInput", value = query[['SQPInput']])
    }
  })
  
  
  ###################################################################
  ######## API Data Retrieval ########
  
  #Function to concatenate strings together to form URL and API call.
  assignAPICallReportingUnitUUID <- function(x) {
    str1 <-  "https://wade-api-uat.azure-api.net/v1/AggRegulatoryOverlay?ReportingUnitUUID="
    str2 <- toString(x)
    keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
    outstring <- paste0(str1,str2,"&",keyStr)
    print(outstring)
    return(outstring)
  }
  
  # reactive data set.
  filteredReportingUnit <- eventReactive(input$SQPInput, {
    if (input$SQPInput == "") {
      shiny::showNotification("No data", type = "error")
    } else {
      return(val <- fromJSON(assignAPICallReportingUnitUUID(input$SQPInput)))
    }
  })
  
  
  ##################################################################
  ######## Create Empty Base Map ########
  
  # Site Specific Map
  output$mapA <- renderLeaflet({
    # Create the Base Map
    SiteMap = leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      
      # Add tile layer upon launch
      addProviderTiles(
        providers$Esri.WorldGrayCanvas,
        options = providerTileOptions(
          updateWhenZooming = FALSE, # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)) # map won't load new tiles when panning
  }) #end renderLeaflet
  
  
  ###################################################################
  ######## WaDE API Outputs, Table Outputs, Map, Line Plot ########
  
  observe({
    
    ######## WaDE API Outputs ########
    
    # Organization Block Info
    OrganizationFunc <-function() {
      Organization <- filteredReportingUnit()[['Organizations']]
      return(Organization)
    }
    
    
    # ReportingUnitsRegulatory Block Info
    ReportingUnitsRegulatoryFunc <-function() {
      ReportingUnitsRegulatory <- filteredReportingUnit()[['Organizations']][['ReportingUnitsRegulatory']][[1]]
      return(ReportingUnitsRegulatory)
    }
    
    # RegulatoryOverlays Table Info
    RegulatoryOverlaysFunc <-function() {
      RegulatoryOverlays <- filteredReportingUnit()[['Organizations']][['RegulatoryOverlays']][[1]]
      return(RegulatoryOverlays)
    }
    
    ######## Populate Data Blocks & Tables ########
    # Organization Block
    output$OrganizationName <- renderText(OrganizationFunc()[['OrganizationName']])
    output$State <- renderText(OrganizationFunc()[['OrganizationState']])
    output$Website <- renderText(OrganizationFunc()[['OrganizationWebsite']])
    
    # ReportingUnitsRegulatory BLock
    output$WaDEAreaID <- renderText(ReportingUnitsRegulatoryFunc()[['ReportingUnitUUID']])
    output$AreaNativeID <- renderText(ReportingUnitsRegulatoryFunc()[['ReportingUnitNativeID']])
    output$AreaName <- renderText(ReportingUnitsRegulatoryFunc()[['ReportingUnitName']])
    output$AreaType <- renderText(ReportingUnitsRegulatoryFunc()[['ReportingUnitTypeCV']])
    output$WaterSourceType <- renderText(RegulatoryOverlaysFunc()[['WaterSourceTypeCV']])
    
    # RegulatoryOverlays Table
    output$RegulatoryOverlays <- DT::renderDataTable(RegulatoryOverlaysFunc(), options = list(scrollX = TRUE));
    
    
    # map
    try({
      # Subset of Data
      areaDataTable <- ReportingUnitsRegulatoryFunc()
      areaDataTable <- sf::st_as_sf(areaDataTable, wkt = "Geometry")
      bbox <- st_bbox(areaDataTable) %>% as.vector()
      
      # Call the Map
      AreaMapProxy = leafletProxy(mapId="mapA") %>%
        
        #setView
        fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) %>%
        
        # Clean Map
        clearGroup(group=c("AreaGroup")) %>%
        
        # Add POD Sites
        addPolygons(
          data = areaDataTable,
          group = "AreaGroup")
      
    }) #end try
    
  }) #end Observe
  
  
  ##################################################################
  ####### Export Tables to Excel ########
  
  output$downloadExcel <- downloadHandler(
    
    filename = function() {
      "WaDE_Data_Download.xlsx"
    },
    content = function(file) {
      
      Organization <- OrganizationFunc()
      ReportingUnitsRegulatory <- ReportingUnitsRegulatoryFunc()
      RegulatoryOverlays <- RegulatoryOverlaysFunc()
      
      # write workbook and first sheet
      write.xlsx(Organization, file, sheetName = "Organization", append = FALSE)
      
      # add other sheets for each dataframe
      listOtherFiles <- list(ReportingUnitsRegulatory, RegulatoryOverlays)
      for(i in 1:length(listOtherFiles)) {
        write.xlsx(listOtherFiles[i], file, sheetName = names(listOtherFiles)[i], append = TRUE)
      }
    }
  )
  
  
}# end server