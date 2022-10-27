# App: MapRegulatoryAreas_ver1a

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Custom Functions ########
  
  #N/A
  
  ####### Custom Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Standalone Observe Functions ########
  
  ####### End Standalone Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  #For Empty Plots before Mouse Selection
  emptydataRec <- reactive({
    EmptyTable
  })
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  observe({
    
    # #Site Specific
    # if (input$tab_being_displayed == "Site Specific") {
    #   click <- input$SiteSAMap_marker_click$id
    #   tempSiteTable <- SiteTable %>% subset(SiteUUID %in% click)
    #   tempSSATable <- SSATable %>% filter(SiteUUID %in% tempSiteTable$SiteUUID)
    # }
    # 
    # 
    # #Produce subset of data and Plot from info on click on map event
    # if(is.null(click) == TRUE) {
    #   
    #   output$LP_A <- renderPlotly({
    #     #Display Empty plot until mouse click selection
    #     # validate(
    #     #   need(nrow(emptydataRec()) > 0, 'No selection. Please select a Reporting Unit')
    #     # )
    #     plot_ly(emptydataRec(), x = ~ReportYearCV, y = ~Amount)
    #     
    #   })
    #   
    # } else {
    #   
    #   #Plot Amount v ReportYearCV
    #   output$LP_A <- renderPlotly({
    #     
    #     #Subset of data & group by ReportyearCV
    #     finalSSA_WS <- tempSSATable %>% group_by(ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
    #     
    #     #The Plot
    #     LPA <- ggplot(data=finalSSA_WS, aes(x=ReportYearCV, y=SumAmouts)) +
    #       geom_line(show.legend = FALSE) +
    #       geom_point(show.legend = FALSE) +
    #       ggtitle(paste("Site Specific WaDE 2.0 ID: ",click)) +
    #       scale_x_continuous(breaks = seq(round(min(finalSSA_WS$ReportYearCV), digits =0),
    #                                       round(max(finalSSA_WS$ReportYearCV), digits =0),
    #                                       round(sqrt(max(finalSSA_WS$ReportYearCV) - min(finalSSA_WS$ReportYearCV)), digits =0))) +
    #       scale_y_continuous(labels = scales::comma) +
    #       labs(x="Report Year", y="Wtihdrawl Annual Water Use (Acre-Feet)") +
    #       theme(legend.title = element_blank(), legend.text = element_text(size = 8),
    #             plot.title = element_text(hjust = 0.5, size = 8),
    #             panel.background = element_blank(),
    #             axis.title.y=element_text(size = 10), axis.text.y=element_text(size = 8), axis.line.y = element_line(size = 1),
    #             axis.title.x=element_text(size = 10), axis.text.x=element_text(size = 8), axis.line.x = element_line(size = 1),
    #             plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
    #     
    #     ggplotly(LPA) %>%
    #       layout(legend = list(orientation = "h", xanchor = "center", x = 0.5, y = -0.3))
    #     
    #   })
    # }
    
  })
  
  ####### End County Plots Based on Observe Functions s ########
  ##################################################################
  
  
  
  ##################################################################
  ######## RegA Map ########
  
  #Base Map Creation
  output$RegAMap <- renderLeaflet({
    
    a = providers$Esri.DeLorme
    
    leaflet(
      options = leafletOptions(preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        provider = providers$Esri.OceanBasemap,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE,  # map won't load new tiles when panning
          maxZoom = 20) 
      ) %>%
      setView(lng = -102.00, lat = 37.00, zoom = 5)
  })
  
  #Incremental Changes to the Map
  observe({
    
    #Filtering Shapefile based on User Inputs
    RegDataShapeFilter <- subset(RegDataShape,
               (State %in% input$StateInput) & (BoundaryTy %in% input$BoundaryTypeInput)
          )

    #Create the Map
    leafletProxy(
      mapId = "RegAMap"
    ) %>%
      clearShapes() %>%
      addProviderTiles(
        provider = input$basemapInput,
      ) %>%
      addPolygons(
        data = RegDataShapeFilter,
        layerId = ~AreaName,
        label = ~AreaName,
        color = "#444444",
        weight = 2,
        opacity = 1.0,
        fillOpacity = 0.2,
        popup = ~paste(
          "AreaUUID", AreaUUID, "<br>",
          "State: ", State, "<br>",
          "Area Name: ", AreaName, "<br>",
          "Boundary Type : ", BoundaryTy, "<br>")
      )
  })
  
  
  ######## End RegA Map ########
  ##################################################################
  
  
  
  
} #endServer