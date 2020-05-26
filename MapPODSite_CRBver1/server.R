# App: MapPODSite_CRBver1

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  observe({
    #Reaction to SiteUUID Text Input Box.
    if ("" %in%  input$SiteUUIDInput)
    {SiteUUID_choice = P_dfSite$SiteUUID}
    else
    {SiteUUID_choice = input$SiteUUIDInput}
    updateTextInput(session, 'SiteUUIDInput', value = SiteUUID_choice)
  })
  
  
  
  #Reaction to Map Selection Tools
  data_of_click <- reactiveValues(clickedMarker = list()) # list to store the map selections for tracking
  selectedLocations <- reactive({
    selectedLocations <- subset(filteredSite(), SiteUUID %in% data_of_click$clickedMarker)
    selectedLocations # return this output
  })
  
  
  #Filter BenUse Table
  filterBenUse <- reactive({
    P_dfBen %>%
      filter(WBenUse %in% input$BenUseInput)
  })
  
  #Filter Allow Table - Child BenUse Table
  filterAllow <- reactive({
    P_dfAllo %>%
      filter(
        (PD >= input$DateInput[1]),
        (PD <= input$DateInput[2]),
        (AA_CFS >= input$minAA_CFS),
        (AA_CFS <= input$maxAA_CFS),
        (AA_AF >= input$minAA_AF),
        (AA_AF <= input$maxAA_AF),
        (State %in% input$StateInput),
        (SN_ID %in% filterBenUse()$SN_ID)
      )
  })
  
  #Filter Site Table - Child AllowTable - Child BenUse Table 
  filteredSite <- reactive({
    if (is.null(input$mapA_bounds))
      return(P_dfSite[FALSE,])
    
    bounds <- input$mapA_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    P_dfSite %>%
      filter(
        (Lat >= latRng[1] & Lat <= latRng[2] & Long >= lngRng[1] & Long <= lngRng[2]),
        (SiteUUID %in% unlist(strsplit(input$SiteUUIDInput, ","))),
        (SiteUUID %in% filterAllow()$SiteUUID)
      )
  })
  
  
  
  #Issue of HeatMap not responding to 'in view' filter approach.
  #Heatmap seems to cluster, so shouldn't be an issue to leave out.
  hfsdata <- reactive({
    P_dfSite %>%
      filter(
        (SiteUUID %in% unlist(strsplit(input$SiteUUIDInput, ","))),
        (SiteUUID %in% filterAllow()$SiteUUID)
      )
  })
  
  
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ######## MapA Leaflet Traditional ########
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    #Base Map
    leaflet(options = leafletOptions(minZoom = 7, preferCanvas = TRUE)) %>%
      addProviderTiles(
        # providers$Esri.WorldGrayCanvas,
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      ) %>%
      addPolygons(data = CRBasin,
                  fillColor = "green",
                  options = pathOptions(clickable = FALSE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Beneficial Use",
                pal = BenUseMapPalette,
                values = filterBenUse()$WBenUse
      ) %>%
      
      setView(lng = -108.40, lat = 40.24, zoom = 8)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Point of Diversion Site Map")  # Helps solves issue of observe({ waiting for user input before implementing.
    leafletProxy("mapA", session) %>%
      clearMarkers() %>%
      addCircleMarkers(
        # clusterOptions = markerClusterOptions(),  # maybe... want to avoid if possible
        data = filteredSite(),
        lat = ~Lat,
        lng = ~Long,
        radius = ~log(AA_CFS),
        stroke = TRUE,
        fillOpacity = 0.8,
        color = ~BenUseMapPalette(WBenUse),
        labelOptions = labelOptions(noHide = T, direction = 'auto'),
        popupOptions(autoPan = FALSE),
        popup = ~paste(
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/SitePlotApp_ver1/?SQPInput=', filteredSite()$SiteUUID, '"> Link </a>'), "<br>",
          "SiteUUID: ", filteredSite()$SiteUUID, "<br>",
          "SN_ID: ", filteredSite()$SN_ID, "<br>",
          "State: ", filteredSite()$State, "<br>",
          "AA_CFS: ", filteredSite()$AA_CFS, "<br>",
          "AA_AF: ", filteredSite()$AA_AF, "<br>",
          "PD: ", filteredSite()$PD, "<br>",
          "WSN: ", filteredSite()$WSN, "<br>",
          "WBenUse: ", filteredSite()$WBenUse, "<br>")
      ) %>%
      addDrawToolbar(
        targetGroup='Selected',
        polylineOptions=FALSE,
        markerOptions = FALSE,
        polygonOptions = drawPolygonOptions(shapeOptions=drawShapeOptions(fillOpacity = 0 ,color = 'white' ,weight = 3)),
        rectangleOptions = drawRectangleOptions(shapeOptions=drawShapeOptions(fillOpacity = 0 ,color = 'white' ,weight = 3)),
        circleOptions = drawCircleOptions(shapeOptions = drawShapeOptions(fillOpacity = 0 ,color = 'white' ,weight = 3)),
        editOptions = editToolbarOptions(edit = FALSE, selectedPathOptions = selectedPathOptions()))
  })
  
  
  #Map Selection Tools Reaction. Draw new features with selection.
  #Only add new layers for bounded locations
  observeEvent(input$mapA_draw_new_feature,{
    found_in_boundsMapA <- findLocations(shape = input$mapA_draw_new_feature,
                                         location_coordinates = coordinates,
                                         location_id_colname = "SiteUUID")
    
    for(id in found_in_boundsMapA){
      if(id %in% data_of_click$clickedMarker){
        # don't add id
      } else {
        # add id
        data_of_click$clickedMarker<-append(data_of_click$clickedMarker, id, 0)
      }
    }
    
    #Look up data by IDs found
    selectedMapA <- subset(filteredSite(), SiteUUID %in% data_of_click$clickedMarker)
    proxy <- leafletProxy("mapA")
    proxy %>% addCircles(data = selectedMapA,
                         radius = 1000,
                         lat = selectedMapA$Lat,
                         lng = selectedMapA$Long,
                         fillColor = "wheat",
                         fillOpacity = 1,
                         color = "mediumseagreen",
                         weight = 3,
                         stroke = T,
                         layerId = as.character(selectedMapA$secondLocationID),
                         highlightOptions = highlightOptions(color = "hotpink", opacity = 1.0, weight = 2, bringToFront = TRUE))
  })
  
  #Map Selection Tools Reaction. Draw new features with selection.
  #Loop through list of one or more deleted features/ polygons
  observeEvent(input$mapA_draw_deleted_features,{
    
    for(feature in input$mapA_draw_deleted_features$features) {
      
      # get ids for locations within the bounding shape
      bounded_layer_idsMapA <- findLocations(shape = feature,
                                             location_coordinates = coordinates,
                                             location_id_colname = "secondLocationID")
      
      # remove second layer representing selected locations
      proxyMapA <- leafletProxy("mapA")
      proxyMapA %>% removeShape(layerId = as.character(bounded_layer_idsMapA))
      first_layer_idsMapA <- subset(filteredSite(), secondLocationID %in% bounded_layer_idsMapA)$SiteUUID
      data_of_click$clickedMarker <- data_of_click$clickedMarker[!data_of_click$clickedMarker %in% first_layer_idsMapA]
    }
  })
  ######## End MapA Leaflet Traditional  ########
  ##################################################################
  
  
  
  ##################################################################
  ######## The Text Output ######## 
  output$textOutA <- renderUI({
    str1 <- paste("Number of POD Sites Visible: ", nrow(filteredSite()))
    str2 <- paste("Number of POD Sites Selected: ", nrow(selectedLocations()))
    HTML(paste(str1, str2, sep = '<br/>'))
  })
  
  ######## End The Text Output ######## 
  ##################################################################
  
  
  
  ##################################################################
  ######## The Table Output ######## 
  #based off reactive map selection tool 
  output$mytable <- renderDataTable({
    if (is.null(filteredSite()))
      return(NULL)
    DT::datatable(selectedLocations(), options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
  })
  ######## End The Table Output ######## 
  ##################################################################
  
  
  
  ##################################################################
  ######## Download Button - to csv ########
  #based off reactive map selection tool 
  output$download <- downloadHandler(
    filename = function(){"data.csv"}, 
    content = function(fname){write.csv(selectedLocations(), fname)
    }
  )
  ######## End Download Button - to csv ########
  ##################################################################
  
  
  
} #endServer