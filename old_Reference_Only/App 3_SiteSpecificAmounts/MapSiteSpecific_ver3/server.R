# App: App 3_SiteSpecificAmounts_v3

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Custom Functions ########
  
  #N/A
  
  ####### End Custom Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Standalone Observe Functions ########
  
  #N/A
  
  ####### End Standalone Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  AmountsData_v2 <- reactive({
    AmountsData %>%
      filter()
  })
  
  SitePODData_v2 <- reactive({
    SitesPODData %>%
      filter(
        (WaterSourceTypeCV %in% input$WaterSourceTypeInput)
      )
  })
  
  wr_SiteData_v2 <- reactive({
    wr_SiteData %>%
      filter()
  })
  
  PolyPOUSF_v2 <- reactive({
    PolyPOUSF %>%
      subset(
        (WaterSourceTypeCV %in% input$WaterSourceTypeInput)
      )
  })
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  
  observe({
    
    ## Blank Plots
    output$LP_A <- renderPlotly({
      LP_A <- plot_ly(type='scatter', mode='lines+markers')
      LP_A <- LP_A %>% layout(title = paste0("Please Make a Selection"),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      LP_A
    })
    
    output$LP_B <- renderPlotly({
      LP_B <- plot_ly(type='scatter', mode='lines+markers')
      LP_B <- LP_B %>% layout(title = paste0("Please Make a Selection"),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      LP_B
    })
    
    output$LP_C <- renderPlotly({
      LP_C <- plot_ly(type='scatter', mode='lines+markers')
      LP_C <- LP_C %>% layout(title = paste0("Please Make a Selection"),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      LP_C
    })
    
    output$LP_D <- renderPlotly({
      LP_D <- plot_ly(type='scatter', mode='lines+markers')
      LP_D <- LP_D %>% layout(title = paste0("Please Make a Selection"),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      LP_D
    })
    
    ## Pie Charts
    output$PC_A <- renderPlotly({
      PC_A <- plot_ly(type='scatter', mode='lines+markers')
      PC_A <- PC_A %>% layout(title = paste0("Nothing to show at this time..."),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      PC_A
    })
    
    output$PC_B <- renderPlotly({
      PC_B <- plot_ly(type='scatter', mode='lines+markers')
      PC_B <- PC_B %>% layout(title = paste0("Nothing to show at this time..."),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      PC_B
    })
    
    output$PC_C <- renderPlotly({
      PC_C <- plot_ly(type='scatter', mode='lines+markers')
      PC_C <- PC_C %>% layout(title = paste0("Nothing to show at this time..."),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      PC_C
    })
    
    output$PC_D <- renderPlotly({
      PC_D <- PC_D(type='scatter', mode='lines+markers')
      PC_D <- PC_D %>% layout(title = paste0("Nothing to show at this time..."),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      PC_D
    })
    
  }) #end Observe
  
  
  #Observe Click Event - Click Marker
  observeEvent(eventExpr=input$mapA_marker_click, handlerExpr={
    
    # Filter shapefile with clickEvent
    clickVal <- input$mapA_marker_click$id
    tempSiteData_v2 <- SitePODData_v2() %>% subset(SiteUUID %in% clickVal)
    CWSSVal <- tempSiteData_v2$CommunityWaterSupplySystem
    tempAmountsData_v2 <- AmountsData_v2() %>% filter(SiteUUID %in% tempSiteData_v2$SiteUUID)
    
    #Line Plot A: Amount v ReportYearCV by BeneficialUseCV
    output$LP_A <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & BeneficialUseCV
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(BeneficialUseCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_A <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                      group=~BeneficialUseCV, color=~BeneficialUseCV,
                      type='scatter', mode='lines+markers')
      LP_A <- LP_A %>% layout(title = paste0(clickVal, " (", tempSiteData_v2$PODorPOUSite, ")"),
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_A
    })
    
    #Line Plot B: Amount v ReportYearCV by PODorPOUSite per CommunityWaterSupplySystem
    output$LP_B <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & CommunityWaterSupplySystem
      tempAmountsData_v2 <- AmountsData_v2() %>% subset(BeneficialUseCV %in% "DCII")
      tempAmountsData_v2 <- tempAmountsData_v2 %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(CommunityWaterSupplySystem, PODorPOUSite, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_B <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts, 
                      group=~PODorPOUSite, color=~PODorPOUSite,
                      type='scatter', mode='lines+markers')
      LP_B <- LP_B %>% layout(title = CWSSVal,
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_B
    })
    
    #Line Plot C: Amount v ReportYearCV by VariableSpecificCV
    output$LP_C <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & VariableSpecificCV
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(VariableSpecificCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_C <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                      group=~VariableSpecificCV, color=~VariableSpecificCV,
                      type='scatter', mode='lines+markers')
      LP_C <- LP_C %>% layout(title = paste0(clickVal, " (", tempSiteData_v2$PODorPOUSite, ")"),
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_C
    })
    
    #Line Plot D: Amount v ReportYearCV by SiteUUId per CommunityWaterSupplySystem
    output$LP_D <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & CommunityWaterSupplySystem
      tempAmountsData_v2 <- AmountsData_v2() %>% subset(BeneficialUseCV %in% "DCII")
      tempAmountsData_v2 <- tempAmountsData_v2 %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(CommunityWaterSupplySystem, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_D <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts, 
                      group=~SiteUUID, color=~SiteUUID,
                      type='scatter', mode='lines+markers')
      LP_D <- LP_D %>% layout(title = CWSSVal,
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_D
    })
    
  }) #end ObserveEvent
  
  
  #Observe Click Event - Click Shape
  observeEvent(eventExpr=input$mapA_shape_click, handlerExpr={
    
    # Filter shapefile with clickEvent
    clickVal <- input$mapA_shape_click$id
    tempPolyPOUSF_v2 <- PolyPOUSF_v2() %>% subset(SiteUUID %in% clickVal)
    CWSSVal <- tempPolyPOUSF_v2$CommunityWaterSupplySystem
    tempAmountsData_v2 <- AmountsData_v2() %>% filter(SiteUUID %in% tempPolyPOUSF_v2$SiteUUID)
    
    #Line Plot A: Amount v ReportYearCV by BeneficialUseCV
    output$LP_A <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & BeneficialUseCV
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(BeneficialUseCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_A <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                      group=~BeneficialUseCV, color=~BeneficialUseCV,
                      type='scatter', mode='lines+markers')
      LP_A <- LP_A %>% layout(title = paste0(clickVal, " (", tempPolyPOUSF_v2$PODorPOUSite, ")"),
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_A
    })
    
    #Line Plot B: Amount v ReportYearCV by PODorPOUSite per CommunityWaterSupplySystem
    output$LP_B <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & CommunityWaterSupplySystem
      tempAmountsData_v2 <- AmountsData_v2() %>% subset(BeneficialUseCV %in% "DCII")
      tempAmountsData_v2 <- tempAmountsData_v2 %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(CommunityWaterSupplySystem, PODorPOUSite, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_B <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts, 
                      group=~PODorPOUSite, color=~PODorPOUSite,
                      type='scatter', mode='lines+markers')
      LP_B <- LP_B %>% layout(title = CWSSVal,
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_B
    })
    
    #Line Plot C: Amount v ReportYearCV by VariableSpecificCV
    output$LP_C <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & VariableSpecificCV
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(VariableSpecificCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_C <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                      group=~VariableSpecificCV, color=~VariableSpecificCV,
                      type='scatter', mode='lines+markers')
      LP_C <- LP_C %>% layout(title = paste0(clickVal, " (", tempPolyPOUSF_v2$PODorPOUSite, ")"),
                              paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_C
    })
    
    #Line Plot D: Amount v ReportYearCV by SiteUUId per CommunityWaterSupplySystem
    output$LP_D <- renderPlotly({
      
      #Subset of data & group by SiteUUID, ReportyearCV & CommunityWaterSupplySystem
      tempAmountsData_v2 <- AmountsData_v2() %>% subset(BeneficialUseCV %in% "DCII")
      tempAmountsData_v2 <- tempAmountsData_v2 %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      AmountsData_v3 <- tempAmountsData_v2 %>% group_by(CommunityWaterSupplySystem, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
      
      #The Plot
      LP_D <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts, 
                      group=~SiteUUID, color=~SiteUUID,
                      type='scatter', mode='lines+markers')
      LP_D <- LP_D %>% layout(title = CWSSVal,
                              xaxis = list(title="Report Year"),
                              yaxis = list(title="Water Amount (Gallons)"),
                              showlegend=TRUE)
      LP_D
    })
    
  }) #end ObserveEvent
  
  ####### End Line Plots Based on Observe Functions ########
  ##################################################################
  
  
  
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
      
      # Set starting view / zoom level
      setView(lng = -112, lat = 39, zoom = 7) %>%
      
      # Legend - using an image.
      addLegendImage(
        images = LegendImage,
        labels = "",
        width = 250,
        height = 200,
        position = 'bottomright',
        orientation = 'horizontal')
    
  }) #end renderLeaflet
  
  
  #Incremental Changes to the Map / Responses to filters
  observe({
    
    # print(input$mapA_zoom)  
    
    # Require Tab Name - Helps solves issue of observe waiting for user input before implementing.
    req(input$tab_being_displayed == "Site Specific")
    
    try({
      
      # Subset of PolyPOUSF_v2() data, with custom mapping options.
      polydatatable <- PolyPOUSF_v2()
      if (input$NoRecordInput == TRUE) {polydatatable <- polydatatable %>% subset(RecordCheck == 1)}
      polydatatable$polyColor  <- ifelse(polydatatable$RecordCheck == 0, "black", "red")
      polydatatable$polyOpacity  <- ifelse(polydatatable$RecordCheck == 0, 0.1, 0.5)
      polydatatable$polylabel  <- paste(polydatatable$SiteUUID, " : ", 
                                        polydatatable$CommunityWaterSupplySystem)
      
      # Subset of SitePODData_v2() data, with custom mapping options.
      sitedatatable <- SitePODData_v2()
      if (input$NoRecordInput == TRUE) {sitedatatable <- sitedatatable %>% subset(RecordCheck == 1)}
      sitedatatable$markColor  <- ifelse(sitedatatable$RecordCheck == 0, "black", ifelse(sitedatatable$WaterSourceTypeCV == "Groundwater", "purple", "navy"))
      sitedatatable$markOpacity  <- ifelse(sitedatatable$RecordCheck == 0, 0.1, 0.5)
      sitedatatable$markFill  <- ifelse(sitedatatable$WaterSourceTypeCV == "Groundwater", FALSE, TRUE)
      sitedatatable$markFillColor  <- ifelse(sitedatatable$RecordCheck == 0, "black", ifelse(sitedatatable$WaterSourceTypeCV == "Groundwater", "purple", "navy"))
      sitedatatable$markFillOpacity  <- ifelse(sitedatatable$RecordCheck == 0, 0.1, 0.5)
      sitedatatable$marklabel  <- paste(sitedatatable$SiteUUID, " : ", 
                                        sitedatatable$CommunityWaterSupplySystem)
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean the Map
        clearMarkers() %>%
        
        # Add POU Polygons
        addPolygons(
          data = polydatatable,
          layerId = ~SiteUUID,
          color = ~polyColor,
          opacity = ~polyOpacity,
          label = ~polylabel,
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>WaDE Site ID: </b>", PolyPOUSF$SiteUUID, "<br>",
            "<b>Water Source Type: </b>", PolyPOUSF$WaterSourceTypeCV, "<br>",
            "<b>Site Designation: </b>", PolyPOUSF$PODorPOUSite, "<br>",
            "<b>Supply System Name: </b>", PolyPOUSF$CommunityWaterSupplySystem, "<br>")) %>%
        
        # Add POD Sites
        addCircleMarkers(
          data = sitedatatable,
          layerId = ~SiteUUID,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 4,
          color = ~markColor,
          opacity = ~markOpacity,
          fill = ~markFill,
          fillColor = ~markFillColor,
          fillOpacity = ~markFillOpacity,
          label = ~marklabel,
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          popup = paste(
            "<b>WaDE Site ID: </b>", SitePODData_v2()$SiteUUID, "<br>",
            "<b>Water Source Type: </b>", SitePODData_v2()$WaterSourceTypeCV, "<br>",
            "<b>Site Designation: </b>", SitePODData_v2()$PODorPOUSite, "<br>",
            "<b>Supply System Name: </b>", SitePODData_v2()$CommunityWaterSupplySystem, "<br>")
        ) %>%
        
        # Add WR Sites
        addRectangles(
          data = wr_SiteData_v2(),
          layerId = ~SiteUUID,
          lng1 = ~(Longitude - 0.0001),
          lng2 = ~(Longitude + 0.0001),
          lat1 = ~(Latitude - 0.0001),
          lat2 = ~(Latitude + 0.0001),
          color = "green",
          label = ~SiteUUID,
          group = "WaterRightSites",
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top')
        ) %>%
        
        # Add Linkss between POUs-to-PODs
        addPolygons(
          data = LinksSF,
          layerId = ~LinkID,
          color = "Yellow",
          weight = 0.5,
          opacity = 1.0,
          fillOpacity = 0,
          group = "Site Connections",
          options = pathOptions(clickable = FALSE)) %>%
        
        # Layer / Group Controls
        addLayersControl(
          overlayGroups = c("Site Connections", "WaterRightSites"),
          options = layersControlOptions(collapsed = FALSE)) %>%
        
        # Hide Layer / Group Controls Upon Launch
        hideGroup(c("Site Connections", "WaterRightSites"))
      
    }) #end try
  }) #end Observe
  
  
  #Observe Click Event - Click Marker - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_marker_click, handlerExpr={
    
    # Custom function for coloring ss sites
    pal <- colorFactor(c("navy", "red"), domain = c("POD", "POU"))
    
    # Filter shapefile with clickEvent
    clickVal <- input$mapA_marker_click$id
    
    try({
      
      # Retrieve / Create CWSSVal value from SS site click.
      tempSiteData_v2 <- SitePODData_v2() %>% subset(SiteUUID %in% clickVal)
      CWSSVal <- tempSiteData_v2$CommunityWaterSupplySystem
      if (CWSSVal == "NULL") {CWSSVal <- ""} # prevents NULL sites from being highlighted / created.
      
      # Subset of LinksSF data that = CWSSVal.
      LinksSF <- LinksSF %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("HighlightSites", "LinkID", "Outline")) %>%
        
        # Add Links between POUs-to-PODs.
        addPolygons(
          data = LinksSF,
          layerId = ~LinkID,
          color = "#444444",
          weight = 0.3,
          opacity = 0.6,
          group = "LinkID",
          options = pathOptions(clickable = FALSE))
      
    }) #end try
  }) #end ObserveEvent
  
  
  #Observe Click Event - Click Shape - create links, highlight sites, water right sites, & group polygons.
  observeEvent(eventExpr=input$mapA_shape_click, handlerExpr={
    
    # Custom function for coloring ss sites
    pal <- colorFactor(c("navy", "red"), domain = c("POD", "POU"))
    
    # Filter shapefile with clickEvent
    clickVal <- input$mapA_shape_click$id
    
    try({
      
      # Retrieve / Create CWSSVal value from SS site click.
      tempPolyPOUSF_v2 <- PolyPOUSF_v2() %>% subset(SiteUUID %in% clickVal)
      CWSSVal <- tempPolyPOUSF_v2$CommunityWaterSupplySystem
      if (CWSSVal == "NULL") {CWSSVal <- ""} # prevents NULL sites from being highlighted / created.
      
      # Subset of LinksSF data that = CWSSVal.
      LinksSF <- LinksSF %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      
      # Call the Map
      SiteMapProxy = leafletProxy(mapId="mapA") %>%
        
        # Clean Map
        clearGroup(group=c("HighlightSites", "WaterRightSites", "LinkID", "Outline")) %>%
        
        # Add Links between POUs-to-PODs.
        addPolygons(
          data = LinksSF,
          layerId = ~LinkID,
          color = "Yellow",
          weight = 0.5,
          opacity = 0.6,
          group = "LinkID",
          options = pathOptions(clickable = FALSE))
      
    }) #end try
  }) #end ObserveEvent
  
  ######## End Site Specific Map ########
  ##################################################################
  
} #endServer