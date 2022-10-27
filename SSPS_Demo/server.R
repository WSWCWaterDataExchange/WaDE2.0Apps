# App: SSPS Demo

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  AmountsDataReac <- reactive({
    amountData
  })
  
  sitesPODRec <- reactive({
    sitesPOD %>%
      subset(
        (State %in% input$StateInput)
      )
    sitesPOD[sapply(sitesPOD$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
  })
  
  polyPOURec <- reactive({
    polyPOU %>%
      subset(
        (State %in% input$StateInput)
      )
    polyPOU[sapply(polyPOU@data$WaDENameWS, function(p) {any(input$WaterSourceTypeInput %in% p)}), ]
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
        width = 200,
        height = 300,
        position = 'bottomright',
        orientation = 'horizontal')
    
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  observe({
    try({
      
      # Subset of polyPOURec() data, with custom mapping options.
      polyDataTable <- polyPOURec()
      if (input$NoRecordInput == TRUE) {polyDataTable <- polyDataTable %>% subset(CountVar > 0)}
      polyDataTable$polyOpacity  <- ifelse(polyDataTable$CountVar > 0, 0.1, 1.0)
      polyDataTable$polylabel  <- paste(polyDataTable$SiteNativeID, " : ", polyDataTable$CommunityWaterSupplySystem)
      
      # Subset of sitesPODRec() data, with custom mapping options.
      siteDataTable <- sitesPODRec()
      if (input$NoRecordInput == TRUE) {siteDataTable <- siteDataTable %>% subset(CountVar > 0)}
      siteDataTable$siteLabel  <- paste(siteDataTable$SiteNativeID, " : ", siteDataTable$CommunityWaterSupplySystem)
      
      # Color Scale for Map
      pal <- colorNumeric(palette=colorList, domain=binList)
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("PODSite_A", "SitePoly_A")) %>%
        
        # Add POU Polygons
        addPolygons(
          data = polyDataTable,
          layerId = ~SiteUUID,
          stroke = TRUE,
          color = "black",
          weight = 1,
          opacity = 0.5,
          fill = TRUE,
          fillColor = ~pal(CountVar),
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
            "<b>Community Water Supply System:</b>", polyDataTable$CommunityWaterSupplySystem, "<br>",
            "<b>Varaible Type:</b>", polyDataTable$VariableCV, "<br>",
            "<b>Additional Info:</b>", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', polyDataTable$SiteUUID, '"> Link </a>'), "<br>")
          ) %>%
        
        # Add POD Sites
        addCircleMarkers(
          data = siteDataTable,
          layerId = ~SiteUUID,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 2,
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
            "<b>Community Water Supply System:</b>", siteDataTable$CommunityWaterSupplySystem, "<br>",
            "<b>Varaible Type:</b>", siteDataTable$VariableCV, "<br>",
          "<b>Additional Info:</b>", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/SiteSpecificLandingPadgeDemo?SQPInput=', siteDataTable$SiteUUID, '"> Link </a>'), "<br>"))
    }) #end try
  }) #end Observe
  
  
  # Observe Click Event - Click Shape - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_shape_click, handlerExpr={
    try({
      clickVal <- input$mapA_shape_click$id
      tempSiteDataReac <- polyPOURec() %>% subset(SiteUUID %in% clickVal)
      CWSSVal <- tempSiteDataReac$CommunityWaterSupplySystem
      if (CWSSVal == "NULL") {CWSSVal <- ""} # prevents NULL sites from being highlighted / created.
      createHeighlightMapFunc(clickVal, CWSSVal)
    }) #end try
  }) #end ObserveEvent
  
  
  # Observe Click Event - Click marker - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_marker_click, handlerExpr={
    try({
      clickVal <- input$mapA_marker_click$id
      tempSiteData_v2 <- sitesPODRec() %>% subset(SiteUUID %in% clickVal)
      CWSSVal <- tempSiteData_v2$CommunityWaterSupplySystem
      if (CWSSVal == "NULL") {CWSSVal <- ""} # prevents NULL sites from being highlighted / created.
      createHeighlightMapFunc(clickVal, CWSSVal)
    }) #end try
  }) #end ObserveEvent
  
  
  # Create Heighlight Area and Points Function
  createHeighlightMapFunc <- function(clickVal, CWSSVal) {
    
    # # Subset of LinksSF data that = CWSSVal.
    # LinksSF <- LinksSF %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
    
    # Subset of polyPOURec() data, with custom mapping options.
    polydatatable <- polyPOURec()
    polydatatable <- polydatatable %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
    if (input$NoRecordInput == TRUE) {polydatatable <- polydatatable %>% subset(RecordCheck == 1)}
    
    # Subset of sitesPODRec() data, with custom mapping options.
    sitedatatable <- sitesPODRec()
    sitedatatable <- sitedatatable %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
    if (input$NoRecordInput == TRUE) {sitedatatable <- sitedatatable %>% subset(RecordCheck == 1)}
    
    # Call the Map
    SiteMapProxy = leafletProxy(mapId="mapA") %>%
      
      # Clean Map
      clearGroup(group=c("LinkToSites", "HighlightPoly", "HighlightSite")) %>%
      
      # # Add Linkss between POUs-to-PODs
      # addPolygons(
      #   data = LinksSF,
      #   # layerId = ~LinkID,
      #   color = "Yellow",
      #   weight = 0.5,
      #   opacity = 1.0,
      #   fillOpacity = 0,
      #   group = "LinkToSites",
      #   options = pathOptions(clickable = FALSE)) %>%
    
    # Add POU Polygons
    addPolygons(
      data = polydatatable,
      # layerId = ~SiteUUID,
      color = "Yellow",
      opacity = 0.1,
      group = "HighlightPoly",
      options = pathOptions(clickable = FALSE)) %>%
      
      # Add POD Sites
      addCircleMarkers(
        data = sitedatatable,
        # layerId = ~SiteUUID,
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 4,
        color = "Yellow",
        opacity = 0.2,
        group = "HighlightSite",
        options = pathOptions(clickable = FALSE))
    
    return(SiteMapProxy)
  }
  
} #endServer