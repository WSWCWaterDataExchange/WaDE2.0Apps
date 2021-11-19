# App: App 3_SiteSpecificAmounts_v3
#Notes:
# 1) Map Logic: SiteTable -> SSATable

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
  
  SiteData_v2 <- reactive({
    SiteData %>%
      filter(
        (WaterSourceTypeCV %in% input$WaterSourceTypeInput)
      )
  })
  
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  
  observe({
    
    if (input$tab_being_displayed == "Site Specific") {
      clickVal <- input$mapA_shape_click$id
      tempSiteData_v2 <- SiteData_v2() %>% subset(SiteUUID %in% clickVal)
      tempAmountsData_v2 <- AmountsData_v2() %>% filter(SiteUUID %in% tempSiteData_v2$SiteUUID)
    }
    
    #Produce subset of data and Plot from info on clickVal on map event
    if(is.null(clickVal) == TRUE) {
      
      ## Line Plots
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
      
    } else {
      
      #Line Plot A: Amount v ReportYearCV by BeneficialUseCV
      output$LP_A <- renderPlotly({
        
        #Subset of data & group by SiteUUID, ReportyearCV & BeneficialUseCV
        AmountsData_v3 <- tempAmountsData_v2 %>% group_by(BeneficialUseCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        LP_A <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                        group=~BeneficialUseCV, color=~BeneficialUseCV,
                        type='scatter', mode='lines+markers')
        LP_A <- LP_A %>% layout(title = paste0(clickVal, " (", tempSiteData_v2$PODorPOUSite, ")"),
                                xaxis = list(title="Report Year"),
                                yaxis = list(title="Water Amount (Acre-Feet)"),
                                showlegend=TRUE)
        LP_A
      })
      
      #Line Plot B: Amount v ReportYearCV by WaterSourceTypeCV
      output$LP_B <- renderPlotly({
        
        #Subset of data & group by SiteUUID, ReportyearCV & WaterSourceTypeCV
        AmountsData_v3 <- tempAmountsData_v2 %>% group_by(WaterSourceTypeCV, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        LP_B <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                        group=~WaterSourceTypeCV, color=~WaterSourceTypeCV,
                        type='scatter', mode='lines+markers')
        LP_B <- LP_B %>% layout(title = paste0(clickVal, " (", tempSiteData_v2$PODorPOUSite, ")"),
                                xaxis = list(title="Report Year"),
                                yaxis = list(title="Water Amount (Acre-Feet)"),
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
                                xaxis = list(title="Report Year"),
                                yaxis = list(title="Water Amount (Acre-Feet)"),
                                showlegend=TRUE)
        LP_C
      })
      
      #Line Plot D: Amount v ReportYearCV by CommunityWaterSupplySystem
      output$LP_D <- renderPlotly({
        
        #Subset of data & group by SiteUUID, ReportyearCV & CommunityWaterSupplySystem
        AmountsData_v3 <- tempAmountsData_v2 %>% group_by(CommunityWaterSupplySystem, SiteUUID, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        LP_D <- plot_ly(data=AmountsData_v3, x=~ReportYearCV, y=~SumAmouts,
                        group=~CommunityWaterSupplySystem, color=~CommunityWaterSupplySystem,
                        type='scatter', mode='lines+markers')
        LP_D <- LP_D %>% layout(title = paste0(clickVal, " (", tempSiteData_v2$PODorPOUSite, ")"),
                                xaxis = list(title="Report Year"),
                                yaxis = list(title="Water Amount (Acre-Feet)"),
                                showlegend=TRUE)
        LP_D
      })
      
    } #end else
  })  #end Observe
  
  ####### End Line Plots Based on Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Site Specific Map ########
  
  
  #Base Map Creation
  output$mapA <- renderLeaflet({
    #Base Map
    SiteMap = leaflet(
      options = leafletOptions(preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.WorldGrayCanvas, 
        options = providerTileOptions(
          updateWhenZooming = FALSE,      # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)           # map won't load new tiles when panning
      ) %>%
      setView(lng = -112, lat = 39, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Site Specific")  # Helps solves issue of observe waiting for user input before implementing.
    
    #### Custom functions to narrow data / add data features
    pal <- colorFactor(c("navy", "red"), domain = c("POD", "POU"))
    
    #### Create the Map
    SiteMapProxy = leafletProxy(
      mapId="mapA"
    ) %>%
      
      clearShapes() %>% # for incremental changes, clears out all original data
      
      # Add POU & POD Sites
      addCircles(
        data = SiteData_v2(),
        layerId = ~SiteUUID,
        lng = ~Longitude,
        lat = ~Latitude,
        radius = ~ifelse(PODorPOUSite == "POU", 700, 300),
        # weight = ~ifelse(PODorPOUSite == "POU", 7, 6),
        color = ~ifelse(RecordCheck == 0, "black", pal(PODorPOUSite)),
        stroke = ~ifelse(PODorPOUSite == "POU", TRUE, ifelse(WaterSourceTypeCV == "Groundwater", TRUE, FALSE)),
        opacity = ~ifelse(RecordCheck == 0, 0.1, 0.5),
        fill = ~ifelse(WaterSourceTypeCV == "Groundwater", FALSE, TRUE),
        fillColor = ~ifelse(RecordCheck == 0, "black", pal(PODorPOUSite)),
        fillOpacity = ~ifelse(RecordCheck == 0, 0.1, 0.5),
        label = ~SiteUUID,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = paste(
          "SiteUUID: ", SiteData_v2()$SiteUUID, "<br>",
          "WaterSourceTypeCV: ", SiteData_v2()$WaterSourceTypeCV, "<br>",
          "PODorPOUSite: ", SiteData_v2()$PODorPOUSite, "<br>",
          "CommunityWaterSupplySystem: ", SiteData_v2()$CommunityWaterSupplySystem, "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      
      # # Add Linkss between POUs-to-PODs.
      # # Note:
      # #   1) Using a shapefile to create polygon and treating the shapes as lines.
      # addPolygons(
      #   data = LinkDataSF,
      #   layerId = ~LinkID,
      #   color = "#444444",
      #   weight = 0.1,
      #   opacity = 1.0,
      #   fillOpacity = 0,
    #   group = "LinkID",
    #   options = pathOptions(clickable = FALSE)
    # ) %>%
    
    # Layer / Group Controls
    addLayersControl(
      overlayGroups = c("Outline", "LinkID"),
      options = layersControlOptions(collapsed = FALSE)
    ) 
    
  }) #end Observe
  
  
  #Observe Click Event, create polygon.
  observeEvent(eventExpr=input$mapA_shape_click, handlerExpr={
    
    # Filter shapefile with clickevent
    clickVal <- input$mapA_shape_click$id
    
    try({
      tempSiteData_v2 <- SiteData_v2() %>% subset(SiteUUID %in% clickVal)
      CWSSVal <- tempSiteData_v2$CommunityWaterSupplySystem
      tempSiteGroupSF <- SiteGroupSF %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      LinksSF <- LinksSF %>% subset(CommunityWaterSupplySystem %in% CWSSVal)
      
      #### Create the Map
      SiteMapProxy = leafletProxy(
        mapId="mapA"
      ) %>%
        # Clean Map
        clearGroup(group="Outline") %>%
        # Adding Outline to POU & POD Site Groups
        addPolygons(
          data = tempSiteGroupSF,
          layerId = ~CommunityWaterSupplySystem,
          stroke = TRUE,
          color = "#8600D1",
          weight = 1,
          opacity = 0.2,
          fill = TRUE,
          fillColor = "#8600D1",
          fillOpacity = 0.2,
          label = ~CommunityWaterSupplySystem,
          labelOptions = labelOptions(
            noHide = FALSE,
            textOnly = FALSE,
            textsize = "7px",
            opacity = 0.8,
            direction = 'top'),
          group = "Outline"
        ) %>%
        
        # Add Linkss between POUs-to-PODs.
        # Note:
        #   1) Using a shapefile to create polygon and treating the shapes as lines.
        addPolygons(
          data = LinksSF,
          layerId = ~LinkID,
          color = "#444444",
          weight = 0.5,
          opacity = 1.0,
          fillOpacity = 0,
          group = "LinkID",
          options = pathOptions(clickable = FALSE)
        )
      
    }) #end try
    
  })#end ObserveEvent
  
  
  ######## End Site Specific Map ########
  ##################################################################
  
} #endServer