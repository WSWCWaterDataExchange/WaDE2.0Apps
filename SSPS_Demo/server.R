# App: SSPS Demo

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  # note: filters working better when building a subset below with single values & vectors
  sitesRec <- reactive({
    sitesFile
  })
  
  polyRec <- reactive({
    polyFile
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
      setView(lng = -98.0, lat = 35.0, zoom = 5) %>%
      
      # Legend - using an image.
      addLegendImage(
        images = LegendImage,
        labels = "",
        width = 220,
        height = 140,
        position = 'bottomright',
        orientation = 'horizontal')
    
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  observe({
    try({
      
      # Subset of polyRec() data, with custom mapping options.
      polyDataTable <- polyRec()
      polyDataTable <- polyDataTable[sapply(polyDataTable$WaDENameS, function(p) {any(input$SiteTypeInput %in% p)}), ]
      polyDataTable <- polyDataTable[sapply(polyDataTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
      polyDataTable <- polyDataTable[sapply(polyDataTable$WaDENameBU, function(p) {any(input$BenUseInput %in% p)}), ]
      polyDataTable <- polyDataTable[sapply(polyDataTable$WaDENameV, function(p) {any(input$VariableCVInput %in% p)}), ]
      polyDataTable <- polyDataTable[sapply(polyDataTable$TimeStep, function(p) {any(input$TimeStepInput %in% p)}), ]
      polyDataTable <- polyDataTable %>% subset((State %in% input$StateInput))
      polyDataTable <- polyDataTable %>% subset(minTimeFrameStart >= input$ReportYearSliderInput[1] | is.na(minTimeFrameStart))
      polyDataTable <- polyDataTable %>% subset(maxTimeFrameEnd <= input$ReportYearSliderInput[2] | is.na(maxTimeFrameEnd))
      polyDataTable$polyOpacity  <- ifelse(polyDataTable$CountVar > 0, 0.1, 1.0)
      polyDataTable$polylabel  <- polyDataTable$SiteNativeID

      # Subset of sitesRec() data, with custom mapping options.
      siteDataTable <- sitesRec()
      siteDataTable <- siteDataTable[sapply(siteDataTable$WaDENameS, function(p) {any(input$SiteTypeInput %in% p)}), ]
      siteDataTable <- siteDataTable[sapply(siteDataTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
      siteDataTable <- siteDataTable[sapply(siteDataTable$WaDENameBU, function(p) {any(input$BenUseInput %in% p)}), ]
      siteDataTable <- siteDataTable[sapply(siteDataTable$WaDENameV, function(p) {any(input$VariableCVInput %in% p)}), ]
      siteDataTable <- siteDataTable[sapply(siteDataTable$TimeStep, function(p) {any(input$TimeStepInput %in% p)}), ]
      siteDataTable <- siteDataTable %>% subset((State %in% input$StateInput))
      siteDataTable <- siteDataTable %>% subset((VariableCV %in% input$VariableCVInput))
      siteDataTable <- siteDataTable %>% filter((minTimeFrameStart >= input$ReportYearSliderInput[1] | is.na(minTimeFrameStart)), (maxTimeFrameEnd <= input$ReportYearSliderInput[2] | is.na(maxTimeFrameEnd)))
      siteDataTable$siteLabel  <- siteDataTable$SiteNativeID
      
      # issue of flilter and min max PopulationServed list
      #siteDataTable <- siteDataTable[sapply(siteDataTable$PopulationServed, function(p) {any(input$PopulationServedSliderInput[1] %in% p)}), ]
      #siteDataTable <- siteDataTable[sapply(siteDataTable$PopulationServed, function(p) {any(input$PopulationServedSliderInput[2] %in% p)}), ]
      #siteDataTable <- siteDataTable[sapply(siteDataTable$PopulationServed, function(p) {filter((siteDataTable %>% PopulationServed >= input$PopulationServedSliderInput[1] | is.na(PopulationServed)), (PopulationServed <= input$PopulationServedSliderInput[2] | is.na(PopulationServed))) %in% p}), ]


      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("PODSite_A", "SitePoly_A", 'LinkToSites')) %>%
        
        # Add Polygons
        addPolygons(
          data = polyDataTable,
          layerId = ~SiteUUID,
          stroke = TRUE,
          color = "black",
          weight = 1,
          opacity = 0.5,
          fill = TRUE,
          fillColor = "#DC3220",
          fillOpacity = 1.0,
          label = ~polylabel,
          group = "SitePoly_A",
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>Native Site ID:</b>", polyDataTable$SiteNativeID, "<br>",
            "<b>WaDE Site ID:</b>", polyDataTable$SiteUUID, "<br>",
            "<b>Site Name:</b>", polyDataTable$SiteName, "<br>",
            "<b>Site Type:</b>", polyDataTable$WaDENameS, "<br>",
            "<b>Water Source Type:</b>", polyDataTable$WaDENameWS, "<br>",
            "<b>Beneficial Use:</b>", polyDataTable$WaDENameBU, "<br>",
            "<b>Variable Data Type:</b>", polyDataTable$WaDENameV, "<br>",
            "<b>Population Served:</b>", polyDataTable$PopulationServed, "<br>",
            "<b>Time Step:</b>", polyDataTable$TimeStep, "<br>",
            "<b>Min Time Frame:</b>", polyDataTable$minTimeFrameStart, "<br>",
            "<b>Max Time Frame:</b>", polyDataTable$maxTimeFrameEnd, "<br>",
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', polyDataTable$SiteUUID, '", target=\"_blank\"> Link </a>'))
        ) %>%
        
        # Add Sites
        addCircleMarkers(
          data = siteDataTable,
          layerId = ~SiteUUID,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 2,
          color = "#005AB5",
          group = "PODSite_A",
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>Native Site ID:</b>", siteDataTable$SiteNativeID, "<br>",
            "<b>WaDE Site ID:</b>", siteDataTable$SiteUUID, "<br>",
            "<b>Site Name:</b>", siteDataTable$SiteName, "<br>",
            "<b>Site Type:</b>", siteDataTable$WaDENameS, "<br>",
            "<b>Water Source Type:</b>", siteDataTable$WaDENameWS, "<br>",
            "<b>Beneficial Use:</b>", siteDataTable$WaDENameBU, "<br>",
            "<b>Variable Data Type:</b>", siteDataTable$WaDENameV, "<br>",
            "<b>Population Served:</b>", siteDataTable$PopulationServed, "<br>",
            "<b>Time Step:</b>", siteDataTable$TimeStep, "<br>",
            "<b>Min Time Frame:</b>", siteDataTable$minTimeFrameStart, "<br>",
            "<b>Max Time Frame:</b>", siteDataTable$maxTimeFrameEnd, "<br>",
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', siteDataTable$SiteUUID, '", target=\"_blank\"> Link </a>'))
        )
    }) #end try
  }) #end Observe
  
  
  # Observe Click Event - Click Shape - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_shape_click, handlerExpr={
    try({
      clickVal <- input$mapA_shape_click$id
      if (clickVal == "NULL") {clickVal <- ""} # prevents NULL sites from being highlighted / created.
      createHeighlightMapFunc(clickVal)
    }) #end try
  }) #end ObserveEvent
  
  
  # Observe Click Event - Click marker - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_marker_click, handlerExpr={
    try({
      clickVal <- input$mapA_marker_click$id
      if (clickVal == "NULL") {clickVal <- ""} # prevents NULL sites from being highlighted / created.
      createHeighlightMapFunc(clickVal)
    }) #end try
  }) #end ObserveEvent
  
  
  # Create Heighlight Area and Points Function
  createHeighlightMapFunc <- function(clickVal) {
    
    # # Subset of LinksSF data that = CWSSVal.
    linkTable <- linkFile %>% subset(SiteUUID %in% clickVal)
    linkTable <- linkTable[sapply(linkTable$WaDENameS, function(p) {any(input$SiteTypeInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameBU, function(p) {any(input$BenUseInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameV, function(p) {any(input$VariableCVInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$TimeStep, function(p) {any(input$TimeStepInput %in% p)}), ]
    linkTable <- linkTable %>% subset((State %in% input$StateInput))
    linkTable <- linkTable %>% subset(minTimeFrameStart >= input$ReportYearSliderInput[1] | is.na(minTimeFrameStart))
    linkTable <- linkTable %>% subset(maxTimeFrameEnd <= input$ReportYearSliderInput[2] | is.na(maxTimeFrameEnd))
    
    # Call the Map
    SiteMapProxy = leafletProxy(mapId="mapA") %>%
      
      # Clean Map
      clearGroup(group=c("LinkToSites")) %>%
      
      # Add Linkss between POUs-to-PODs
      addPolygons(
        data = linkTable,
        color = "Yellow",
        weight = 0.5,
        opacity = 1.0,
        fillOpacity = 0,
        group = "LinkToSites",
        options = pathOptions(clickable = FALSE))
    
    return(SiteMapProxy)
  }
  
} #endServer