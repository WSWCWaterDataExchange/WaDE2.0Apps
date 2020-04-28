################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ######################################################
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
  
  
  #Resulting Data Set due to 1) Map Bounds & 2) Input Controls
  filtered <- reactive({
    if (is.null(input$mapA_bounds))
      return(FileIn[FALSE,])
    
    bounds <- input$mapA_bounds
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
  

  
  
  ######################################################
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
  
  ######################################################
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
  
  
  
  ######################################################
  ######## The Map Ouput with Interactive Tools ########
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    # if (is.null(filtered()))
    #   return(NULL)
    
    #Base Map
    leaflet(options = leafletOptions(minZoom = 8)) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -111.9349, lat = 40.27901, zoom = 8)
  })
  
  
  #Incremental Changes to the Map
  observe({
    leafletProxy("mapA", data = filtered()) %>%
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
  observeEvent(input$mapA_draw_new_feature,{
    found_in_bounds <- findLocations(shape = input$mapA_draw_new_feature, 
                                     location_coordinates = coordinates, 
                                     location_id_colname = "AA_ID")
    
    for(id in found_in_bounds){
      if(id %in% data_of_click$clickedMarker){
        # don't add id
      } else {
        # add id
        data_of_click$clickedMarker<-append(data_of_click$clickedMarker, id, 0)
      }
    }
    
    #Look up data by IDs found
    selected <- subset(filtered(), AA_ID %in% data_of_click$clickedMarker)
    proxy <- leafletProxy("mapA")
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
  observeEvent(input$mapA_draw_deleted_features,{
    
    for(feature in input$mapA_draw_deleted_features$features) {
      
      # get ids for locations within the bounding shape
      bounded_layer_ids <- findLocations(shape = feature, 
                                         location_coordinates = coordinates, 
                                         location_id_colname = "secondLocationID")
      
      # remove second layer representing selected locations
      proxy <- leafletProxy("mapA")
      proxy %>% removeShape(layerId = as.character(bounded_layer_ids))
      first_layer_ids <- subset(filtered(), secondLocationID %in% bounded_layer_ids)$AA_ID
      data_of_click$clickedMarker <- data_of_click$clickedMarker[!data_of_click$clickedMarker %in% first_layer_ids]
    }
  })
  
  
  ######################################################
  ######## The Table Output ######## 
  #based off reactive map selection tool 
  output$mytable <- renderDataTable({
    if (is.null(filtered()))
      return(NULL)
    DT::datatable(selectedLocations(), options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
  })
  
  
  ######################################################
  ######## Download Button - to csv ########
  #based off reactive map selection tool 
  output$download <- downloadHandler(
    filename = function(){"data.csv"}, 
    content = function(fname){write.csv(selectedLocations(), fname)
    }
  )
  
  
} #endServer