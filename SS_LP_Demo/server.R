# App: Site-Specific Landing Page Demo

################################################################################################
################################################################################################
# Sec 4. The Server (function)

server <- function(input, output, session) {
  
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
  assignAPICallSiteUUID <- function(x) {
    str1 <-  "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
    str2 <- toString(x)
    keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
    outstring <- paste0(str1,str2,"&",keyStr)
    print(outstring)
    return(outstring)
  }
  
  
  # reactive dataset(). This returns empty / shows nothing if null
  filteredSite <- eventReactive(input$SQPInput, {
    if (input$SQPInput == "") {
      shiny::showNotification("No data", type = "error")
      NULL
    } else {
      return(val <- fromJSON(assignAPICallSiteUUID(input$SQPInput)))
    }
  })
  
  
  
  ###################################################################
  ######## WaDE API Outputs ########
  
  # Organization Info
  OrganizationFunc <-function() {
    if(length(filteredSite()[[2]]) == 0) {
      Organization <- list('Empty')
    } else {
      Organization <- filteredSite()[[2]]
    }
    return(Organization)
  }
  output$OrganizationName <- renderText(OrganizationFunc()[[1]])
  output$State <- renderText(OrganizationFunc()[[7]])
  output$Website <- renderText(OrganizationFunc()[[3]])
  
  
  # Method Info
  MethodFunc <-function() {
    if(length(filteredSite()[[2]][[10]][[1]]) == 0) {
      Method <- list('Empty')
    } else {
      Method <- filteredSite()[[2]][[10]][[1]]
    }
    return(Method)
  }
  output$ApplicableResourceType <- renderText(MethodFunc()[[5]])
  output$MethodType <- renderText(MethodFunc()[[6]])
  output$MethodLink <- renderText(MethodFunc()[[4]])
  output$MethodDescription <- renderText(MethodFunc()[[3]])
  
  
  # Site Info
  SiteFunc <-function() {
    if(length(filteredSite()[[2]][[13]][[1]]) == 0) {
      Site <- list('Empty')
    } else {
      Site <- filteredSite()[[2]][[13]][[1]]
    }
    return(Site)
  }
  output$WaDESiteID <- renderText(SiteFunc()[[1]])
  output$SiteNativeID <- renderText(SiteFunc()[[2]])
  output$SiteName <- renderText(SiteFunc()[[1]])
  output$Longitude <- renderText(SiteFunc()[[3]])
  output$Latitude <- renderText(SiteFunc()[[4]])
  output$County <- renderText(SiteFunc()[[10]])
  output$SiteType <-renderText(SiteFunc()[[1]])
  output$PODorPOU <- renderText(SiteFunc()[[11]])
  
  
  # Variable Info
  VariableFunc <-function() {
    if(length(filteredSite()[[2]][[9]][[1]]) == 0) {
      Variable <- list('Empty')
    } else {
      Variable <- filteredSite()[[2]][[9]][[1]]
    }
    return(Variable)
  }
  output$Variable <- DT::renderDataTable(VariableFunc(), options = list(scrollX = TRUE));
  
  
  # SiteSpecificAmount Info
  SiteSpecificAmountFunc <-function() {
    if(length(filteredSite()[[2]][[12]][[1]][1:30]) == 0) {
      SiteSpecificAmount <- list('Empty')
    } else {
      SiteSpecificAmount <- filteredSite()[[2]][[12]][[1]][1:30]
    }
    return(SiteSpecificAmount)
  }
  output$SiteSpecificAmount <- DT::renderDataTable(SiteSpecificAmountFunc(), options = list(scrollX = TRUE));
  
  
  # WaterSources Info
  WaterSourcesFunc <-function() {
    if(length(filteredSite()[[2]][[8]][[1]]) == 0) {
      WaterSources <- list('Empty')
    } else {
      WaterSources <- filteredSite()[[2]][[8]][[1]]
    }
    return(WaterSources)
  }
  output$WaterSources <- DT::renderDataTable(WaterSourcesFunc(), options = list(scrollX = TRUE));
  
  
  
  ##################################################################
  ######## Map ########
  
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
  
  # Incremental Changes to the Map / Responses to filters
  observe({
    try({
      # Subset of Data
      siteDataTable <- SiteFunc()
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        setView(
          lng = siteDataTable$Longitude,
          lat = siteDataTable$Latitude,
          zoom = 10) %>%
        
        # Add POD Sites
        addCircleMarkers(
          data = siteDataTable,
          layerId = ~SiteUUID,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 2)
    }) #end try
  }) #end Observe
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  
  # Create Empty Line Plots on App Launch
  observe({
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
  }) #endObserve
  
  
  # Create Line Plots based on observeEvent - input$SQPInput not null
  observeEvent(eventExpr=input$SQPInput, handlerExpr={
    SiteSpecificAmount <-SiteSpecificAmountFunc()
    createLinePlotsAFunc(SiteSpecificAmount)
  }, ignoreNULL = FALSE
  ) #end ObserveEvent
  
  
  # Create Line Plot A Function
  createLinePlotsAFunc <- function(SiteSpecificAmount) {
    output$LP_A <- renderPlotly({
      # Plot Subset Data - Amount via VariableSpecificCV vs TimeFrameStart
      AmountsData_v3 <- SiteSpecificAmount %>% group_by(SiteUUID, TimeframeStart, VariableSpecificTypeCV, Amount) %>% summarise(SumAmount = sum(Amount))
      
      # Error in plotly not using lines with group_by() function.
      AmountsData_v3 <- ungroup(AmountsData_v3)
      
      # The Plot
      LP_A <- plot_ly(data=AmountsData_v3, x=~TimeframeStart, y=~SumAmount,
                      color=~VariableSpecificTypeCV,
                      type='scatter', mode='lines+markers')
      LP_A <- LP_A %>% layout(title="WaDE Site ID: xxx",
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Time"),
                              yaxis = list(title="Sum of Water Amount"),
                              legend = list(title=list(text='<b>VariableSpecificTypeCV</b>')),
                              showlegend=TRUE)
      LP_A
    })
    return(output)
  }
  
  
  
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
      Sites <- SiteFunc()
      WaterSources <- WaterSourcesFunc()
      SiteSpecificAmount <- SiteSpecificAmountFunc()
      
      
      # write workbook and first sheet
      write.xlsx(Method, file, sheetName = "Method", append = FALSE)
      
      # add other sheets for each dataframe
      listOtherFiles <- list(Variable, Organization, WaterSources, Sites, SiteSpecificAmount)
      for(i in 1:length(listOtherFiles)) {
        write.xlsx(listOtherFiles[i], file, sheetName = names(listOtherFiles)[i], append = TRUE)
      }
    }
  )

  
  
} #End server