# App: AG Demo

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########

  ReportingUnitRec <- eventReactive(input$ApplyChangesInput, {
    ReportingUnitData[sapply(ReportingUnitData@data$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
    # ReportingUnitData[sapply(ReportingUnitData@data$WaDENameBU, function(p) {any(input$BeneficialUseInput %in% p)}), ]
    ReportingUnitData %>%
      subset(
        (State %in% input$StateInput) & (WaDENameRU %in% input$ReportingUnitTypeInput)
      )
  })
  
  
  
  ##################################################################
  ######## Map ########
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    
    # Subset of ReportingUnitData data, with custom mapping options.
    ReportingUnitDataTable <- ReportingUnitData
    ReportingUnitDataTable$polylabel <- paste(ReportingUnitDataTable$State, " : ", ReportingUnitDataTable$WaDENameRU, " : ", ReportingUnitDataTable$ReportingUnitName)
    if (input$NoRecordInput == TRUE) {ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(CountVar > 0)}
    
    # Color Scale for Map
    binpal <- colorFactor("RdYlBu", ReportingUnitDataTable$WaDENameRU)
    
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
        fillColor = ~binpal(WaDENameRU),
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
          "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/AggregatedBudgetLandingPadgeDemo?SQPInput=', ReportingUnitDataTable$ReportingUnitUUID, '", target=\"_blank\"> Link </a>'))
      )
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  observe({
    try({

      # Subset of ReportingUnitRec() data, with custom mapping options.
      ReportingUnitDataTable <- ReportingUnitRec()
      ReportingUnitDataTable$polylabel <- paste(ReportingUnitDataTable$State, " : ", ReportingUnitDataTable$WaDENameRU, " : ", ReportingUnitDataTable$ReportingUnitName)
      if (input$NoRecordInput == TRUE) {ReportingUnitDataTable <- ReportingUnitDataTable %>% subset(CountVar > 0)}

      # Color Scale for Map
      binpal <- colorFactor("RdYlBu", ReportingUnitDataTable$WaDENameRU)

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
          fillColor = ~binpal(WaDENameRU),
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
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/AggregatedBudgetLandingPadgeDemo?SQPInput=', ReportingUnitDataTable$ReportingUnitUUID, '", target=\"_blank\"> Link </a>'))
        )

    }) #end try
  }) #end Observe
  
} #endServer