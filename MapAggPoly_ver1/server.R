# App: MapAggPoly_ver1

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Custom Functions ########
  
  # ### Amounts Color Palette ###
  # palA <- colorNumeric(palette = "YlOrRd", domain = AAF$Amount)
  
  
  ####### Custom Functions ########
  ##################################################################
  
  ##################################################################
  ####### Standalone Observe Functions ########
  
  #Change Report Year Slider to Default Value depending on tab
  observe({
    if (input$tab_being_displayed == "County Reporting Unit")
    {ReportYear_Tab = '2008'}
    else
    {ReportYear_Tab = input$ReportYearInput}
    updateSliderInput(session, 'ReportYearInput', value = ReportYear_Tab)
  })
  
  observe({
    if (input$tab_being_displayed == "HUC8 Reporting Unit")
    {ReportYear_Tab = '2005'}
    else
    {ReportYear_Tab = input$ReportYearInput}
    updateSliderInput(session, 'ReportYearInput', value = ReportYear_Tab)
  })
  
  observe({
    if (input$tab_being_displayed == "Basin Reporting Unit")
    {ReportYear_Tab = '2004'}
    else
    {ReportYear_Tab = input$ReportYearInput}
    updateSliderInput(session, 'ReportYearInput', value = ReportYear_Tab)
  })
  
  
  
  ####### End Standalone Observe Functions ########
  ##################################################################
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  #For Empty Plots before Mouse Selection
  emptydata <- reactive({NULL})
  
  #Filter BenUse Table
  FilterBenUse <- reactive({
    ABBUF 
  })
  
  #Filter Variable Table
  FilterVariables <- reactive({
    V
  })
  
  #Filter WaterSource Table
  FilterWaterSource <- reactive({
    WS
  })
  
  #Filter AggFacts Table - Child BenUse Table
  FilterAllow <- reactive({
    AAF %>%
      filter(
        (VariableSpecificID %in% FilterVariables()$VariableSpecificID),
        (WaterSourceID %in% FilterWaterSource()$WaterSourceID),
        (ReportYearCV == input$ReportYearInput)
      )
  })
  
  ### County ###
  #Filter Site Table - Child AggFacts Table - Child BenUse Table
  CountyFilteredSite <- reactive({
    CountyAggSF %>%
      subset(
        ReportingUnitID %in% FilterAllow()$ReportingUnitID
      )
  })
  
  
  ### HUC8 ###
  #Filter Site Table - Child AggFacts Table - Child BenUse Table
  HUC8FilteredSite <- reactive({
    HUCAggSF %>%
      subset(
        ReportingUnitID %in% FilterAllow()$ReportingUnitID
      )
  })
  
  
  ### Basin ###
  #Filter Site Table - Child AggFacts Table - Child BenUse Table
  BasinFilteredSite <- reactive({
    BasinAggSF %>%
      subset(
        ReportingUnitID %in% FilterAllow()$ReportingUnitID
      )
  })
  
  
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  ##################################################################
  ####### County Plots Based on Observe Functions ########
  
  observe({
    req(input$tab_being_displayed == "County Reporting Unit")
    
    #Save variable on click on map event
    click = input$CountyMap_shape_click
    sub = CountyFilteredSite()[CountyFilteredSite()$ReportingUnitUUID == input$CountyMap_shape_click$id, c("ReportingUnitUUID")]
    nm = sub$ReportingUnitUUID
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      
      output$linePlotCountyA <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
        
      })
      
      output$linePlotCountyB <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
    } else {
      
      #Plot Amount v ReportyearCV by WaterSourceUUID
      output$linePlotCountyA <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & WaterSourceID
        tempCountyAggSF <- CountyAggSF %>%subset(ReportingUnitUUID %in% input$CountyMap_shape_click$id)
        tempAAF <- AAF %>%filter(ReportingUnitID %in% tempCountyAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = WS, by = "WaterSourceID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PCA <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=WaterSourceUUID, col=WaterSourceUUID)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (WaterSourceType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "WaterSourceType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PCA)
      })
      
      #Plot Amount v ReportyearCV by VariableCV
      output$linePlotCountyB <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableCV
        tempCountyAggSF <- CountyAggSF %>% subset(ReportingUnitUUID %in% input$CountyMap_shape_click$id)
        tempAAF <- AAF %>% filter(ReportingUnitID %in% tempCountyAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = V, by = "VariableSpecificID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PCB <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=VariableCV, col=VariableCV)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (VariableType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "VariableType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PCB)
      })
      
    }
  })
  
  ####### End County Plots Based on Observe Functions s ########
  ##################################################################
  
  
  ##################################################################
  ####### HUC8 Plots Based on Observe Functions ########
  
  observe({
    req(input$tab_being_displayed == "HUC8 Reporting Unit")
    
    #Save variable on click on map event
    click = input$HUC8Map_shape_click
    sub = HUC8FilteredSite()[HUC8FilteredSite()$ReportingUnitUUID == input$HUC8Map_shape_click$id, c("ReportingUnitUUID")]
    nm = sub$ReportingUnitUUID
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      
      output$linePlotHUC8A <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
      output$linePlotHUC8B <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
    } else {
      
      #Plot Amount v ReportyearCV by WaterSourceUUID
      output$linePlotHUC8A <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & WaterSourceID
        tempHUCAggSF <- HUCAggSF %>%subset(ReportingUnitUUID %in% input$HUC8Map_shape_click$id)
        tempAAF <- AAF %>% filter(ReportingUnitID %in% tempHUCAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = WS, by = "WaterSourceID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PHA <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=WaterSourceUUID, col=WaterSourceUUID)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (WaterSourceType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "WaterSourceType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PHA)
      })
      
      #Plot Amount v ReportyearCV by VariableCV
      output$linePlotHUC8B <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableCV
        tempHUCAggSF <- HUCAggSF %>% subset(ReportingUnitUUID %in% input$HUC8Map_shape_click$id)
        tempAAF <- AAF %>% filter(ReportingUnitID %in% tempHUCAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = V, by = "VariableSpecificID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PHB <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=VariableCV, col=VariableCV)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (VariableType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "VariableType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PHB)
      })
      
    }
  })
  
  ####### End HUC8 Plots Based on Observe Functions s ########
  ##################################################################
  
  
  ##################################################################
  ####### Basin Plots Based on Observe Functions ########
  
  observe({
    req(input$tab_being_displayed == "Basin Reporting Unit")
    
    #Save variable on click on map event
    click = input$BasinMap_shape_click
    sub = BasinFilteredSite()[BasinFilteredSite()$ReportingUnitUUID == input$BasinMap_shape_click$id, c("ReportingUnitUUID")]
    nm = sub$ReportingUnitUUID
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      
      
      output$linePlotBasinA <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
      output$linePlotBasinB <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
    } else {
      
      #Plot Amount v ReportyearCV by WaterSourceUUID
      output$linePlotBasinA <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & WaterSourceID
        tempBasinAggSF <- BasinAggSF %>%subset(ReportingUnitUUID %in% input$BasinMap_shape_click$id)
        tempAAF <- AAF %>%filter(ReportingUnitID %in% tempBasinAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = WS, by = "WaterSourceID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PBA <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=WaterSourceUUID, col=WaterSourceUUID)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (WaterSourceType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "WaterSourceType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PBA)
      })
      
      #Plot Amount v ReportyearCV by VariableCV
      output$linePlotBasinB <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableCV
        tempBasinAggSF <- BasinAggSF %>% subset(ReportingUnitUUID %in% input$BasinMap_shape_click$id)
        tempAAF <- AAF %>% filter(ReportingUnitID %in% tempBasinAggSF$ReportingUnitID)
        tempAAF_2 <- left_join(x = tempAAF, y = V, by = "VariableSpecificID")
        finalAFF <- tempAAF_2 %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        PBB <- ggplot(data=finalAFF, aes(x=ReportYearCV, y=SumAmouts, group=VariableCV, col=VariableCV)) +
          geom_line(show.legend = TRUE) +
          geom_point(show.legend = FALSE) +
          ggtitle("Amount -per- Report Year (VariableType)") +
          scale_x_continuous(breaks = seq(round(min(finalAFF$ReportYearCV), digits =0),
                                          round(max(finalAFF$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF$ReportYearCV) - min(finalAFF$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma,
                             limits = c(round(min(finalAFF$SumAmouts), digits = 0),
                                        round(max(finalAFF$SumAmouts), digits = 0))) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "VariableType") +
          theme(legend.text = element_text(size = 9.0), legend.background = element_rect(color = "black", fill = "grey90", size = 1, linetype = "solid"),
                plot.title = element_text(hjust = 0.5, size = 14.0),
                panel.background=element_blank(),
                axis.title.y=element_text(size = 14), axis.text.y=element_text(size = 12), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 14), axis.text.x=element_text(size = 12), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=2, b=0, l=0, "cm"))
        
        ggplotly(PBB)
      })
      
    }
  })
  
  ####### End Basin Plots Based on Observe Functions s ########
  ##################################################################
  
  
  ##################################################################
  ######## County Map ########
  
  
  #Base Map Creation
  output$CountyMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        minZoom = 4,
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      ) %>%
      setView(lng = -107.50, lat = 37.00, zoom = 6)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "County Reporting Unit")  # Helps solves issue of observe({ waiting for user input before implementing.
    
    leafletProxy(
      mapId = "CountyMap",
    ) %>%
      clearShapes() %>%
      addPolygons(
        data = CountyAggSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = WSWCCounty,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0.4,
        fillColor = "grey",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = MNCounty,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0.4,
        fillColor = "grey",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = CountyFilteredSite(),
        # label = ~ReportingUnitUUID,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = "Yellow",
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "County Name: ", NAME, "<br>",
          "ReportingUnitID : ", ReportingUnitID, "<br>",
          "ReportingUnitUUID : ", ReportingUnitUUID, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', CountyFilteredSite()$ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      )
  })
  
  
  ######## End County Map ########
  ##################################################################
  
  
  ##################################################################
  ######## HUC8 Map ########
  
  #Base Map Creation
  output$HUC8Map <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        minZoom = 4,
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      )%>%
      setView(lng = -111.40, lat = 39.50, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "HUC8 Reporting Unit") # Helps solves issue of observe({ waiting for user input before implementing.
    leafletProxy(
      mapId = "HUC8Map",
    ) %>%
      clearShapes() %>%
      addPolygons(
        data = HUCAggSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = HUC8FilteredSite(),
        # label = ~ReportingUnitUUID,
        layerId = ~ReportingUnitUUID,
        color = "#444444", 
        weight = 1, 
        smoothFactor = 0.5,
        opacity = 1.0, 
        fillOpacity = 0.8,
        fillColor = "yellow",
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "HUC8 Code: ", HUC_8, "<br>",
          "HUC8 Name: ", ReportingUnitName, "<br>",
          "ReportingUnitID : ", ReportingUnitID, "<br>",
          "ReportingUnitUUID : ", ReportingUnitUUID, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', HUC8FilteredSite()$ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      )
  })
  
  ######## End HUC8 Map ########
  ##################################################################
  
  
  ##################################################################
  ######## Basin Map ########
  
  #Base Map Creation
  output$BasinMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        minZoom = 4,
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      )%>%
      setView(lng = -107.40, lat = 42.75, zoom = 7)
  })
  
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Basin Reporting Unit") # Helps solves issue of observe({ waiting for user input before implementing.
    leafletProxy(
      mapId = "BasinMap",
    ) %>%
      clearShapes() %>%
      addPolygons(
        data = BasinAggSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = BasinFilteredSite(),
        # label = ~ReportingUnitUUID,
        layerId = ~ReportingUnitUUID,
        color = "#444444", 
        weight = 1, 
        smoothFactor = 0.5,
        opacity = 1.0, 
        fillOpacity = 0.8,
        fillColor = "yellow",
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Basin Name: ", RU_Name, "<br>",
          "ReportingUnitID : ", ReportingUnitID, "<br>",
          "ReportingUnitUUID : ", ReportingUnitUUID, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', BasinFilteredSite()$ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      )
  })
  
  ######## End Basin Map ########
  ##################################################################
  
  
  
} #endServer