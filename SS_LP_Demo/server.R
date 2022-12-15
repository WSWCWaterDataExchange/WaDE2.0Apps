# App: Site-Specific Landing Page Demo

################################################################################################
################################################################################################
# Sec 4. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ######## Create Base Map / Empty line plot ########
  
  # Base Map 
  output$mapA <- renderLeaflet({
    SiteMap = leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(
        providers$Esri.WorldGrayCanvas,
        options = providerTileOptions(
          updateWhenZooming = FALSE, # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)) # map won't load new tiles when panning
  }) #end renderLeaflet
  
  
  # Call Empty Line Plot Function
  output$LP_A <- renderPlotly(createEmptyPlotFunc())
  
  #------------------------
  # Crate Empty Plot Function
  #------------------------
  createEmptyPlotFunc <- function() {
    LP <- plot_ly(type='scatter', mode='lines+markers')
    LP <- LP %>% layout(title = paste0("Please Make a Selection"),
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    LP
    return(LP)
  }
  
  
  
  ###################################################################
  ######## API Data Retrieval ########
  
  # reactive dataset(). This returns empty / shows nothing if NULL
  filteredSite <- eventReactive(input$SQPInput, {
    if (input$SQPInput == "") {
      shiny::showNotification("No data", type = "error")
      NULL
    } else {
      return(val <- fromJSON(assignAPICallSiteUUID(input$SQPInput)))
    }
  })
  
  #------------------------
  # Concatenate API strings function
  #------------------------
  assignAPICallSiteUUID <- function(x) {
    str1 <-  "https://wade-api-uat.azure-api.net/v1/SiteVariableAmounts?SiteUUID="
    str2 <- toString(x)
    keyStr <- "key=38f422d1ada34907a91aff4532fa4669"
    outstring <- paste0(str1,str2,"&",keyStr)
    print(outstring)
    return(outstring)
  }
  
  
  
  ##################################################################
  ######## Observe change in SQPInput Input ######## 
  
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['SQPInput']])) {
      updateTextInput(session, "SQPInput", value = query[['SQPInput']])
    }
  })
  
  
  
  ###################################################################
  ######## Page Outputs, Table Outputs, Map, Line Plot ########
  
  observe({
    
    ######## Populate Page Outputs ########
    #org
    output$OrganizationName <- renderText(OrganizationFunc()[['OrganizationName']])
    output$State <- renderText(OrganizationFunc()[['OrganizationState']])
    output$Website <- renderText(OrganizationFunc()[['OrganizationWebsite']])
    
    #method
    output$ApplicableResourceType <- renderText(MethodFunc()[['ApplicableResourceType']])
    output$MethodType <- renderText(MethodFunc()[['MethodTypeCV']])
    output$MethodLink <- renderText(MethodFunc()[['MethodNEMILink']])
    output$MethodDescription <- renderText(MethodFunc()[['MethodDescription']])
    
    #site
    output$WaDESiteID <- renderText(SiteFunc()[['SiteUUID']])
    output$SiteNativeID <- renderText(SiteFunc()[['NativeSiteID']])
    output$SiteName <- renderText("TBD, API Bug") # output$SiteName <- renderText(SiteFunc()[[1]])
    output$Longitude <- renderText(SiteFunc()[['Longitude']])
    output$Latitude <- renderText(SiteFunc()[['Latitude']])
    output$County <- renderText(SiteFunc()[['County']])
    output$SiteType <- renderText("TBD, API Bug") # output$SiteType <-renderText(SiteFunc()[[1]])
    output$PODorPOU <- renderText(SiteFunc()[['PODorPOUSite']])
    
    #variable
    output$Variable <- DT::renderDataTable(VariableFunc(), options = list(scrollX = TRUE));
    
    #sitespecific
    output$SiteSpecificAmount <- DT::renderDataTable(SiteSpecificAmountFunc(), options = list(scrollX = TRUE));
    
    #watersource
    output$WaterSources <- DT::renderDataTable(WaterSourcesFunc(), options = list(scrollX = TRUE));
    
    #relatedPODsites
    output$RelatedPODSites <- DT::renderDataTable(RelatedPODSitesFunc(), escape = FALSE, options = list(scrollX = TRUE));
    
    #relatedPOUISites
    output$RelatedPOUSites <- DT::renderDataTable(RelatedPOUSitesFunc(), options = list(scrollX = TRUE));
    
    
    ######## Create mapA Output ######## 
    try({
      # createPolyMapFunc()
      if(is.na(SiteFunc()$SiteGeometry) == FALSE) {
        print("Yes Geometry")
        inputData <- sf::st_as_sf(SiteFunc(), wkt = "SiteGeometry")
        createPolyMapFunc(inputData)
      } else {
        createSiteMapFunc(SiteFunc())
      }
    }) #end try
    
    
    ######## Call Line Plot Ouput ########
    try({
      SiteSpecificAmount <- SiteSpecificAmountFunc()
      createLinePlotsAFunc(SiteSpecificAmount)
    }) #end try
    
  }) #end Observe
  
  
  #------------------------
  # Organization Info function
  #------------------------
  OrganizationFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      Organization <- vector(mode='list', length=7)
    } else {
      Organization <- filteredSite()[['Organizations']]
    }
    return(Organization)
  }
  
  #------------------------
  # Method Info function
  #------------------------
  MethodFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      Method <- vector(mode='list', length=9)
    } else {
      Method <- filteredSite()[['Organizations']][['Methods']][[1]]
    }
    return(Method)
  }
  
  #------------------------
  # Site Info function
  #------------------------
  SiteFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      Site <- vector(mode='list', length=13)
    } else {
      Site <- filteredSite()[['Organizations']][['Sites']][[1]]
    }
    return(Site)
  }
  
  #------------------------
  # Variable Info function
  #------------------------
  VariableFunc <-function() {
    if(length(filteredSite()[[2]]) == 0) {
      Variable <- data.frame(EmptyTable=double())
    } else {
      Variable <- filteredSite()[['Organizations']][['VariableSpecifics']][[1]]
    }
    return(Variable)
  }
  
  #------------------------
  # SiteSpecificAmount Info function
  #------------------------
  SiteSpecificAmountFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      SiteSpecificAmount <- data.frame(EmptyTable=double())
    } else {
      SiteSpecificAmount <- filteredSite()[['Organizations']][['SiteVariableAmounts']][[1]]
    }
    return(SiteSpecificAmount)
  }
  
  #------------------------
  # WaterSources Info function
  #------------------------
  WaterSourcesFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      WaterSources <- data.frame(EmptyTable=double())
    } else {
      WaterSources <- filteredSite()[['Organizations']][['WaterSources']][[1]]
    }
    return(WaterSources)
  }
  
  #------------------------
  # RelatedPODSites Info function
  #------------------------
  RelatedPODSitesFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      RelatedPODSites <- data.frame(EmptyTable=double())
    } else {
      RelatedPODSites <- filteredSite()[['Organizations']][['Sites']][[1]][['RelatedPODSites']][[1]]
      if(length(RelatedPODSites) == 0) {
        RelatedPODSites <- data.frame(EmptyTable=double())
      } else {
        RelatedPODSites$SiteUUID <- paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', RelatedPODSites$SiteUUID, '", target=\"_blank\">', RelatedPODSites$SiteUUID, '</a>')
      }
    }
    return(RelatedPODSites)
  }
  
  #------------------------
  # RelatedPOUSites Info function
  #------------------------
  RelatedPOUSitesFunc <-function() {
    if(length(filteredSite()[['Organizations']]) == 0) {
      RelatedPOUSites <- data.frame(EmptyTable=double())
    } else {
      RelatedPOUSites <- filteredSite()[['Organizations']][['Sites']][[1]][['RelatedPOUSites']][[1]]
      if(length(RelatedPOUSites) == 0) {
        RelatedPOUSites <- data.frame(EmptyTable=double())
      } else {
        RelatedPOUSites$SiteUUID <- paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', RelatedPOUSites$SiteUUID, '", target=\"_blank\">', RelatedPOUSites$SiteUUID, '</a>')
      }
    }
    return(RelatedPOUSites)
  }
  
  #------------------------
  # Site Map function
  #------------------------
  createSiteMapFunc <- function(inputData) {
    SiteMapProxy = leafletProxy(mapId="mapA") %>%
      setView(
        lng = inputData$Longitude,
        lat = inputData$Latitude,
        zoom = 10) %>%
      clearGroup(group=c("SiteGroup")) %>%
      addCircleMarkers(
        data = inputData,
        layerId = ~SiteUUID,
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 2,
        group = "SiteGroup",
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = paste(
          "<b>Native Site ID:</b>", inputData$SiteNativeID, "<br>",
          "<b>WaDE Site ID:</b>", inputData$SiteUUID, "<br>",
          "<b>Site Name:</b>", inputData$SiteName, "<br>",
          "<b>Site Type:</b>", inputData$WaDENameS, "<br>",
          "<b>Water Source Type:</b>", inputData$WaDENameWS, "<br>",
          "<b>Varaible Type:</b>", inputData$VariableCV, "<br>",
          "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', inputData$SiteUUID, '", target=\"_blank\"> Link </a>'))
      )
    return(SiteMapProxy)
  }
  
  #------------------------
  # Poly Map function
  #------------------------
  createPolyMapFunc <- function(inputData) {
    bbox <- st_bbox(inputData) %>% as.vector()
    AreaMapProxy = leafletProxy(mapId="mapA") %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) %>%
      clearGroup(group=c("AreaGroup")) %>%
      addPolygons(
        data = inputData,
        group = "AreaGroup")
    return()
  }
  
  #------------------------
  # Line Plot A Function
  #------------------------
  createLinePlotsAFunc <- function(SiteSpecificAmount) {
    output$LP_A <- renderPlotly({
      # Plot Subset Data - Amount via VariableSpecificCV vs TimeFrameStart
      
      # AmountsData_v3 <- SiteSpecificAmount %>% group_by(SiteUUID, TimeframeStart, VariableSpecificTypeCV, Amount) %>% summarise(SumAmount = sum(Amount))
      # AmountsData_v3$TimeframeStart <- as.Date(AmountsData_v3$TimeframeStart)
      # SiteUUIDstring <- unique(AmountsData_v3$SiteUUID)
      # AmountsData_v3 <- ungroup(AmountsData_v3) # Error in plotly not using lines with group_by() function.
      
      # temp fix for VariableSpecificTypeCV API issue
      library(rio)
      variableCVFile <- import("data/variableCV.csv")  # POD Site Table
      SiteSpecificAmount <- merge(x=SiteSpecificAmount, y=variableCVFile, by="VariableSpecificTypeCV",all.x=TRUE)
      AmountsData_v3 <- SiteSpecificAmount %>% group_by(SiteUUID, TimeframeStart, VariableSpecificCV, Amount) %>% summarise(SumAmount = sum(Amount))
      AmountsData_v3$TimeframeStart <- as.Date(AmountsData_v3$TimeframeStart)
      SiteUUIDstring <- unique(AmountsData_v3$SiteUUID)
      AmountsData_v3 <- ungroup(AmountsData_v3) # Error in plotly not using lines with group_by() function.
  
      # The Plot
      LP_A <- plot_ly(data=AmountsData_v3, x=~TimeframeStart, y=~SumAmount,
                      # color=~VariableSpecificTypeCV, # temp fix
                      color=~VariableSpecificCV,
                      type='scatter', mode='lines+markers')
      LP_A <- LP_A %>% layout(title=paste0("WaDE Site ID: ", SiteUUIDstring),
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Time"),
                              yaxis = list(title="Sum of Water Amount"),
                              # legend = list(title=list(text='<b>VariableSpecificTypeCV</b>')), #temp fix
                              legend = list(title=list(text='<b>VariableSpecificCV</b>')),
                              showlegend=TRUE)
      LP_A
    })
    return(output)
  }
  
  
  
  ##################################################################
  ####### Export Tables to Excel ########
  
  
  
  
  # downloadData <- eventReactive(input$SQPInput, {
  #   Method <- MethodFunc()
  #   Variable <- VariableFunc()
  #   Organization <- OrganizationFunc()[1:7]
  #   WaterSources <- WaterSourcesFunc()
  #   Sites <- SiteFunc()[1:11]
  #   SiteSpecificAmount <- SiteSpecificAmountFunc()[1:31]
  #   RelatedPODSites <- RelatedPODSitesFunc()[1:3]
  #   RelatedPOUSites <- RelatedPOUSitesFunc()[1:3]
  # })
  
  
  
  observe({
    output$downloadDataOuput <- downloadHandler(
      
      filename = function() {"WaDE_Data_Download.xlsx"},
      content = function(file) {
        
        Method <- MethodFunc()
        Variable <- VariableFunc()
        Organization <- OrganizationFunc()[1:7]
        WaterSources <- WaterSourcesFunc()
        Sites <- SiteFunc()[1:11]
        SiteSpecificAmount <- SiteSpecificAmountFunc()[1:31]
        RelatedPODSites <- RelatedPODSitesFunc()[1:3]
        RelatedPOUSites <- RelatedPOUSitesFunc()[1:3]
        
        # write workbook
        listFiles <- list(Method, Variable, Organization, WaterSources, Sites, SiteSpecificAmount, RelatedPODSites)
        listNames <- list("Method", "Variable", "Organization", "WaterSources", "Sites", "SiteSpecificAmount", "RelatedPODSites", "RelatedPOUSites")
        for(i in 1:length(listFiles)) {
          write.xlsx(x=listFiles[i], file=file, sheetName=listNames[i], append = TRUE)
        }
      } #end content
    ) #end downloadHandler
    
  })
  
  
} #End server