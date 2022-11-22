# App: SSRG Demo

#################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  sitesRec <- reactive({
    sites
  })
  
  
  
  ##################################################################
  ######## Site Specific Map ########
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    
    # Create the Base Map
    SiteMap = leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      
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
      setView(lng = -98.0, lat = 41.0, zoom = 5) %>%
      
      # Legend - using an image.
      addLegendImage(
        images = LegendImage,
        labels = "",
        width = 200,
        height = 200,
        position = 'bottomright',
        orientation = 'horizontal')
    
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  observe({
    try({
      
      # Subset of sitesRec() data, with custom mapping options.
      siteDataTable <- sitesRec()
      if (input$NoRecordInput == TRUE) {siteDataTable <- siteDataTable %>% subset(CountVar > 0)}
      siteDataTable <- siteDataTable[sapply(siteDataTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
      siteDataTable <- siteDataTable %>% subset((State %in% input$StateInput))
      siteDataTable <- siteDataTable %>% filter(minTimeFrameStart >= input$sliderInput[1], maxTimeFrameEnd <= input$sliderInput[2], na.rm = TRUE)
      siteDataTable$siteLabel  <- siteDataTable$SiteNativeID
      siteDataTable$markColor <- ifelse(siteDataTable$WaDENameWS == "Surface Water", "Navy", ifelse(siteDataTable$WaDENameWS == "Groundwater", "Purple", "#BFBFBF"))
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("Site_A")) %>%
        
        # Add POD Sites
        addCircleMarkers(
          data = siteDataTable,
          layerId = ~SiteUUID,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 2,
          color = ~markColor,
          group = "Site_A",
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>Native Site ID:</b>", siteDataTable$SiteNativeID, "<br>",
            "<b>State:</b>", siteDataTable$State, "<br>",
            "<b>WaDE Site ID:</b>", siteDataTable$SiteUUID, "<br>",
            "<b>Site Name:</b>", siteDataTable$SiteName, "<br>",
            "<b>Site Type:</b>", siteDataTable$WaDENameS, "<br>",
            "<b>Water Source Type:</b>", siteDataTable$WaDENameWS, "<br>",
            "<b>Time Step:</b>", siteDataTable$AggregationIntervalUnitCV, "<br>",
            "<b>Min Time Frame:</b>", siteDataTable$minTimeFrameStart, "<br>",
            "<b>Max Time Frame:</b>", siteDataTable$maxTimeFrameEnd, "<br>",
            "<b>Varaible Type:</b>", siteDataTable$VariableCV, "<br>",
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', siteDataTable$SiteUUID, '", target=\"_blank\"> Link </a>'))
        )
    }) #end try
  }) #end Observe
  
} #endServer