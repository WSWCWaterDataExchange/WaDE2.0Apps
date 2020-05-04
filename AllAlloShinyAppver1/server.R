################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  observe({
    #Reaction to Benuse Input Box & 'Select All' Option.
    if ("Select All" %in% input$BenUseInput)
    {BenUseList_choices = BenUseList[-1]}
    else
    {BenUseList_choices = input$BenUseInput}
    updateSelectInput(session, 'BenUseInput', choices = BenUseList, selected = BenUseList_choices)
    
    #Reaction to State Input Box & 'Select All' Option.
    if ("Select All" %in% input$StateInput)
    {StateList_choices = StateList[-1]}
    else
    {StateList_choices = input$StateInput}
    updateSelectInput(session, 'StateInput', choices = StateList, selected = StateList_choices)
  })
  
  
  #Reaction to Map Selection Tools
  data_of_click <- reactiveValues(clickedMarker = list()) # list to store the map selections for tracking
  selectedLocations <- reactive({
    selectedLocations <- subset(filtered(), AA_ID %in% data_of_click$clickedMarker)
    selectedLocations # return this output
  })
  
  
  #MapA Mapdeck - Mapdeck doesn't like the 'Select All' Option in either inputs.
  #Resulting Data Set due Input Controls
  mapdeckfiltered <- reactive({
    FileIn %>%
      filter(
        (PD >= input$DateInput[1]), 
        (PD <= input$DateInput[2])
        # (WBenUse %in% input$BenUseInput),
        # (State %in% input$StateInput)
      )
    
  })
  
  
  #MapB Leaflet.mapboxgl
  #Resulting Data Set due to 1) Map Bounds & 2) Input Controls
  filtered <- reactive({
    if (is.null(input$mapB_bounds))
      return(FileIn[FALSE,])
    
    bounds <- input$mapB_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    FileIn %>%
      filter(
        (Lat >= latRng[1] & Lat <= latRng[2] & Long >= lngRng[1] & Long <= lngRng[2]),
        (PD >= input$DateInput[1]), 
        (PD <= input$DateInput[2]),
        (WBenUse %in% input$BenUseInput),
        (State %in% input$StateInput)
      )
  })
  
  #MapC Leaflet Traditonal
  #Resulting Data Set due to 1) Map Bounds & 2) Input Controls
  filteredmapC <- reactive({
    if (is.null(input$mapC_bounds))
      return(FileIn[FALSE,])
    
    bounds <- input$mapC_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    FileIn %>%
      filter(
        (Lat >= latRng[1] & Lat <= latRng[2] & Long >= lngRng[1] & Long <= lngRng[2]),
        (PD >= input$DateInput[1]), 
        (PD <= input$DateInput[2]),
        (WBenUse %in% input$BenUseInput),
        (State %in% input$StateInput)
      )
  })
  
  ####### End Reactive Data Sets ########
  ##################################################################



  
  ##################################################################
  ######## MapA MapdecOuput ########
  output$mapA <- renderMapdeck({
    mapdeck(
      token = access_token,
      style = mapdeck_style('dark'),
      location = c(-111.9349, 40.27901),
      zoom = 3)
    
  })
  
  observeEvent({is.null(mapdeckfiltered())},{
    if (is.null(mapdeckfiltered())) {
      mapdeck(style = mapdeck_style('dark'))
    } else {
      mapdeck_update(map_id = 'mapA') %>%
        add_scatterplot(
          data = mapdeckfiltered(),
          lat = "Lat",
          lon = "Long",
          fill_colour = "WBenUse",
          radius = 1500,
          update_view = FALSE)
    }
  })
  
  ######## End MapA MapdecOuput ########
  ##################################################################


  ##################################################################
  ######## MapB Leaflet.mapboxgl ########
  
  ######## PlotA Output - Flow CFS ########
  output$barplotA <- renderPlot({
    if (is.null(filtered()))
      return(NULL)
    
    if (length(data_of_click$clickedMarker) == 0) {
      plotinput = filtered()
    } else {
      plotinput = selectedLocations()
    }
    ggplot(plotinput, aes(x = WBenUse, y = sum(AA_CFS), fill = WBenUse)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(y="Sum of Selected Features Flow (CFS)", x = "Beneficial Use Type") +
      ggtitle("Allowcation Flow (CFS)") +
      scale_fill_manual(values = BenUseColorsList) +
      scale_y_continuous(expand = c(0, 0)) +
      theme(plot.title = element_text(hjust = 0.5, size = 16.0),
            axis.title.y = element_text(siz=12), axis.text.y = element_text(size=12), axis.line.y = element_blank(),
            axis.title.x = element_text(siz=12), axis.text.x = element_text(size=12), axis.line.x = element_blank(),
            panel.border = element_rect(colour = "black", fill=NA, size=1),
            panel.background = element_rect(fill = "grey92", colour = NA), axis.line = element_line(size = 1),
            plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
  })
  
  ####### PlotB Output - Volume AF ########
  output$barplotB <- renderPlot({
    if (is.null(filtered()))
      return(NULL)
    
    if (length(data_of_click$clickedMarker) == 0) {
      plotinput = filtered()
      plotinput
    } else {
      plotinput = selectedLocations()
      plotinput
    }
    ggplot(plotinput, aes(x = WBenUse, y = sum(AA_AF), fill = WBenUse)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(y="Sum of Selected Features Volume (AF)", x = "Beneficial Use Type") +
      ggtitle("Allocation Volume (AF)") +
      scale_fill_manual(values = BenUseColorsList) +
      scale_y_continuous(expand = c(0, 0)) +
      theme(plot.title = element_text(hjust = 0.5, size = 16.0),
            axis.title.y = element_text(siz=12), axis.text.y = element_text(size=12), axis.line.y = element_blank(),
            axis.title.x = element_text(siz=12), axis.text.x = element_text(size=12), axis.line.x = element_blank(),
            panel.border = element_rect(colour = "black", fill=NA, size=1),
            panel.background = element_rect(fill = "grey92", colour = NA), axis.line = element_line(size = 1),
            plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
  })
  
  #Base Map Creation
  output$mapB <- renderLeaflet({
    #Base Map
    leaflet(options = leafletOptions(minZoom = 8)) %>%
      addMapboxGL(
        accessToken = access_token,
        style = style_url
      ) %>%
      setView(lng = -111.9349, lat = 40.27901, zoom = 8)
  })
  
  
  #Incremental Changes to the Map
  observe({
    leafletProxy("mapB", data = filtered()) %>%
      clearShapes() %>%
      addCircles(
        # lng = ~Long, 
        # lat = ~Lat,
        # radius = 200,
        layerId = ~AA_ID,
        stroke = FALSE,
        opacity = 0,
        fillOpacity = 0,
        color = ~BenUseMapPalette(WBenUse),
        labelOptions = labelOptions(noHide = T, direction = 'auto'),
        popup = paste(
          "AllocationAmountID: ", filtered()$AA_ID, "<br>",
          "SiteUUID: ", filtered()$SiteUUID, "<br>",
          "State: ", filtered()$State, "<br>",
          "NativeID: ", filtered()$SN_ID, "<br>",
          "AllowedAllocationFlowCFS: ", filtered()$AA_CFS, "<br>",
          "AllowedAllocationVolumeAF: ", filtered()$AA_AF, "<br>",
          "AllocationMaxLimitVolumeAF: ", filtered()$AAM_AF, "<br>",
          "PriorityDate: ", filtered()$PD, "<br>",
          "BenUse: ", filtered()$WBenUse, "<br>",
          "Link: ", filtered()$APILink, "<br>")) %>%
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
  observeEvent(input$mapB_draw_new_feature,{
    found_in_boundsMapB <- findLocations(shape = input$mapB_draw_new_feature, 
                                     location_coordinates = coordinates, 
                                     location_id_colname = "AA_ID")
    
    for(id in found_in_boundsMapB){
      if(id %in% data_of_click$clickedMarker){
        # don't add id
      } else {
        # add id
        data_of_click$clickedMarker<-append(data_of_click$clickedMarker, id, 0)
      }
    }
    
    #Look up data by IDs found
    selected <- subset(filtered(), AA_ID %in% data_of_click$clickedMarker)
    proxy <- leafletProxy("mapB")
    proxy %>% addCircles(data = selected,
                         radius = 1000,
                         lat = selected$Lat,
                         lng = selected$Long,
                         fillColor = "wheat",
                         fillOpacity = 1,
                         color = "mediumseagreen",
                         weight = 3,
                         stroke = T,
                         layerId = as.character(selected$secondLocationID),
                         highlightOptions = highlightOptions(color = "hotpink", opacity = 1.0, weight = 2, bringToFront = TRUE))
  })
  
  #Map Selection Tools Reaction. Draw new features with selection.
  #Loop through list of one or more deleted features/ polygons
  observeEvent(input$mapB_draw_deleted_features,{
    
    for(feature in input$mapB_draw_deleted_features$features) {
      
      # get ids for locations within the bounding shape
      bounded_layer_ids <- findLocations(shape = feature, 
                                         location_coordinates = coordinates, 
                                         location_id_colname = "secondLocationID")
      
      # remove second layer representing selected locations
      proxy <- leafletProxy("mapB")
      proxy %>% removeShape(layerId = as.character(bounded_layer_ids))
      first_layer_ids <- subset(filtered(), secondLocationID %in% bounded_layer_ids)$AA_ID
      data_of_click$clickedMarker <- data_of_click$clickedMarker[!data_of_click$clickedMarker %in% first_layer_ids]
    }
  })
  ######## End MapB Leaflet.mapboxgl ########
  ##################################################################

  
  ##################################################################
  ######## MapC Leaflet Traditional ########
  
  ######## PlotC Output - Flow CFS ########
  output$barplotC <- renderPlot({
    if (is.null(filteredmapC()))
      return(NULL)
    
    if (length(data_of_click$clickedMarker) == 0) {
      plotinput = filteredmapC()
    } else {
      plotinput = selectedLocations()
    }
    ggplot(plotinput, aes(x = WBenUse, y = sum(AA_CFS), fill = WBenUse)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(y="Sum of Selected Features Flow (CFS)", x = "Beneficial Use Type") +
      ggtitle("Allowcation Flow (CFS)") +
      scale_fill_manual(values = BenUseColorsList) +
      scale_y_continuous(expand = c(0, 0)) +
      theme(plot.title = element_text(hjust = 0.5, size = 16.0),
            axis.title.y = element_text(siz=12), axis.text.y = element_text(size=12), axis.line.y = element_blank(),
            axis.title.x = element_text(siz=12), axis.text.x = element_text(size=12), axis.line.x = element_blank(),
            panel.border = element_rect(colour = "black", fill=NA, size=1),
            panel.background = element_rect(fill = "grey92", colour = NA), axis.line = element_line(size = 1),
            plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
  })
  
  ####### PlotD Output - Volume AF ########
  output$barplotD <- renderPlot({
    if (is.null(filteredmapC()))
      return(NULL)
    
    if (length(data_of_click$clickedMarker) == 0) {
      plotinput = filteredmapC()
      return(plotinput)
    } else {
      plotinput = selectedLocations()
      return(plotinput)
    }
    ggplot(plotinput, aes(x = WBenUse, y = sum(AA_AF), fill = WBenUse)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(y="Sum of Selected Features Volume (AF)", x = "Beneficial Use Type") +
      ggtitle("Allocation Volume (AF)") +
      scale_fill_manual(values = BenUseColorsList) +
      scale_y_continuous(expand = c(0, 0)) +
      theme(plot.title = element_text(hjust = 0.5, size = 16.0),
            axis.title.y = element_text(siz=12), axis.text.y = element_text(size=12), axis.line.y = element_blank(),
            axis.title.x = element_text(siz=12), axis.text.x = element_text(size=12), axis.line.x = element_blank(),
            panel.border = element_rect(colour = "black", fill=NA, size=1),
            panel.background = element_rect(fill = "grey92", colour = NA), axis.line = element_line(size = 1),
            plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
  })
  
  #Base Map Creation
  output$mapC <- renderLeaflet({
    #Base Map
    leaflet(options = leafletOptions(minZoom = 7, preferCanvas = TRUE)) %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas, options = providerTileOptions(
        updateWhenZooming = FALSE,      # map won't update tiles until zoom is done
        updateWhenIdle = TRUE           # map won't load new tiles when panning
      )) %>%
      setView(lng = -111.9349, lat = 40.27901, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    leafletProxy("mapC", data = filteredmapC()) %>%
      clearShapes() %>%
      addCircles(
        lat = ~Lat,
        lng = ~Long,
        radius = 1500,
        layerId = ~AA_ID,
        stroke = FALSE,
        fillOpacity = 0.4,
        color = ~BenUseMapPalette(WBenUse),
        labelOptions = labelOptions(noHide = T, direction = 'auto'),
        popup = paste(
          "AllocationAmountID: ", filteredmapC()$AA_ID, "<br>",
          "SiteUUID: ", filteredmapC()$SiteUUID, "<br>",
          "State: ", filteredmapC()$State, "<br>",
          "NativeID: ", filteredmapC()$SN_ID, "<br>",
          "AllowedAllocationFlowCFS: ", filteredmapC()$AA_CFS, "<br>",
          "AllowedAllocationVolumeAF: ", filteredmapC()$AA_AF, "<br>",
          "AllocationMaxLimitVolumeAF: ", filteredmapC()$AAM_AF, "<br>",
          "PriorityDate: ", filteredmapC()$PD, "<br>",
          "BenUse: ", filteredmapC()$WBenUse, "<br>",
          "Link: ", filteredmapC()$APILink, "<br>")) %>%
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
  observeEvent(input$mapC_draw_new_feature,{
    found_in_boundsMapC <- findLocations(shape = input$mapC_draw_new_feature, 
                                     location_coordinates = coordinates, 
                                     location_id_colname = "AA_ID")
    
    for(id in found_in_boundsMapC){
      if(id %in% data_of_click$clickedMarker){
        # don't add id
      } else {
        # add id
        data_of_click$clickedMarker<-append(data_of_click$clickedMarker, id, 0)
      }
    }
    
    #Look up data by IDs found
    selectedMapC <- subset(filteredmapC(), AA_ID %in% data_of_click$clickedMarker)
    proxy <- leafletProxy("mapC")
    proxy %>% addCircles(data = selectedMapC,
                         radius = 1000,
                         lat = selectedMapC$Lat,
                         lng = selectedMapC$Long,
                         fillColor = "wheat",
                         fillOpacity = 1,
                         color = "mediumseagreen",
                         weight = 3,
                         stroke = T,
                         layerId = as.character(selectedMapC$secondLocationID),
                         highlightOptions = highlightOptions(color = "hotpink", opacity = 1.0, weight = 2, bringToFront = TRUE))
  })
  
  #Map Selection Tools Reaction. Draw new features with selection.
  #Loop through list of one or more deleted features/ polygons
  observeEvent(input$mapC_draw_deleted_features,{
    
    for(feature in input$mapC_draw_deleted_features$features) {
      
      # get ids for locations within the bounding shape
      bounded_layer_idsMapC <- findLocations(shape = feature, 
                                         location_coordinates = coordinates, 
                                         location_id_colname = "secondLocationID")
      
      # remove second layer representing selected locations
      proxyMapC <- leafletProxy("mapC")
      proxyMapC %>% removeShape(layerId = as.character(bounded_layer_idsMapC))
      first_layer_idsMapC <- subset(filtered(), secondLocationID %in% bounded_layer_idsMapC)$AA_ID
      data_of_click$clickedMarker <- data_of_click$clickedMarker[!data_of_click$clickedMarker %in% first_layer_idsMapC]
    }
  })
  ######## End MapC Leaflet Traditional  ########
  ##################################################################
  
  
  
  ##################################################################
  ######## The Table Output ######## 
  #based off reactive map selection tool 
  output$mytable <- renderDataTable({
    if (is.null(filtered()))
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