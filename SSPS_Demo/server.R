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
  
  # HUC12Rec <- reactive({
  #   HUC12File
  # })
  
  
  
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
        overlayGroups = c("POD Site", "POU Polygon", "HUC12"),
        baseGroups = c("WorldGrayCanvas", "WorldStreetMap", "DeLorme", "WorldTopoMap", "WorldImagery"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      
      hideGroup("HUC12") %>%
      
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
      polyDataTable <- polyDataTable %>% subset(minPopulationServed >= input$PopulationServedSliderInput[1] | is.na(minPopulationServed))
      polyDataTable <- polyDataTable %>% subset(maxPopulationServed <= input$PopulationServedSliderInput[2] | is.na(maxPopulationServed))
      polyDataTable$polyOpacity  <- ifelse(polyDataTable$CountVar > 0, 0.1, 1.0)
      polyDataTable$polylabel  <- paste0(polyDataTable$SiteName," : ", polyDataTable$SiteNativeID)
      
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
      siteDataTable <- siteDataTable %>% filter((minPopulationServed >= input$PopulationServedSliderInput[1] | is.na(minPopulationServed)), (maxPopulationServed <= input$PopulationServedSliderInput[2] | is.na(maxPopulationServed)))
      siteDataTable$siteLabel  <- paste0(siteDataTable$SiteName, " : ", siteDataTable$SiteNativeID)
      
      # Search for Site Name Filter
      # Due to order of operations, this has to come after the sapply() filters, as sapply() cannot accept an empty list.
      if (input$SiteNameInput != "") {
        polyDataTable <- polyDataTable %>% subset((SiteName == input$SiteNameInput))
        siteDataTable <- siteDataTable %>% subset((SiteName == input$SiteNameInput))
      }
      
      
      # # HUC12 Polygon Data
      # if (input$NoRecordInput == TRUE) {HUC12Rec() <- sitedatatable %>% subset(RecordCheck == 1)}
      
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("POD Site", "POU Polygon", 'LinkToSites')) %>%
        
        # hideGroup("HUC12") %>%
        
        # Add HUC12 Polygons
        addPolygons(
          data = HUC12File,
          stroke = TRUE,
          color = "black",
          weight = 1,
          fill = F,
          group = "HUC12",
          options = pathOptions(clickable = FALSE)
        ) %>%
        
        # Add Polygons
        addPolygons(
          data = polyDataTable,
          layerId = ~SiteUUID,
          group = "POU Polygon",
          stroke = TRUE,
          color = ~HasLinksColor,
          weight = 1.2,
          opacity = 0.7,
          fill = TRUE,
          fillColor = "#DC3220",
          fillOpacity = 0.8,
          label = ~polylabel,
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
            "<b>Min Population Served:</b>", polyDataTable$minPopulationServed, "<br>",
            "<b>Max Population Served:</b>", polyDataTable$maxPopulationServed, "<br>",
            "<b>Time Step:</b>", polyDataTable$TimeStep, "<br>",
            "<b>Min Time Frame:</b>", polyDataTable$minTimeFrameStart, "<br>",
            "<b>Max Time Frame:</b>", polyDataTable$maxTimeFrameEnd, "<br>",
            "<b>Additional Info:</b>", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', polyDataTable$SiteUUID, '", target=\"_blank\"> Link </a>'))
        ) %>%
        
        # Add Sites
        addCircleMarkers(
          data = siteDataTable,
          layerId = ~SiteUUID,
          group = "POD Site",
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 4,
          stroke = TRUE,
          color = ~HasLinksColor,
          weight = 0.7,
          opacity = 1,
          fill = TRUE,
          fillColor = "#005AB5",
          fillOpacity = 1.0,
          label = ~siteLabel,
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          clusterOptions = markerClusterOptions(
            maxClusterRadius = 0.01,
            iconCreateFunction = JS("function (cluster) {
            var childCount = cluster.getChildCount();
            c = 'rgba(39, 50, 245, 0.8);'
            var size = 1/100;
            return new L.DivIcon({ 
              html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', 
              className: 'marker-cluster', 
              iconSize: new L.Point(size, size) 
            });
            }")
          ),
          popup = paste(
            "<b>Native Site ID:</b>", siteDataTable$SiteNativeID, "<br>",
            "<b>WaDE Site ID:</b>", siteDataTable$SiteUUID, "<br>",
            "<b>Site Name:</b>", siteDataTable$SiteName, "<br>",
            "<b>Site Type:</b>", siteDataTable$WaDENameS, "<br>",
            "<b>Water Source Type:</b>", siteDataTable$WaDENameWS, "<br>",
            "<b>Beneficial Use:</b>", siteDataTable$WaDENameBU, "<br>",
            "<b>Variable Data Type:</b>", siteDataTable$WaDENameV, "<br>",
            "<b>Min Population Served:</b>", siteDataTable$minPopulationServed, "<br>",
            "<b>Max Population Served:</b>", siteDataTable$maxPopulationServed, "<br>",
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
    
    # Call the Map
    SiteMapProxy = leafletProxy(mapId="mapA") %>%
      
      # Clean Map
      clearGroup(group=c("LinkToSites")) %>%
      
      # Add Links between Sites
      addPolygons(
        # data = linkTable,
        group = "LinkToSites",
        data = createlinkTableFunc(clickVal),
        color = "limegreen",
        weight = 1.0,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE))
    
    return(SiteMapProxy)
  } #end createHeighlightMapFunc
  
  
  # Create Data Functions
  ###################################################
  createlinkTableFunc <- function(clickVal) {
    # Subset of LinksSF data that = CWSSVal.
    linkTable <- linkFile %>% subset(SiteUUID %in% clickVal)
    linkTable <- linkTable[sapply(linkTable$WaDENameS, function(p) {any(input$SiteTypeInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameBU, function(p) {any(input$BenUseInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$WaDENameV, function(p) {any(input$VariableCVInput %in% p)}), ]
    linkTable <- linkTable[sapply(linkTable$TimeStep, function(p) {any(input$TimeStepInput %in% p)}), ]
    linkTable <- linkTable %>% subset((State %in% input$StateInput))
    linkTable <- linkTable %>% subset(minTimeFrameStart >= input$ReportYearSliderInput[1] | is.na(minTimeFrameStart))
    linkTable <- linkTable %>% subset(maxTimeFrameEnd <= input$ReportYearSliderInput[2] | is.na(maxTimeFrameEnd))
    linkTable <- linkTable %>% subset(minPopulationServed >= input$PopulationServedSliderInput[1] | is.na(minPopulationServed))
    linkTable <- linkTable %>% subset(maxPopulationServed <= input$PopulationServedSliderInput[2] | is.na(maxPopulationServed))
    return(linkTable)
  } #end createlinkTableFunc
  
  
} #endServer