# App: AggDataApp

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  ### County ###
  #Filter BenUse Table
  countyFilterBenUse <- reactive({
    P_CABBUF %>%
      filter(
        BeneficialUseCV %in% input$BenUseInput
      )
  })
  #Filter AggFacts Table - Child BenUse Table
  countyFilterAllow <- reactive({
    P_CAAF %>%
      filter(
        #Note: NM has no assinged BenUse in the WaDE 2.0 QA
        AggregatedAmountID %in% countyFilterBenUse()$AggregatedAmountID
      )
  })
  #Filter Site Table - Child AggFacts Table - Child BenUse Table
  countyFilteredSite <- reactive({
    CountyAggSF %>%
      subset(
        ReportingUnitID %in% countyFilterAllow()$ReportingUnitID
      )
  })
  
  
  ### HUC8 ###
  #Filter BenUse Table
  huc8FilterBenUse <- reactive({
    P_H8ABBUF %>%
      filter(
        BeneficialUseCV %in% input$BenUseInput
      )
  })
  #Filter AggFacts Table - Child BenUse Table
  huc8FilterAllow <- reactive({
    P_H8AAF %>%
      filter(
        AggregatedAmountID %in% huc8FilterBenUse()$AggregatedAmountID
      )
  })
  #Filter Site Table - Child AggFacts Table - Child BenUse Table
  huc8FilteredSite <- reactive({
    HUCAggSF %>%
      subset(
        ReportingUnitID %in% huc8FilterAllow()$ReportingUnitID
      )
  })
  
  
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ######## County Map ########
  
  #Base Map Creation
  output$CountyMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        minZoom = 4, 
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      )%>% 
      setView(lng = -111.40, lat = 39.50, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "County Polygon Map")  # Helps solves issue of observe({ waiting for user input before implementing.
    leafletProxy(
      mapId = "CountyMap", 
      data = countyFilteredSite()
    ) %>%
      clearShapes() %>%
      addPolygons(
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.5,
        fillColor = "Yellow",
        popup = ~paste(
          "AggregatedAmountID: ", countyFilterAllow()$AggregatedAmountID, "<br>",
          "ReportingUnitUUID: ", countyFilteredSite()$ReportingUnitUUID, "<br>",
          "County Name: ", countyFilteredSite()$NAME, "<br>",
          "State: ", countyFilteredSite()$StateCV, "<br>",
          "WBenUse: ", countyFilterBenUse()$BeneficialUseCV, "<br>",
          "ReportYear: ", countyFilterAllow()$ReportYearCV, "<br>",
          "Amount: ", countyFilterAllow()$Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', countyFilteredSite()$ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      )
  })
  
  ######## End County Map ########
  ##################################################################
  
  
  ##################################################################
  ######## HUC8 Map ########
  
  #Base Map Creation
  output$HUC8Map <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        minZoom = 4, 
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      )%>% 
      setView(lng = -111.40, lat = 39.50, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "HUC8 Polygon Map") # Helps solves issue of observe({ waiting for user input before implementing.
    leafletProxy(
      mapId = "HUC8Map", 
      data = huc8FilteredSite()
    ) %>%
      clearShapes() %>%
      addPolygons(
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.5,
        fillColor = "Green",
        popup = ~paste(
          "HUC_8: ", huc8FilteredSite()$HUC_8, "<br>",
          "ReportingUnitUUID: ", huc8FilteredSite()$ReportingUnitUUID, "<br>",
          "Unit Name: ", huc8FilteredSite()$ReportingUnitNativeID, "<br>",
          "State: ", huc8FilteredSite()$StateCV, "<br>",
          "WBenUse: ", huc8FilterBenUse()$BeneficialUseCV, "<br>",
          "ReportYear: ", huc8FilterAllow()$ReportYearCV, "<br>",
          "Amount: ", huc8FilterAllow()$Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', huc8FilteredSite()$ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      )
  })
  
  ######## End HUC8 Map ########
  ##################################################################
  
  
  
  
  ##################################################################
  ######## The Table Output ######## 
  #based off reactive map selection tool 
  
  # output$mytable <- renderDataTable({
  #     if (is.null(filteredSite()))
  #         return(NULL)
  #     DT::datatable(selectedLocations(), options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
  # })
  
  ######## End The Table Output ######## 
  ##################################################################
  
  
  
  ##################################################################
  ######## Download Button - to csv ########
  #based off reactive map selection tool 
  
  # output$download <- downloadHandler(
  #     filename = function(){"data.csv"}, 
  #     content = function(fname){write.csv(selectedLocations(), fname)
  #     }
  # )
  
  ######## End Download Button - to csv ########
  ##################################################################
  
  
  
} #endServer