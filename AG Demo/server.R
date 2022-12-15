# App: AG Demo

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########

  ReportingUnitRec <- reactive({
    ReportingUnitData
  })
  
  
  
  ##################################################################
  ######## Map ########
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    
    # Subset of ReportingUnitData data, with custom mapping options.
    ReportingUnitDataTable <- ReportingUnitData
    ReportingUnitDataTable$polylabel <- paste(ReportingUnitDataTable$State, " : ", ReportingUnitDataTable$WaDENameRU, " : ", ReportingUnitDataTable$ReportingUnitName)
    
    # # Color Scale for Map
    # binpal <- colorFactor("RdYlBu", ReportingUnitDataTable$WaDENameRU)
    
    # Create the Base Map
    AgMap = leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      
      # Add tile layer upon launch
      addProviderTiles(
        providers$Esri.WorldGrayCanvas,
        options = providerTileOptions(
          updateWhenZooming = FALSE, # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)) %>% # map won't load new tiles when panning
      
      # Extra Provider Tiles to choose from
      addProviderTiles(provider=providers$Esri.WorldGrayCanvas, group="WorldGrayCanvas") %>%
      addProviderTiles(provider=providers$Esri.WorldStreetMap, group="WorldStreetMap") %>%
      addProviderTiles(provider=providers$Esri.DeLorme, group="DeLorme") %>%
      addProviderTiles(provider=providers$Esri.WorldTopoMap, group="WorldTopoMap") %>%
      addProviderTiles(provider=providers$Esri.WorldImagery, group="WorldImagery") %>%
      addLayersControl(
        baseGroups = c("WorldGrayCanvas", "WorldStreetMap", "DeLorme", "WorldTopoMap", "WorldImagery"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      
      # Set starting view / zoom level
      setView(lng = -98.0, lat = 35.0, zoom = 5) %>%
      
      # Legend - using an image.
      addLegendImage(
        images = LegendImage,
        labels = "",
        width = 220,
        height = 200,
        position = 'bottomright',
        orientation = 'horizontal') %>%
      
      # Clean Map
      clearGroup(group=c("AgPoly_A")) %>%
      
      # Add POU Polygons
      addPolygons(
        data = ReportingUnitDataTable,
        layerId = ~ReportingUnitUUID,
        stroke = TRUE,
        color = "black",
        weight = 1,
        opacity = 0.5,
        fill = TRUE,
        # fillColor = ~binpal(WaDENameRU),
        fillColor = ~polyColor,
        fillOpacity = 0.5,
        label = ~polylabel,
        group = "AgPoly_A",
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = paste(
          "<b>Native Area ID:</b>", ReportingUnitDataTable$ReportingUnitNativeID, "<br>",
          "<b>WaDE Area ID:</b>", ReportingUnitDataTable$ReportingUnitUUID, "<br>",
          "<b>Area Name:</b>", ReportingUnitDataTable$ReportingUnitName, "<br>",
          "<b>Area Type:</b>", ReportingUnitDataTable$WaDENameRU, "<br>",
          "<b>Water Source Type:</b>", ReportingUnitDataTable$WaDENameWS, "<br>",
          "<b>Varaible Type:</b>", ReportingUnitDataTable$VariableCV, "<br>",
          "<b>Time Step:</b>", ReportingUnitDataTable$TimeStep, "<br>",
          "<b>Min Time Frame:</b>", ReportingUnitDataTable$minTimeFrameStart, "<br>",
          "<b>Max Time Frame:</b>", ReportingUnitDataTable$maxTimeFrameEnd, "<br>",
          "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/AggregatedBudgetLandingPadgeDemo?SQPInput=', ReportingUnitDataTable$ReportingUnitUUID, '", target=\"_blank\"> Link </a>'))
      )
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  # observe({
  observeEvent(input$ApplyChangesInput, {
    try({

      # Subset of ReportingUnitRec() data, with custom mapping options.
      ReportingUnitDataTable <- ReportingUnitRec()
      ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(State %in% input$StateInput)
      ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(WaDENameRU %in% input$ReportingUnitTypeInput)
      ReportingUnitDataTable <- ReportingUnitDataTable[sapply(ReportingUnitDataTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
      ReportingUnitDataTable <- ReportingUnitDataTable[sapply(ReportingUnitDataTable$WaDENameBU, function(p) {any(input$BenUseInput %in% p)}), ]
      ReportingUnitDataTable <- ReportingUnitDataTable[sapply(ReportingUnitDataTable$WaDENameV, function(p) {any(input$VariableCVInput %in% p)}), ]
      ReportingUnitDataTable <- ReportingUnitDataTable[sapply(ReportingUnitDataTable$TimeStep, function(p) {any(input$TimeStepInput %in% p)}), ]
      ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(minTimeFrameStart >= input$ReportYearSliderInput[1] | is.na(minTimeFrameStart))
      ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(maxTimeFrameEnd <= input$ReportYearSliderInput[2] | is.na(maxTimeFrameEnd))
      ReportingUnitDataTable$polylabel <- paste(ReportingUnitDataTable$State, " : ", ReportingUnitDataTable$WaDENameRU, " : ", ReportingUnitDataTable$ReportingUnitName)

      # Call the Map
      AgMapProxy = leafletProxy(mapId="mapA") %>%

        # Clean Map
        clearGroup(group=c("AgPoly_A")) %>%

        # Add POU Polygons
        addPolygons(
          data = ReportingUnitDataTable,
          layerId = ~ReportingUnitUUID,
          stroke = TRUE,
          color = "black",
          weight = 1,
          opacity = 0.5,
          fill = TRUE,
          # fillColor = ~binpal(WaDENameRU),
          fillColor = ~polyColor,
          fillOpacity = 0.5,
          label = ~polylabel,
          group = "AgPoly_A",
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>Native Area ID:</b>", ReportingUnitDataTable$ReportingUnitNativeID, "<br>",
            "<b>WaDE Area ID:</b>", ReportingUnitDataTable$ReportingUnitUUID, "<br>",
            "<b>Area Name:</b>", ReportingUnitDataTable$ReportingUnitName, "<br>",
            "<b>Area Type:</b>", ReportingUnitDataTable$WaDENameRU, "<br>",
            "<b>Water Source Type:</b>", ReportingUnitDataTable$WaDENameWS, "<br>",
            "<b>Varaible Type:</b>", ReportingUnitDataTable$VariableCV, "<br>",
            "<b>Time Step:</b>", ReportingUnitDataTable$TimeStep, "<br>",
            "<b>Min Time Frame:</b>", ReportingUnitDataTable$minTimeFrameStart, "<br>",
            "<b>Max Time Frame:</b>", ReportingUnitDataTable$maxTimeFrameEnd, "<br>",
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/AggregatedBudgetLandingPadgeDemo?SQPInput=', ReportingUnitDataTable$ReportingUnitUUID, '", target=\"_blank\"> Link </a>'))
        )

    }) #end try
  }) #end Observe
  
} #endServer