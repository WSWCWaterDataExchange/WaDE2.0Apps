# App: App 3_SiteSpecificAmounts_v1
#Notes:
# 1) Map Logic: Site -> SSATable

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
    
    #Site Specific
    if (input$tab_being_displayed == "Site Specific") {
      clickVal <- input$SiteSAMap_marker_click$id
      tempSiteTable <- SiteTable %>% subset(SiteUUID %in% clickVal)
      tempSSATable <- SSATable %>% filter(SiteUUID %in% tempSiteTable$SiteUUID)
    }
    
    
    #Produce subset of data and Plot from info on click on map event
    # if(is.null(click) == TRUE) {
    if(is.null(clickVal) == TRUE) {
      
      output$LP_A <- renderPlotly({
        figLP_A <- plot_ly(emptydataRec(), type='scatter')
        figLP_A <- figLP_A %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figLP_A
      })
      
    } else {
      
      #Line Plot A: Amount v ReportYearCV by BeneficialUseCV
      output$LP_A <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & BeneficialUseCV
        finalAFF_Ben <- tempPAggTable %>% group_by(BeneficialUseCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figLP_A <- plot_ly(data=finalAFF_Ben, x=~ReportYearCV, y=~SumAmouts, 
                           group=~BeneficialUseCV, color=~BeneficialUseCV, 
                           type='scatter', mode='lines+markers')
        figLP_A <- figLP_A %>% layout(xaxis = list(title="Report Year"), yaxis = list(title="Annual Water Use (Acre-Feet)"))
        figLP_A
      })
    }
    
  })
  
  ####### End County Plots Based on Observe Functions s ########
  ##################################################################
  
  
  
  ##################################################################
  ######## County Map ########
  
  #Base Map Creation
  output$SiteSAMap <- renderLeaflet({
    
    a = providers$Esri.DeLorme
    
    leaflet(
      options = leafletOptions(preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        # provider = input$backgroundInput,
        provider = providers$Esri.OceanBasemap,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE,  # map won't load new tiles when panning
          maxZoom = 20)  #issue of leaflet failing to load if zoomed too far in...
      ) %>%
      setView(lng = -112.00, lat = 39.00, zoom = 6)
  })
  
  #Incremental Changes to the Map
  observe({
    
    # #Map Color Palette
    # pal <- colorNumeric(palette = "Blues", domain = WaterServiceAreasSF$WRENAME)
    
    #Create the Map
    leafletProxy(
      mapId = "SiteSAMap"
    ) %>%
      addProviderTiles(
        provider = input$basemapInput,
      ) %>%
      addPolygons(
        data = WaterServiceAreasSF,
        layerId = ~WRID,
        color = "#444444",
        # fillColor = ~pal(WRENAME),
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0.2,
        label = ~WRENAME
      ) %>%
      addCircleMarkers(
        data = SiteTable,
        layerId = ~SiteUUID,
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 3,
        popup = ~paste(
          "SiteUUID", SiteUUID, "<br>",
          "SiteNativeID: ", SiteNativeID, "<br>",
          "SiteName: ", SiteName, "<br>",
          "SiteTypeCV : ", SiteTypeCV, "<br>",
          "County Use : ", County, "<br>",
          "WaterSourceName :", WaterSourceName, "<br>",
          "WaterSourceTypeCV :", WaterSourceTypeCV, "<br>",
          "WaterSourceNativeID :", WaterSourceNativeID)
      )
  })
  
  
  
  ######## End County Map ########
  ##################################################################
  
} #endServer