# App: Ag Landing Page Demo

################################################################################################
################################################################################################
# Sec 4. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ######## Create Base Map ########
  
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
  
  
  ##################################################################
  ####### Blank Line Plots Based on Observe Functions ########
  
  # Create Empty Line Plots on App Launch
  # Crate Empty Plot Function
  createEmptyPlotFunc <- function() {
    LP <- plot_ly(type='scatter', mode='lines+markers')
    LP <- LP %>% layout(title = paste0("Please Make a Selection"),
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    LP
    return(LP)
  }
  
  # Call Empty Line Plot Function
  output$LP_A <- renderPlotly(createEmptyPlotFunc())
  
  
  ##################################################################
  ######## Observer change SQPInput Input ######## 
  
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
    str1 <-  "https://wade-api-uat.azure-api.net/v1/AggregatedAmounts?ReportingUnitUUID="
    str2 <- toString(x)
    keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
    outstring <- paste0(str1,str2,"&",keyStr)
    print(outstring)
    return(outstring)
  }
  
  
  # reactive dataset(). This returns empty / shows nothing if null
  filteredReportingUnit <- eventReactive(input$SQPInput, {
    if (input$SQPInput == "") {
      shiny::showNotification("No data", type = "error")
      # NULL
    } else {
      return(val <- fromJSON(assignAPICallReportingUnitUUID(input$SQPInput)))
    }
  })
  
  
  ###################################################################
  ######## WaDE API Outputs, Table Outputs, Map, Line Plot ########
  
  observe({
    
    ######## WaDE API Outputs ########
    
    # Organization Info
    OrganizationFunc <-function() {
      if(length(filteredReportingUnit()[['Organizations']]) == 0) {
        Organization <- vector(mode='list', length=7)
      } else {
        Organization <- filteredReportingUnit()[['Organizations']]
      }
      return(Organization)
    }
    
    # Method Info
    MethodFunc <-function() {
      if(length(filteredReportingUnit()[['Organizations']]) == 0) {
        Method <- vector(mode='list', length=9)
      } else {
        Method <- filteredReportingUnit()[['Organizations']][['Methods']][[1]]
      }
      return(Method)
    }
    
    # ReportingUnit Info
    ReportingUnitFunc <-function() {
      if(length(filteredReportingUnit()[['Organizations']]) == 0) {
        ReportingUnit <- vector(mode='list', length=13)
      } else {
        ReportingUnit <- filteredReportingUnit()[['Organizations']][['ReportingUnits']][[1]]
      }
      return(ReportingUnit)
    }
    
    # Variable Info
    VariableFunc <-function() {
      if(length(filteredReportingUnit()[[2]]) == 0) {
        Variable <- data.frame(EmptyTable=double())
      } else {
        Variable <- filteredReportingUnit()[['Organizations']][['VariableSpecifics']][[1]]
      }
      return(Variable)
    }
    
    # AggregatedAmounts Info
    AggregatedAmountsFunc <-function() {
      if(length(filteredReportingUnit()[['Organizations']]) == 0) {
        AggregatedAmounts <- data.frame(EmptyTable=double())
      } else {
        AggregatedAmounts <- filteredReportingUnit()[['Organizations']][['AggregatedAmounts']][[1]][1:14]
      }
      return(AggregatedAmounts)
    }
    
    # WaterSources Info
    WaterSourcesFunc <-function() {
      if(length(filteredReportingUnit()[['Organizations']]) == 0) {
        WaterSources <- data.frame(EmptyTable=double())
      } else {
        WaterSources <- filteredReportingUnit()[['Organizations']][['WaterSources']][[1]]
      }
      return(WaterSources)
    }
    
    ######## Populate Data Tables ########
    #org
    output$OrganizationName <- renderText(OrganizationFunc()[['OrganizationName']])
    output$State <- renderText(OrganizationFunc()[['OrganizationState']])
    output$Website <- renderText(OrganizationFunc()[['OrganizationWebsite']])
    
    #method
    output$ApplicableResourceType <- renderText(MethodFunc()[['ApplicableResourceType']])
    output$MethodType <- renderText(MethodFunc()[['MethodTypeCV']])
    output$MethodLink <- renderText(MethodFunc()[['MethodNEMILink']])
    output$MethodDescription <- renderText(MethodFunc()[['MethodDescription']])
    
    #reportingunit
    output$WaDEAreaID <- renderText(ReportingUnitFunc()[['ReportingUnitUUID']])
    output$AreaNativeID <- renderText(ReportingUnitFunc()[['ReportingUnitNativeID']])
    output$AreaName <- renderText(ReportingUnitFunc()[['ReportingUnitName']])
    output$AreaType <- renderText(ReportingUnitFunc()[['ReportingUnitTypeCV']])
    
    #variable
    output$Variable <- DT::renderDataTable(VariableFunc(), options = list(scrollX = TRUE));
    
    #aggregatedamounts
    output$AggregatedAmounts <- DT::renderDataTable(AggregatedAmountsFunc(), options = list(scrollX = TRUE));
    
    #watersource
    output$WaterSources <- DT::renderDataTable(WaterSourcesFunc(), options = list(scrollX = TRUE));
    

    ######## Map ########
    try({
      # Subset of Data
      areaDataTable <- ReportingUnitFunc()
      areaDataTable <- sf::st_as_sf(areaDataTable, wkt = "ReportingUnitGeometry")
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
    
    
    
    ######## Line Plot ########
    # Create Line Plot A Function
    createLinePlotsAFunc <- function(AggregatedAmounts) {
      output$LP_A <- renderPlotly({
        # Plot Subset Data - Amount via VariableSpecificCV vs TimeFrameStart
        AmountsData_v3 <- AggregatedAmounts %>% group_by(TimeframeStart, VariableSpecificTypeCV, Amount) %>% summarise(SumAmount = sum(Amount))
        
        # Error in plotly not using lines with group_by() function.
        AmountsData_v3 <- ungroup(AmountsData_v3)
        
        # The Plot
        LP_A <- plot_ly(data=AmountsData_v3, x=~TimeframeStart, y=~SumAmount,
                        color=~VariableSpecificTypeCV,
                        type='scatter', mode='lines+markers')
        LP_A <- LP_A %>% layout(title="WaDE Area ID: xxx",
                                paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                                xaxis = list(title="Report Time"),
                                yaxis = list(title="Sum of Water Amount"),
                                legend = list(title=list(text='<b>VariableSpecificTypeCV</b>')),
                                showlegend=TRUE)
        LP_A
      })
      return(output)
    }
    
    ######## Call Line Plot Func ########
    try({
      AggregatedAmounts <- AggregatedAmountsFunc()
      createLinePlotsAFunc(AggregatedAmounts)
    }) #end try
    
  }) #end Observe
  
  
  
  ##################################################################
  ####### Export Tables to Excel ########
  
  output$downloadExcel <- downloadHandler(
    
    filename = function() {
      "WaDE_Data_Download.xlsx"
    },
    content = function(file) {
      
      Method <- MethodFunc()
      Variable <- VariableFunc()
      Organization <- OrganizationFunc()
      Sites <- ReportingUnitFunc()
      WaterSources <- WaterSourcesFunc()
      AggregatedAmounts <- AggregatedAmountsFunc()
      
      
      # write workbook and first sheet
      write.xlsx(Method, file, sheetName = "Method", append = FALSE)
      
      # add other sheets for each dataframe
      listOtherFiles <- list(Variable, Organization, WaterSources, Sites, AggregatedAmounts)
      for(i in 1:length(listOtherFiles)) {
        write.xlsx(listOtherFiles[i], file, sheetName = names(listOtherFiles)[i], append = TRUE)
      }
    }
  )
  
  
} #End server